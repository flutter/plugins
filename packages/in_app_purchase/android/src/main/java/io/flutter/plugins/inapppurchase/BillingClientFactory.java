package io.flutter.plugins.inapppurchase;

import android.content.Context;
import com.android.billingclient.api.BillingClient;
import io.flutter.plugin.common.MethodChannel;

public interface BillingClientFactory {
  BillingClient createBillingClient(Context context, MethodChannel channel);
}
