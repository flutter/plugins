// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.content.Context;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** Wraps a {@link BillingClient} instance and responds to Dart calls for it. */
public class InAppPurchasePlugin implements FlutterPlugin, ActivityAware {

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

    private MethodNames() {};
  }

  private MethodChannel methodChannel;
  private MethodChannelHandler methodChannelHandler;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/in_app_purchase");
    final MethodChannelHandler methodChannelHandler =
        new MethodChannelHandler(
            registrar.activity(), registrar.context(), channel, new BillingClientFactoryImpl());
    channel.setMethodCallHandler(methodChannelHandler);
  }

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    setupMethodChannel(
        binding.getFlutterEngine().getDartExecutor(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    methodChannelHandler = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    methodChannelHandler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    methodChannelHandler.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  private void setupMethodChannel(BinaryMessenger messenger, Context context) {
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/in_app_purchase");
    methodChannelHandler =
        new MethodChannelHandler(null, context, methodChannel, new BillingClientFactoryImpl());
    methodChannel.setMethodCallHandler(methodChannelHandler);
  }
}
