package io.flutter.plugins.inapppurchase;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
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
  @Spy Result result;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    plugin = new InAppPurchasePlugin(mockBillingClient, null);
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
}
