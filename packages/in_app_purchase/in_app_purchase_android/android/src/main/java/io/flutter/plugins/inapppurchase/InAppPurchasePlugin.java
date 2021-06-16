// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.util.Log;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import java.lang.reflect.Field;

/** Wraps a {@link BillingClient} instance and responds to Dart calls for it. */
public class InAppPurchasePlugin implements FlutterPlugin, ActivityAware {

  static final String PROXY_PACKAGE_KEY = "PROXY_PACKAGE";

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

    private MethodNames() {};
  }

  private MethodChannel methodChannel;
  private MethodCallHandlerImpl methodCallHandler;

  /** Plugin registration. */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    InAppPurchasePlugin plugin = new InAppPurchasePlugin();
    // Setting the package proxy to match library's build config. which matches the <package> in AndroidManifest.xml.
    registrar.activity().getIntent().putExtra(PROXY_PACKAGE_KEY, getLibraryPackageName());
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
    // Setting the package proxy to match library's build config. which matches the <package> in AndroidManifest.xml.
    binding.getActivity().getIntent().putExtra(PROXY_PACKAGE_KEY, getLibraryPackageName());
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

  private static String getLibraryPackageName() {
    String packageName = null;

    try {
      Field libraryPackageName = BuildConfig.class.getField("LIBRARY_PACKAGE_NAME");
      packageName = (String) (libraryPackageName.get(null));
    } catch (Exception e) {
      // Ignore the exception here. We log as error only if getting `APPLICATION_ID` below also throws exception.
    }
    if (packageName == null) {
      try {
        // Lower version uses APPLICATION_ID instead.
        Field applicationIdField = BuildConfig.class.getField("APPLICATION_ID");
        packageName = (String) (applicationIdField.get(null));
      } catch (Exception e) {
        Log.e("in_app_purchase_android", "Error getting BuildConfig.LIBRARY_PACKAGE_NAME or BuildConfig.LIBRARY_PACKAGE_NAME at getLibraryPackageName: ")
      }
    }
    return packageName;
  }
}
