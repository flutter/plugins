package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.InAppPurchasePlugin.MethodNames.END_CONNECTION;
import static io.flutter.plugins.inapppurchase.InAppPurchasePlugin.MethodNames.IS_READY;
import static io.flutter.plugins.inapppurchase.InAppPurchasePlugin.MethodNames.LAUNCH_BILLING_FLOW;
import static io.flutter.plugins.inapppurchase.InAppPurchasePlugin.MethodNames.ON_DISCONNECT;
import static io.flutter.plugins.inapppurchase.InAppPurchasePlugin.MethodNames.QUERY_SKU_DETAILS;
import static io.flutter.plugins.inapppurchase.InAppPurchasePlugin.MethodNames.START_CONNECTION;
import static io.flutter.plugins.inapppurchase.Translator.fromSkuDetailsList;
import static java.util.Arrays.asList;
import static java.util.Collections.singletonList;
import static java.util.stream.Collectors.toList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.annotation.Nullable;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClient.BillingResponse;
import com.android.billingclient.api.BillingClient.SkuType;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

public class InAppPurchasePluginTest {
  InAppPurchasePlugin plugin;
  @Mock BillingClient mockBillingClient;
  @Mock MethodChannel mockMethodChannel;
  @Spy Result result;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    plugin = new InAppPurchasePlugin(mockBillingClient, mockMethodChannel);
  }

  @Test
  public void invalidMethod() {
    MethodCall call = new MethodCall("invalid", null);
    plugin.onMethodCall(call, result);
    verify(result, times(1)).notImplemented();
  }

  @Test
  public void isReady_true() {
    MethodCall call = new MethodCall(IS_READY, null);
    when(mockBillingClient.isReady()).thenReturn(true);
    plugin.onMethodCall(call, result);
    verify(result).success(true);
  }

  @Test
  public void isReady_false() {
    MethodCall call = new MethodCall(IS_READY, null);
    when(mockBillingClient.isReady()).thenReturn(false);
    plugin.onMethodCall(call, result);
    verify(result).success(false);
  }

  @Test
  public void isReady_clientDisconnected() {
    MethodCall disconnectCall = new MethodCall(END_CONNECTION, null);
    plugin.onMethodCall(disconnectCall, mock(Result.class));
    MethodCall isReadyCall = new MethodCall(IS_READY, null);

    plugin.onMethodCall(isReadyCall, result);

    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
    verify(result, never()).success(any());
  }

  @Test
  public void startConnection() {
    Map<String, Integer> arguments = new HashMap<>();
    arguments.put("handle", 1);
    MethodCall call = new MethodCall(START_CONNECTION, arguments);
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());

    plugin.onMethodCall(call, result);
    verify(result, never()).success(any());
    captor.getValue().onBillingSetupFinished(100);

    verify(result, times(1)).success(100);
  }

  @Test
  public void endConnection() {
    // Set up a connected BillingClient instance
    final int disconnectCallbackHandle = 22;
    Map<String, Integer> arguments = new HashMap<>();
    arguments.put("handle", disconnectCallbackHandle);
    MethodCall connectCall = new MethodCall(START_CONNECTION, arguments);
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());
    plugin.onMethodCall(connectCall, mock(Result.class));
    final BillingClientStateListener stateListener = captor.getValue();

    // Disconnect the connected client
    MethodCall disconnectCall = new MethodCall(END_CONNECTION, null);
    plugin.onMethodCall(disconnectCall, result);

    // Verify that the client is disconnected and that the OnDisconnect callback has been triggered
    verify(result, times(1)).success(any());
    verify(mockBillingClient, times(1)).endConnection();
    stateListener.onBillingServiceDisconnected();
    Map<String, Integer> expectedInvocation = new HashMap<>();
    expectedInvocation.put("handle", disconnectCallbackHandle);
    verify(mockMethodChannel, times(1)).invokeMethod(ON_DISCONNECT, expectedInvocation);
  }

  @Test
  public void querySkuDetailsAsync() {
    // Connect a billing client and set up the SKU query listeners
    establishConnectedBillingClient(/*arguments=*/ null, /*result=*/ null);
    String skuType = BillingClient.SkuType.INAPP;
    List<String> skusList = asList("id1", "id2");
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("skuType", skuType);
    arguments.put("skusList", skusList);
    MethodCall queryCall = new MethodCall(QUERY_SKU_DETAILS, arguments);

    // Query for SKU details
    plugin.onMethodCall(queryCall, result);

    // Assert the arguments were forwarded correctly to BillingClient
    ArgumentCaptor<SkuDetailsParams> paramCaptor = ArgumentCaptor.forClass(SkuDetailsParams.class);
    ArgumentCaptor<SkuDetailsResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(SkuDetailsResponseListener.class);
    verify(mockBillingClient).querySkuDetailsAsync(paramCaptor.capture(), listenerCaptor.capture());
    assertEquals(paramCaptor.getValue().getSkuType(), skuType);
    assertEquals(paramCaptor.getValue().getSkusList(), skusList);

    // Assert that we handed result BillingClient's response
    int responseCode = 200;
    List<SkuDetails> skuDetailsResponse = asList(buildSkuDetails("foo"));
    listenerCaptor.getValue().onSkuDetailsResponse(responseCode, skuDetailsResponse);
    ArgumentCaptor<HashMap<String, Object>> resultCaptor = ArgumentCaptor.forClass(HashMap.class);
    verify(result).success(resultCaptor.capture());
    HashMap<String, Object> resultData = resultCaptor.getValue();
    assertEquals(resultData.get("responseCode"), responseCode);
    assertEquals(resultData.get("skuDetailsList"), fromSkuDetailsList(skuDetailsResponse));
  }

  @Test
  public void querySkuDetailsAsync_clientDisconnected() {
    // Disconnect the Billing client and prepare a querySkuDetails call
    MethodCall disconnectCall = new MethodCall(END_CONNECTION, null);
    plugin.onMethodCall(disconnectCall, mock(Result.class));
    String skuType = BillingClient.SkuType.INAPP;
    List<String> skusList = asList("id1", "id2");
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("skuType", skuType);
    arguments.put("skusList", skusList);
    MethodCall queryCall = new MethodCall(QUERY_SKU_DETAILS, arguments);

    // Query for SKU details
    plugin.onMethodCall(queryCall, result);

    // Assert that we sent an error back.
    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
    verify(result, never()).success(any());
  }

  @Test
  public void launchBillingFlow_ok_nullAccountId() {
    // Fetch the sku details first and then prepare the launch billing flow call
    String skuId = "foo";
    queryForSkus(singletonList(skuId));
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("sku", skuId);
    arguments.put("accountId", null);
    MethodCall launchCall = new MethodCall(LAUNCH_BILLING_FLOW, arguments);

    // Launch the billing flow
    int responseCode = BillingResponse.OK;
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(responseCode);
    plugin.onMethodCall(launchCall, result);

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    BillingFlowParams params = billingFlowParamsCaptor.getValue();
    assertEquals(params.getSku(), skuId);
    assertNull(params.getAccountId());

    // Verify we pass the response code to result
    verify(result, never()).error(any(), any(), any());
    verify(result, times(1)).success(responseCode);
  }

  @Test
  public void launchBillingFlow_ok_AccountId() {
    // Fetch the sku details first and query the method call
    String skuId = "foo";
    String accountId = "account";
    queryForSkus(singletonList(skuId));
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("sku", skuId);
    arguments.put("accountId", accountId);
    MethodCall launchCall = new MethodCall(LAUNCH_BILLING_FLOW, arguments);

    // Launch the billing flow
    int responseCode = BillingResponse.OK;
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(responseCode);
    plugin.onMethodCall(launchCall, result);

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    BillingFlowParams params = billingFlowParamsCaptor.getValue();
    assertEquals(params.getSku(), skuId);
    assertEquals(params.getAccountId(), accountId);

    // Verify we pass the response code to result
    verify(result, never()).error(any(), any(), any());
    verify(result, times(1)).success(responseCode);
  }

  @Test
  public void launchBillingFlow_clientDisconnected() {
    // Prepare the launch call after disconnecting the client
    MethodCall disconnectCall = new MethodCall(END_CONNECTION, null);
    plugin.onMethodCall(disconnectCall, mock(Result.class));
    String skuId = "foo";
    String accountId = "account";
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("sku", skuId);
    arguments.put("accountId", accountId);
    MethodCall launchCall = new MethodCall(LAUNCH_BILLING_FLOW, arguments);

    plugin.onMethodCall(launchCall, result);

    // Assert that we sent an error back.
    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
    verify(result, never()).success(any());
  }

  @Test
  public void launchBillingFlow_skuNotFound() {
    // Try to launch the billing flow for a random sku ID
    establishConnectedBillingClient(null, null);
    String skuId = "foo";
    String accountId = "account";
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("sku", skuId);
    arguments.put("accountId", accountId);
    MethodCall launchCall = new MethodCall(LAUNCH_BILLING_FLOW, arguments);

    plugin.onMethodCall(launchCall, result);

    // Assert that we sent an error back.
    verify(result).error(contains("NOT_FOUND"), contains(skuId), any());
    verify(result, never()).success(any());
  }

  private void establishConnectedBillingClient(
      @Nullable Map<String, Integer> arguments, @Nullable Result result) {
    if (arguments == null) {
      arguments = new HashMap<>();
      arguments.put("handle", 1);
    }
    if (result == null) {
      result = mock(Result.class);
    }

    MethodCall connectCall = new MethodCall(START_CONNECTION, arguments);
    plugin.onMethodCall(connectCall, result);
  }

  private void queryForSkus(List<String> skusList) {
    // Set up the query method call
    establishConnectedBillingClient(/*arguments=*/ null, /*result=*/ null);
    HashMap<String, Object> arguments = new HashMap<>();
    String skuType = SkuType.INAPP;
    arguments.put("skuType", skuType);
    arguments.put("skusList", skusList);
    MethodCall queryCall = new MethodCall(QUERY_SKU_DETAILS, arguments);

    // Call the method.
    plugin.onMethodCall(queryCall, mock(Result.class));

    // Respond to the call with a matching set of Sku details.
    ArgumentCaptor<SkuDetailsResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(SkuDetailsResponseListener.class);
    verify(mockBillingClient).querySkuDetailsAsync(any(), listenerCaptor.capture());
    List<SkuDetails> skuDetailsResponse =
        skusList.stream().map(this::buildSkuDetails).collect(toList());
    listenerCaptor.getValue().onSkuDetailsResponse(BillingResponse.OK, skuDetailsResponse);
  }

  private SkuDetails buildSkuDetails(String id) {
    SkuDetails details = mock(SkuDetails.class);
    when(details.getSku()).thenReturn(id);
    return details;
  }
}
