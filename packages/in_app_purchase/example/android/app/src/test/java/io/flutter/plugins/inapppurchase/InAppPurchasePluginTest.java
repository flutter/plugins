package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromSkuDetailsList;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.support.annotation.Nullable;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.Arrays;
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
    MethodCall call = new MethodCall("BillingClient#isReady()", null);
    when(mockBillingClient.isReady()).thenReturn(true);
    plugin.onMethodCall(call, result);
    verify(result).success(true);
  }

  @Test
  public void isReady_false() {
    MethodCall call = new MethodCall("BillingClient#isReady()", null);
    when(mockBillingClient.isReady()).thenReturn(false);
    plugin.onMethodCall(call, result);
    verify(result).success(false);
  }

  @Test
  public void isReady_clientDisconnected() {
    MethodCall disconnectCall = new MethodCall("BillingClient#endConnection()", null);
    plugin.onMethodCall(disconnectCall, mock(Result.class));
    MethodCall isReadyCall = new MethodCall("BillingClient#isReady()", null);

    plugin.onMethodCall(isReadyCall, result);

    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
    verify(result, never()).success(any());
  }

  @Test
  public void startConnection() {
    Map<String, Integer> arguments = new HashMap<>();
    arguments.put("handle", 1);
    MethodCall call =
        new MethodCall("BillingClient#startConnection(BillingClientStateListener)", arguments);
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
    MethodCall connectCall =
        new MethodCall("BillingClient#startConnection(BillingClientStateListener)", arguments);
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());
    plugin.onMethodCall(connectCall, mock(Result.class));
    final BillingClientStateListener stateListener = captor.getValue();

    // Disconnect the connected client
    MethodCall disconnectCall = new MethodCall("BillingClient#endConnection()", null);
    plugin.onMethodCall(disconnectCall, result);

    // Verify that the client is disconnected and that the OnDisconnect callback has been triggered
    verify(result, times(1)).success(any());
    verify(mockBillingClient, times(1)).endConnection();
    stateListener.onBillingServiceDisconnected();
    Map<String, Integer> expectedInvocation = new HashMap<>();
    expectedInvocation.put("handle", disconnectCallbackHandle);
    verify(mockMethodChannel, times(1))
        .invokeMethod(
            "BillingClientStateListener#onBillingServiceDisconnected()", expectedInvocation);
  }

  @Test
  public void querySkuDetailsAsync() {
    // Connect a billing client and set up the SKU query listeners
    establishConnectedBillingClient(/*arguments=*/ null, /*result=*/ null);
    String skuType = BillingClient.SkuType.INAPP;
    List<String> skusList = Arrays.asList("id1", "id2");
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("skuType", skuType);
    arguments.put("skusList", skusList);
    MethodCall queryCall =
        new MethodCall(
            "BillingClient#querySkuDetailsAsync(SkuDetailsParams, SkuDetailsResponseListener)",
            arguments);

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
    List<SkuDetails> skuDetailsResponse = Arrays.asList(buildSkuDetails());
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
    MethodCall disconnectCall = new MethodCall("BillingClient#endConnection()", null);
    plugin.onMethodCall(disconnectCall, mock(Result.class));
    String skuType = BillingClient.SkuType.INAPP;
    List<String> skusList = Arrays.asList("id1", "id2");
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("skuType", skuType);
    arguments.put("skusList", skusList);
    MethodCall queryCall =
        new MethodCall(
            "BillingClient#querySkuDetailsAsync(SkuDetailsParams, SkuDetailsResponseListener)",
            arguments);

    // Query for SKU details
    plugin.onMethodCall(queryCall, result);

    // Assert that we sent an error back.
    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
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

    MethodCall connectCall =
        new MethodCall("BillingClient#startConnection(BillingClientStateListener)", arguments);
    plugin.onMethodCall(connectCall, result);
  }

  private SkuDetails buildSkuDetails() {
    SkuDetails details = mock(SkuDetails.class);
    when(details.getSku()).thenReturn("foo");
    return details;
  }
}
