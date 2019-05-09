// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesResult;
import static io.flutter.plugins.inapppurchase.Translator.fromSkuDetailsList;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryResponseListener;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.lang.Override;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Wraps a {@link BillingClient} instance and responds to Dart calls for it. */
public class InAppPurchasePlugin implements MethodCallHandler {
  private @Nullable BillingClient billingClient;
  private final Activity activity;
  private final Context context;
  private final MethodChannel channel;

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

  private HashMap<String, SkuDetails> cachedSkus = new HashMap<>();

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/in_app_purchase");
    channel.setMethodCallHandler(
        new InAppPurchasePlugin(registrar.context(), registrar.activity(), channel));
  }

  public InAppPurchasePlugin(Context context, Activity activity, MethodChannel channel) {
    this.context = context;
    this.activity = activity;
    this.channel = channel;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case MethodNames.IS_READY:
        isReady(result);
        break;
      case MethodNames.START_CONNECTION:
        startConnection((int) call.argument("handle"), result);
        break;
      case MethodNames.END_CONNECTION:
        endConnection(result);
        break;
      case MethodNames.QUERY_SKU_DETAILS:
        querySkuDetailsAsync(
            (String) call.argument("skuType"), (List<String>) call.argument("skusList"), result);
        break;
      case MethodNames.LAUNCH_BILLING_FLOW:
        launchBillingFlow(
            (String) call.argument("sku"), (String) call.argument("accountId"), result);
        break;
      case MethodNames.QUERY_PURCHASES:
        queryPurchases((String) call.argument("skuType"), result);
        break;
      case MethodNames.QUERY_PURCHASE_HISTORY_ASYNC:
        queryPurchaseHistoryAsync((String) call.argument("skuType"), result);
        break;
      case MethodNames.CONSUME_PURCHASE_ASYNC:
        consumeAsync((String) call.argument("purchaseToken"), result);
        break;
      default:
        result.notImplemented();
    }
  }

  @VisibleForTesting
  /*package*/ InAppPurchasePlugin(@Nullable BillingClient billingClient, MethodChannel channel) {
    this.billingClient = billingClient;
    this.channel = channel;
    this.context = null;
    this.activity = null;
  }

  private void startConnection(final int handle, final Result result) {
    if (billingClient == null) {
      billingClient = buildBillingClient(context, channel);
    }

    billingClient.startConnection(
        new BillingClientStateListener() {
          @Override
          public void onBillingSetupFinished(int responseCode) {
            // Consider the fact that we've finished a success, leave it to the Dart side to validate the responseCode.
            result.success(responseCode);
          }

          @Override
          public void onBillingServiceDisconnected() {
            final Map<String, Object> arguments = new HashMap<>();
            arguments.put("handle", handle);
            channel.invokeMethod(MethodNames.ON_DISCONNECT, arguments);
          }
        });
  }

  private void endConnection(final Result result) {
    if (billingClient != null) {
      billingClient.endConnection();
      billingClient = null;
    }
    result.success(null);
  }

  private void isReady(Result result) {
    if (billingClientError(result)) {
      return;
    }

    result.success(billingClient.isReady());
  }

  private void querySkuDetailsAsync(
      final String skuType, final List<String> skusList, final Result result) {
    if (billingClientError(result)) {
      return;
    }

    SkuDetailsParams params =
        SkuDetailsParams.newBuilder().setType(skuType).setSkusList(skusList).build();
    billingClient.querySkuDetailsAsync(
        params,
        new SkuDetailsResponseListener() {
          public void onSkuDetailsResponse(
              int responseCode, @Nullable List<SkuDetails> skuDetailsList) {
            updateCachedSkus(skuDetailsList);
            final Map<String, Object> skuDetailsResponse = new HashMap<>();
            skuDetailsResponse.put("responseCode", responseCode);
            skuDetailsResponse.put("skuDetailsList", fromSkuDetailsList(skuDetailsList));
            result.success(skuDetailsResponse);
          }
        });
  }

  private void launchBillingFlow(String sku, @Nullable String accountId, Result result) {
    if (billingClientError(result)) {
      return;
    }

    SkuDetails skuDetails = cachedSkus.get(sku);
    if (skuDetails == null) {
      result.error(
          "NOT_FOUND",
          "Details for sku " + sku + " are not available. Has this ID already been fetched?",
          null);
      return;
    }

    BillingFlowParams.Builder paramsBuilder =
        BillingFlowParams.newBuilder().setSkuDetails(skuDetails);
    if (accountId != null && !accountId.isEmpty()) {
      paramsBuilder.setAccountId(accountId);
    }
    result.success(billingClient.launchBillingFlow(activity, paramsBuilder.build()));
  }

  private void consumeAsync(String purchaseToken, final Result result) {
    if (billingClientError(result)) {
      return;
    }

    ConsumeResponseListener listener =
        new ConsumeResponseListener() {
          @Override
          public void onConsumeResponse(
              @BillingClient.BillingResponse int responseCode, String outToken) {
            result.success(responseCode);
          }
        };
    billingClient.consumeAsync(purchaseToken, listener);
  }

  private void queryPurchases(String skuType, Result result) {
    if (billingClientError(result)) {
      return;
    }

    // Like in our connect call, consider the billing client responding a "success" here regardless of status code.
    result.success(fromPurchasesResult(billingClient.queryPurchases(skuType)));
  }

  private void queryPurchaseHistoryAsync(String skuType, final Result result) {
    if (billingClientError(result)) {
      return;
    }

    billingClient.queryPurchaseHistoryAsync(
        skuType,
        new PurchaseHistoryResponseListener() {
          @Override
          public void onPurchaseHistoryResponse(int responseCode, List<Purchase> purchasesList) {
            final Map<String, Object> serialized = new HashMap<>();
            serialized.put("responseCode", responseCode);
            serialized.put("purchasesList", fromPurchasesList(purchasesList));
            result.success(serialized);
          }
        });
  }

  private void updateCachedSkus(@Nullable List<SkuDetails> skuDetailsList) {
    if (skuDetailsList == null) {
      return;
    }

    for (SkuDetails skuDetails : skuDetailsList) {
      cachedSkus.put(skuDetails.getSku(), skuDetails);
    }
  }

  private boolean billingClientError(Result result) {
    if (billingClient != null) {
      return false;
    }

    result.error("UNAVAILABLE", "BillingClient is unset. Try reconnecting.", null);
    return true;
  }

  private static BillingClient buildBillingClient(Context context, MethodChannel channel) {
    return BillingClient.newBuilder(context)
        .setListener(new PluginPurchaseListener(channel))
        .build();
  }

  @VisibleForTesting
  /*package*/ static class PluginPurchaseListener implements PurchasesUpdatedListener {
    private final MethodChannel channel;

    PluginPurchaseListener(MethodChannel channel) {
      this.channel = channel;
    }

    @Override
    public void onPurchasesUpdated(int responseCode, @Nullable List<Purchase> purchases) {
      final Map<String, Object> callbackArgs = new HashMap<>();
      callbackArgs.put("responseCode", responseCode);
      callbackArgs.put("purchasesList", fromPurchasesList(purchases));
      channel.invokeMethod(MethodNames.ON_PURCHASES_UPDATED, callbackArgs);
    }
  }
}
