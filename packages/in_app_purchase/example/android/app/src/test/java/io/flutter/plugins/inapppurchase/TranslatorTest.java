// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static org.junit.Assert.assertEquals;

import com.android.billingclient.api.SkuDetails;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONException;
import org.junit.Test;

public class TranslatorTest {
  private static final String SKU_DETAIL_EXAMPLE_JSON =
      "{\"productId\":\"example\",\"type\":\"inapp\",\"price\":\"$0.99\",\"price_amount_micros\":990000,\"price_currency_code\":\"USD\",\"title\":\"Example title\",\"description\":\"Example description.\"}";

  @Test
  public void fromSkuDetail() throws JSONException {
    final SkuDetails expected = new SkuDetails(SKU_DETAIL_EXAMPLE_JSON);

    Map<String, Object> serialized = Translator.fromSkuDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromSkuDetailsList() throws JSONException {
    final String SKU_DETAIL_EXAMPLE_2_JSON =
        "{\"productId\":\"example2\",\"type\":\"inapp\",\"price\":\"$0.99\",\"price_amount_micros\":990000,\"price_currency_code\":\"USD\",\"title\":\"Example title\",\"description\":\"Example description.\"}";
    final List<SkuDetails> expected =
        Arrays.asList(
            new SkuDetails(SKU_DETAIL_EXAMPLE_JSON), new SkuDetails(SKU_DETAIL_EXAMPLE_2_JSON));

    final List<HashMap<String, Object>> serialized = Translator.fromSkuDetailsList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromSkuDetailsList_null() {
    assertEquals(0, Translator.fromSkuDetailsList(null).size());
  }

  private void assertSerialized(SkuDetails expected, Map<String, Object> serialized) {
    assertEquals(expected.getDescription(), serialized.get("description"));
    assertEquals(expected.getFreeTrialPeriod(), serialized.get("freeTrialPeriod"));
    assertEquals(expected.getIntroductoryPrice(), serialized.get("introductoryPrice"));
    assertEquals(
        expected.getIntroductoryPriceAmountMicros(),
        serialized.get("introductoryPriceAmountMicros"));
    assertEquals(expected.getIntroductoryPriceCycles(), serialized.get("introductoryPriceCycles"));
    assertEquals(expected.getIntroductoryPricePeriod(), serialized.get("introductoryPricePeriod"));
    assertEquals(expected.getPrice(), serialized.get("price"));
    assertEquals(expected.getPriceAmountMicros(), serialized.get("priceAmountMicros"));
    assertEquals(expected.getPriceCurrencyCode(), serialized.get("priceCurrencyCode"));
    assertEquals(expected.getSku(), serialized.get("sku"));
    assertEquals(expected.getSubscriptionPeriod(), serialized.get("subscriptionPeriod"));
    assertEquals(expected.getTitle(), serialized.get("title"));
    assertEquals(expected.getType(), serialized.get("type"));
  }
}
