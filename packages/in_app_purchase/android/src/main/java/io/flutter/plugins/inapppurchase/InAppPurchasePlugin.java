package io.flutter.plugins.inapppurchase;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
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
  private final Context context;
  private final MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/in_app_purchase");
    channel.setMethodCallHandler(new InAppPurchasePlugin(registrar.context(), channel));
  }

  public InAppPurchasePlugin(Context context, MethodChannel channel) {
    this.context = context;
    this.channel = channel;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "BillingClient#isReady()":
        isReady(result);
        break;
      case "BillingClient#startConnection(BillingClientStateListener)":
        startConnection((int) call.argument("handle"), result);
        break;
      case "BillingClient#endConnection()":
        endConnection(result);
        break;
      default:
        result.notImplemented();
    }
  }

  @VisibleForTesting
  /*package*/ InAppPurchasePlugin(BillingClient billingClient, MethodChannel channel) {
    this.billingClient = billingClient;
    this.channel = channel;
    this.context = null;
  }

  private void startConnection(final int handle, final Result result) {
    if (billingClient == null) {
      billingClient = buildBillingClient(context);
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
            channel.invokeMethod(
                "BillingClientStateListener#onBillingServiceDisconnected()", arguments);
          }
        });
  }

  private void endConnection(final Result result) {
    billingClient.endConnection();
    billingClient = null;
    result.success(null);
  }

  private void isReady(Result result) {
    result.success(billingClient.isReady());
  }

  private static BillingClient buildBillingClient(Context context) {
    return BillingClient.newBuilder(context)
        .setListener(
            new PurchasesUpdatedListener() {
              @Override
              public void onPurchasesUpdated(
                  int responseCode, @Nullable List<Purchase> purchases) {}
            })
        .build();
  }
}
