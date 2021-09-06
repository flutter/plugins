// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_ios/store_kit_wrappers.dart';

final dummyPayment = SKPaymentWrapper(
    productIdentifier: 'prod-id',
    applicationUsername: 'app-user-name',
    requestData: 'fake-data-utf8',
    quantity: 2,
    simulatesAskToBuyInSandbox: true);
final SKError dummyError =
    SKError(code: 111, domain: 'dummy-domain', userInfo: {'key': 'value'});

final SKPaymentTransactionWrapper dummyOriginalTransaction =
    SKPaymentTransactionWrapper(
  transactionState: SKPaymentTransactionStateWrapper.purchased,
  payment: dummyPayment,
  originalTransaction: null,
  transactionTimeStamp: 1231231231.00,
  transactionIdentifier: '123123',
  error: dummyError,
);

final SKPaymentTransactionWrapper dummyTransaction =
    SKPaymentTransactionWrapper(
  transactionState: SKPaymentTransactionStateWrapper.purchased,
  payment: dummyPayment,
  originalTransaction: dummyOriginalTransaction,
  transactionTimeStamp: 1231231231.00,
  transactionIdentifier: '123123',
  error: dummyError,
);

final SKPriceLocaleWrapper dollarLocale = SKPriceLocaleWrapper(
  currencySymbol: '\$',
  currencyCode: 'USD',
  countryCode: 'US',
);

final SKPriceLocaleWrapper noSymbolLocale = SKPriceLocaleWrapper(
  currencySymbol: '',
  currencyCode: 'EUR',
  countryCode: 'UK',
);

final SKProductSubscriptionPeriodWrapper dummySubscription =
    SKProductSubscriptionPeriodWrapper(
  numberOfUnits: 1,
  unit: SKSubscriptionPeriodUnit.month,
);

final SKProductDiscountWrapper dummyDiscount = SKProductDiscountWrapper(
  price: '1.0',
  priceLocale: dollarLocale,
  numberOfPeriods: 1,
  paymentMode: SKProductDiscountPaymentMode.payUpFront,
  subscriptionPeriod: dummySubscription,
);

final SKProductWrapper dummyProductWrapper = SKProductWrapper(
  productIdentifier: 'id',
  localizedTitle: 'title',
  localizedDescription: 'description',
  priceLocale: dollarLocale,
  subscriptionGroupIdentifier: 'com.group',
  price: '1.0',
  subscriptionPeriod: dummySubscription,
  introductoryPrice: dummyDiscount,
);

final SkProductResponseWrapper dummyProductResponseWrapper =
    SkProductResponseWrapper(
  products: [dummyProductWrapper],
  invalidProductIdentifiers: <String>['123'],
);

Map<String, dynamic> buildLocaleMap(SKPriceLocaleWrapper local) {
  return {
    'currencySymbol': local.currencySymbol,
    'currencyCode': local.currencyCode,
    'countryCode': local.countryCode,
  };
}

Map<String, dynamic>? buildSubscriptionPeriodMap(
    SKProductSubscriptionPeriodWrapper? sub) {
  if (sub == null) {
    return null;
  }
  return {
    'numberOfUnits': sub.numberOfUnits,
    'unit': SKSubscriptionPeriodUnit.values.indexOf(sub.unit),
  };
}

Map<String, dynamic> buildDiscountMap(SKProductDiscountWrapper discount) {
  return {
    'price': discount.price,
    'priceLocale': buildLocaleMap(discount.priceLocale),
    'numberOfPeriods': discount.numberOfPeriods,
    'paymentMode':
        SKProductDiscountPaymentMode.values.indexOf(discount.paymentMode),
    'subscriptionPeriod':
        buildSubscriptionPeriodMap(discount.subscriptionPeriod),
  };
}

Map<String, dynamic> buildProductMap(SKProductWrapper product) {
  return {
    'productIdentifier': product.productIdentifier,
    'localizedTitle': product.localizedTitle,
    'localizedDescription': product.localizedDescription,
    'priceLocale': buildLocaleMap(product.priceLocale),
    'subscriptionGroupIdentifier': product.subscriptionGroupIdentifier,
    'price': product.price,
    'subscriptionPeriod':
        buildSubscriptionPeriodMap(product.subscriptionPeriod),
    'introductoryPrice': buildDiscountMap(product.introductoryPrice!),
  };
}

Map<String, dynamic> buildProductResponseMap(
    SkProductResponseWrapper response) {
  List productsMap = response.products
      .map((SKProductWrapper product) => buildProductMap(product))
      .toList();
  return {
    'products': productsMap,
    'invalidProductIdentifiers': response.invalidProductIdentifiers
  };
}

Map<String, dynamic> buildErrorMap(SKError error) {
  return {
    'code': error.code,
    'domain': error.domain,
    'userInfo': error.userInfo,
  };
}

Map<String, dynamic> buildTransactionMap(
    SKPaymentTransactionWrapper transaction) {
  Map<String, dynamic> map = <String, dynamic>{
    'transactionState': SKPaymentTransactionStateWrapper.values
        .indexOf(SKPaymentTransactionStateWrapper.purchased),
    'payment': transaction.payment.toMap(),
    'originalTransaction': transaction.originalTransaction == null
        ? null
        : buildTransactionMap(transaction.originalTransaction!),
    'transactionTimeStamp': transaction.transactionTimeStamp,
    'transactionIdentifier': transaction.transactionIdentifier,
    'error': buildErrorMap(transaction.error!),
  };
  return map;
}
