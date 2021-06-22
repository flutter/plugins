// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

/** Wraps a {@link BillingClient} instance and responds to Dart calls for it. */
public class InAppPurchasePlugin implements FlutterPlugin, ActivityAware {

  static final String PROXY_PACKAGE_KEY = "PROXY_PACKAGE";
  // The proxy value has to match the <package> value in library's AndroidManifest.xml.
  // This is important that the <package> is not changed, so we hard code the value here then having
  // a unit test to make sure. If there is a strong reason to change the <package> value, please inform the
  // code owner of this package.
  static final String PROXY_VALUE = "io.flutter.plugins.inapppurchase";

  @VisibleForTesting
  static final class MethodNames {
    static final String IS_READY = "BillingClient#isReady()";
    static final String START_CONNECTION =
        "BillingClient#startConnection(BillingClientStateListener)";
    static final String END_CONNECTION = "BillingClient#endConnection()";
    static final String ON_DISCONNECT = "BillingClientStateListener#onBillingServiceDisconnected()";
    static final String QUERY_SKU_DETAILS =
        "BillingClient#querySkuDetailsAsync(SkuDetailsParams, SkuDetailsResponseListener)";
    static final String LAUNCH_BILLING_FLOW =
        "BillingClient#launchBillingFlow(Activity, BillingFlowParams)";
    static final String ON_PURCHASES_UPDATED =
        "PurchasesUpdatedListener#onPurchasesUpdated(int, List<Purchase>)";
    static final String QUERY_PURCHASES = "BillingClient#queryPurchases(String)";
    static final String QUERY_PURCHASE_HISTORY_ASYNC =
        "BillingClient#queryPurchaseHistoryAsync(String, PurchaseHistoryResponseListener)";
    static final String CONSUME_PURCHASE_ASYNC =
        "BillingClient#consumeAsync(String, ConsumeResponseListener)";
    static final String ACKNOWLEDGE_PURCHASE =
        "BillingClient#(AcknowledgePurchaseParams params, (AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener)";
    static final String IS_FEATURE_SUPPORTED = "BillingClient#isFeatureSupported(String)";
    static final String LAUNCH_PRICE_CHANGE_CONFIRMATION_FLOW =
        "BillingClient#launchPriceChangeConfirmationFlow (Activity, PriceChangeFlowParams, PriceChangeConfirmationListener)";

    private MethodNames() {};
  }

  private MethodChannel methodChannel;
  private MethodCallHandlerImpl methodCallHandler;

  /** Plugin registration. */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    InAppPurchasePlugin plugin = new InAppPurchasePlugin();
    registrar.activity().getIntent().putExtra(PROXY_PACKAGE_KEY, PROXY_VALUE);
    ((Application) registrar.context().getApplicationContext())
        .registerActivityLifecycleCallbacks(plugin.methodCallHandler);
  }

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    setupMethodChannel(
        /*activity=*/ null, binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    teardownMethodChannel();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.getActivity().getIntent().putExtra(PROXY_PACKAGE_KEY, PROXY_VALUE);
    methodCallHandler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    methodCallHandler.setActivity(null);
    methodCallHandler.onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    methodCallHandler.setActivity(null);
  }

  private void setupMethodChannel(Activity activity, BinaryMessenger messenger, Context context) {
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/in_app_purchase");
    methodCallHandler =
        new MethodCallHandlerImpl(activity, context, methodChannel, new BillingClientFactoryImpl());
    methodChannel.setMethodCallHandler(methodCallHandler);
  }

  private void teardownMethodChannel() {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    methodCallHandler = null;
  }

  @VisibleForTesting
  void setMethodCallHandler(MethodCallHandlerImpl methodCallHandler) {
    this.methodCallHandler = methodCallHandler;
  }
}
