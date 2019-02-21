// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import androidx.annotation.Nullable;
import com.android.billingclient.api.SkuDetails;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

/** Handles serialization of {@link com.android.billingclient.api.BillingClient} related objects. */
/*package*/ class Translator {
  static HashMap<String, Object> fromSkuDetail(SkuDetails detail) {
    HashMap<String, Object> info = new HashMap<>();
    info.put("title", detail.getTitle());
    info.put("description", detail.getDescription());
    info.put("freeTrialPeriod", detail.getFreeTrialPeriod());
    info.put("introductoryPrice", detail.getIntroductoryPrice());
    info.put("introductoryPriceAmountMicros", detail.getIntroductoryPriceAmountMicros());
    info.put("introductoryPriceCycles", detail.getIntroductoryPriceCycles());
    info.put("introductoryPricePeriod", detail.getIntroductoryPricePeriod());
    info.put("price", detail.getPrice());
    info.put("priceAmountMicros", detail.getPriceAmountMicros());
    info.put("priceCurrencyCode", detail.getPriceCurrencyCode());
    info.put("sku", detail.getSku());
    info.put("type", detail.getType());
    info.put("isRewarded", detail.isRewarded());
    info.put("subscriptionPeriod", detail.getSubscriptionPeriod());
    return info;
  }

  static List<HashMap<String, Object>> fromSkuDetailsList(
      @Nullable List<SkuDetails> skuDetailsList) {
    if (skuDetailsList == null) {
      return Collections.emptyList();
    }

    ArrayList<HashMap<String, Object>> output = new ArrayList<>();
    for (SkuDetails detail : skuDetailsList) {
      output.add(fromSkuDetail(detail));
    }
    return output;
  }
}
