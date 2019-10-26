// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesResult;
import static io.flutter.plugins.inapppurchase.Translator.fromSkuDetailsList;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryResponseListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Handles method channel for the plugin. */
class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

  private static final String TAG = "InAppPurchasePlugin";

  @Nullable private BillingClient billingClient;
  private final BillingClientFactory billingClientFactory;

  @Nullable private Activity activity;
  private final Context applicationContext;
  private final MethodChannel methodChannel;

  private HashMap<String, SkuDetails> cachedSkus = new HashMap<>();

  /** Constructs the MethodCallHandlerImpl */
  MethodCallHandlerImpl(
      @Nullable Activity activity,
      @NonNull Context applicationContext,
      @NonNull MethodChannel methodChannel,
      @NonNull BillingClientFactory billingClientFactory) {
    this.billingClientFactory = billingClientFactory;
    this.applicationContext = applicationContext;
    this.activity = activity;
    this.methodChannel = methodChannel;
  }

  /**
   * Sets the activity. Should be called as soon as the the activity is available. When the activity
   * becomes unavailable, call this method again with {@code null}.
   */
  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case InAppPurchasePlugin.MethodNames.IS_READY:
        isReady(result);
        break;
      case InAppPurchasePlugin.MethodNames.START_CONNECTION:
        startConnection((int) call.argument("handle"), result);
        break;
      case InAppPurchasePlugin.MethodNames.END_CONNECTION:
        endConnection(result);
        break;
      case InAppPurchasePlugin.MethodNames.QUERY_SKU_DETAILS:
        querySkuDetailsAsync(
            (String) call.argument("skuType"), (List<String>) call.argument("skusList"), result);
        break;
      case InAppPurchasePlugin.MethodNames.LAUNCH_BILLING_FLOW:
        launchBillingFlow(
            (String) call.argument("sku"), (String) call.argument("accountId"), result);
        break;
      case InAppPurchasePlugin.MethodNames.QUERY_PURCHASES:
        queryPurchases((String) call.argument("skuType"), result);
        break;
      case InAppPurchasePlugin.MethodNames.QUERY_PURCHASE_HISTORY_ASYNC:
        queryPurchaseHistoryAsync((String) call.argument("skuType"), result);
        break;
      case InAppPurchasePlugin.MethodNames.CONSUME_PURCHASE_ASYNC:
        consumeAsync((String) call.argument("purchaseToken"), result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void endConnection(final MethodChannel.Result result) {
    if (billingClient != null) {
      billingClient.endConnection();
      billingClient = null;
    }
    result.success(null);
  }

  private void isReady(MethodChannel.Result result) {
    if (billingClientError(result)) {
      return;
    }

    result.success(billingClient.isReady());
  }

  private void querySkuDetailsAsync(
      final String skuType, final List<String> skusList, final MethodChannel.Result result) {
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

  private void launchBillingFlow(
      String sku, @Nullable String accountId, MethodChannel.Result result) {
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

    if (activity == null) {
      result.error(
          "ACTIVITY_UNAVAILABLE",
          "Details for sku "
              + sku
              + " are not available. This method must be run with the app in foreground.",
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

  private void consumeAsync(String purchaseToken, final MethodChannel.Result result) {
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

  private void queryPurchases(String skuType, MethodChannel.Result result) {
    if (billingClientError(result)) {
      return;
    }

    // Like in our connect call, consider the billing client responding a "success" here regardless of status code.
    result.success(fromPurchasesResult(billingClient.queryPurchases(skuType)));
  }

  private void queryPurchaseHistoryAsync(String skuType, final MethodChannel.Result result) {
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

  private void startConnection(final int handle, final MethodChannel.Result result) {
    if (billingClient == null) {
      billingClient = billingClientFactory.createBillingClient(applicationContext, methodChannel);
    }

    billingClient.startConnection(
        new BillingClientStateListener() {
          private boolean alreadyFinished = false;

          @Override
          public void onBillingSetupFinished(int responseCode) {
            if (alreadyFinished) {
              Log.d(TAG, "Tried to call onBilllingSetupFinished multiple times.");
              return;
            }
            alreadyFinished = true;
            // Consider the fact that we've finished a success, leave it to the Dart side to validate the responseCode.
            result.success(responseCode);
          }

          @Override
          public void onBillingServiceDisconnected() {
            final Map<String, Object> arguments = new HashMap<>();
            arguments.put("handle", handle);
            methodChannel.invokeMethod(InAppPurchasePlugin.MethodNames.ON_DISCONNECT, arguments);
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

  private boolean billingClientError(MethodChannel.Result result) {
    if (billingClient != null) {
      return false;
    }

    result.error("UNAVAILABLE", "BillingClient is unset. Try reconnecting.", null);
    return true;
  }
}
