package io.flutter.plugins.inapppurchase;

import android.app.Activity;
import android.content.Context;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.SkuDetails;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class MethodCallHandlerTest {
    private MethodCallHandlerImpl methodCallHandler;
    private MockedStatic<BillingFlowParams> mockStaticBuilder;
    private BillingFlowParams.Builder billingFlowParamsBuilder;
    private BillingFlowParams billingFlowParams;

    @Before
    public void before() {
        methodCallHandler = new MethodCallHandlerImpl(null, mock(Context.class), mock(MethodChannel.class), mock(BillingClientFactory.class));
        methodCallHandler.billingClient = mock(BillingClient.class);
        BillingClient client = mock(BillingClient.class);
        when(client.isReady()).thenReturn(true);

        SkuDetails details = mock(SkuDetails.class);
        methodCallHandler.cachedSkus.put("testPurchase", details);

        setupBillingFlow();
    }

    @After
    public void after(){
        closeBillingFlow();
    }

    @Test
    public void isReady_returns_true_if_billingClientIsReady() {
        BillingClient client = mock(BillingClient.class);
        when(client.isReady()).thenReturn(true);
        MethodChannel.Result result = mock(MethodChannel.Result.class);
        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.IS_READY, null);

        methodCallHandler.billingClient = client;
        methodCallHandler.onMethodCall(call, result);

        verify(result, times(1)).success(true);
    }

    @Test
    public void isReady_returns_false_if_billingClientIsNotReady() {
        BillingClient client = mock(BillingClient.class);
        when(client.isReady()).thenReturn(false);
        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.IS_READY, null);
        MethodChannel.Result result = mock(MethodChannel.Result.class);

        methodCallHandler.billingClient = client;
        methodCallHandler.onMethodCall(call, result);

        verify(result, times(1)).success(false);
    }

    @Test
    public void isReady_returns_false_if_billingClientIsNotSet() {
        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.IS_READY, null);
        MethodChannel.Result result = mock(MethodChannel.Result.class);

        methodCallHandler.billingClient = null;
        methodCallHandler.onMethodCall(call, result);

        verify(result, times(1))
                .error("UNAVAILABLE", "BillingClient is unset. Try reconnecting.", null);
    }

    private Map<String, Object> createBillingArgs(){
        Map<String, Object> args = new HashMap<>();
        args.put("sku", "testPurchase");
        return args;
    }

    @Test
    public void launchBillingFlow_fails_withMissingSku() {
        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.LAUNCH_BILLING_FLOW, createBillingArgs());
        MethodChannel.Result result = mock(MethodChannel.Result.class);

        methodCallHandler.cachedSkus.remove("testPurchase");
        methodCallHandler.onMethodCall(call, result);

        verify(result, times(1))
                .error("NOT_FOUND",
                        "Details for sku testPurchase are not available. " +
                                "It might because skus were not fetched prior to the call. " +
                                "Please fetch the skus first. An example of how to fetch the skus could be found here: " +
                                "https://github.com/flutter/plugins/blob/master/packages/in_app_purchase/README.md#loading-products-for-sale",
                        null);
    }

    @Test
    public void launchBillingFlow_fails_whenNotAttachedToActivity() {
        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.LAUNCH_BILLING_FLOW, createBillingArgs());
        MethodChannel.Result result = mock(MethodChannel.Result.class);

        methodCallHandler.onMethodCall(call, result);

        verify(result, times(1))
                .error("ACTIVITY_UNAVAILABLE",
                        "Details for sku testPurchase are not available. This method must be run with the app in foreground.",
                        null);
    }

    @Test
    public void launchBillingFlow_launchesBillingFlowOnClient() {
        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.LAUNCH_BILLING_FLOW, createBillingArgs());
        MethodChannel.Result result = mock(MethodChannel.Result.class);

        assert methodCallHandler.billingClient != null;
        when(methodCallHandler.billingClient.launchBillingFlow(any(Activity.class), any(BillingFlowParams.class))).thenReturn(mock(BillingResult.class));

        Activity activity = mock(Activity.class);
        methodCallHandler.setActivity(activity);
        methodCallHandler.onMethodCall(call, result);

        verify(methodCallHandler.billingClient, times(1)).launchBillingFlow(activity, billingFlowParams);
        verify(result, times(1)).success(any());
    }

    @Test
    public void launchBillingFlow_setsObfuscatedProfileId() {
        String obfuscatedProfileId = "abcdef";
        Map<String, Object> billingArgs = createBillingArgs();
        billingArgs.put("obfuscatedProfileId", obfuscatedProfileId);

        MethodCall call = new MethodCall(InAppPurchasePlugin.MethodNames.LAUNCH_BILLING_FLOW, billingArgs);
        MethodChannel.Result result = mock(MethodChannel.Result.class);

        methodCallHandler.setActivity(mock(Activity.class));
        methodCallHandler.onMethodCall(call, result);

        verify(billingFlowParamsBuilder, times(1)).setObfuscatedProfileId(obfuscatedProfileId);
    }

    private void setupBillingFlow(){
        assert methodCallHandler.billingClient != null;
        when(methodCallHandler.billingClient.launchBillingFlow(any(Activity.class), any(BillingFlowParams.class))).thenReturn(mock(BillingResult.class));

        billingFlowParamsBuilder = mock(BillingFlowParams.Builder.class);
        mockStaticBuilder = mockStatic(BillingFlowParams.class);
        mockStaticBuilder.when(new MockedStatic.Verification() {
            @Override
            public void apply() {
                BillingFlowParams.newBuilder();
            }
        }).thenReturn(billingFlowParamsBuilder);

        when(billingFlowParamsBuilder.setSkuDetails(any(SkuDetails.class))).thenReturn(billingFlowParamsBuilder);
        when(billingFlowParamsBuilder.setObfuscatedAccountId(any(String.class))).thenReturn(billingFlowParamsBuilder);
        billingFlowParams = mock(BillingFlowParams.class);
        when(billingFlowParamsBuilder.build()).thenReturn(billingFlowParams);
    }

    private void closeBillingFlow(){
        mockStaticBuilder.close();
    }
}
