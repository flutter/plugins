// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.android.billingclient.api.BillingClient.BillingResponse;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.Purchase.PurchasesResult;
import com.android.billingclient.api.SkuDetails;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONException;
import org.junit.Test;

public class TranslatorTest {
  private static final String SKU_DETAIL_EXAMPLE_JSON =
      "{\"productId\":\"example\",\"type\":\"inapp\",\"price\":\"$0.99\",\"price_amount_micros\":990000,\"price_currency_code\":\"USD\",\"title\":\"Example title\",\"description\":\"Example description.\"}";
  private static final String PURCHASE_EXAMPLE_JSON =
      "{\"orderId\":\"foo\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\"}";

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
    assertEquals(Collections.emptyList(), Translator.fromSkuDetailsList(null));
  }

  @Test
  public void fromPurchase() throws JSONException {
    final Purchase expected = new Purchase(PURCHASE_EXAMPLE_JSON, "signature");

    assertSerialized(expected, Translator.fromPurchase(expected));
  }

  @Test
  public void fromPurchasesList() throws JSONException {
    final String purchase2Json =
        "{\"orderId\":\"foo2\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\"}";
    final String signature = "signature";
    final List<Purchase> expected =
        Arrays.asList(
            new Purchase(PURCHASE_EXAMPLE_JSON, signature), new Purchase(purchase2Json, signature));

    final List<HashMap<String, Object>> serialized = Translator.fromPurchasesList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromPurchasesList_null() {
    assertEquals(Collections.emptyList(), Translator.fromPurchasesList(null));
  }

  @Test
  public void fromPurchasesResult() throws JSONException {
    PurchasesResult result = mock(PurchasesResult.class);
    final String purchase2Json =
        "{\"orderId\":\"foo2\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\"}";
    final String signature = "signature";
    final List<Purchase> expectedPurchases =
        Arrays.asList(
            new Purchase(PURCHASE_EXAMPLE_JSON, signature), new Purchase(purchase2Json, signature));
    when(result.getPurchasesList()).thenReturn(expectedPurchases);
    when(result.getResponseCode()).thenReturn(BillingResponse.OK);

    final HashMap<String, Object> serialized = Translator.fromPurchasesResult(result);

    assertEquals(BillingResponse.OK, serialized.get("responseCode"));
    List<Map<String, Object>> serializedPurchases =
        (List<Map<String, Object>>) serialized.get("purchasesList");
    assertEquals(expectedPurchases.size(), serializedPurchases.size());
    assertSerialized(expectedPurchases.get(0), serializedPurchases.get(0));
    assertSerialized(expectedPurchases.get(1), serializedPurchases.get(1));
  }

  @Test
  public void fromPurchasesResult_null() throws JSONException {
    PurchasesResult result = mock(PurchasesResult.class);
    when(result.getResponseCode()).thenReturn(BillingResponse.ERROR);

    final HashMap<String, Object> serialized = Translator.fromPurchasesResult(result);

    assertEquals(BillingResponse.ERROR, serialized.get("responseCode"));
    assertEquals(Collections.emptyList(), serialized.get("purchasesList"));
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

  private void assertSerialized(Purchase expected, Map<String, Object> serialized) {
    assertEquals(expected.getOrderId(), serialized.get("orderId"));
    assertEquals(expected.getPackageName(), serialized.get("packageName"));
    assertEquals(expected.getPurchaseTime(), serialized.get("purchaseTime"));
    assertEquals(expected.getPurchaseToken(), serialized.get("purchaseToken"));
    assertEquals(expected.getSignature(), serialized.get("signature"));
    assertEquals(expected.getOriginalJson(), serialized.get("originalJson"));
    assertEquals(expected.getSku(), serialized.get("sku"));
  }
}
