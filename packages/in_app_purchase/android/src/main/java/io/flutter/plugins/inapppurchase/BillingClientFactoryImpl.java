package io.flutter.plugins.inapppurchase;

import android.content.Context;
import com.android.billingclient.api.BillingClient;
import io.flutter.plugin.common.MethodChannel;

/** The implementation for {@link BillingClientFactory} for the plugin. */
public final class BillingClientFactoryImpl implements BillingClientFactory {

  @Override
  public BillingClient createBillingClient(Context context, MethodChannel channel) {
    return BillingClient.newBuilder(context)
        .setListener(new PluginPurchaseListener(channel))
        .build();
  }
}
