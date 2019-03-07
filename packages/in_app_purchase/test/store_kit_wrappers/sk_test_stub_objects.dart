// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase/store_kit_wrappers.dart';

final dummyPayment = SKPaymentWrapper(
    productIdentifier: 'prod-id',
    applicationUsername: 'app-user-name',
    requestData: 'fake-data-utf8',
    quantity: 2,
    simulatesAskToBuyInSandbox: true);
final SKError dummyError =
    SKError(code: 111, domain: 'dummy-domain', userInfo: {'key': 'value'});
final SKDownloadWrapper dummyDownload = SKDownloadWrapper(
  contentIdentifier: 'id',
  state: SKDownloadState.failed,
  contentLength: 32,
  contentURL: 'https://download.com',
  contentVersion: '0.0.1',
  transactionID: 'tranID',
  progress: 0.6,
  timeRemaining: 1231231,
  downloadTimeUnknown: false,
  error: dummyError,
);
final SKPaymentTransactionWrapper dummyOriginalTransaction =
    SKPaymentTransactionWrapper(
  transactionState: SKPaymentTransactionStateWrapper.purchased,
  payment: dummyPayment,
  originalTransaction: null,
  transactionTimeStamp: 1231231231.00,
  transactionIdentifier: '123123',
  downloads: [dummyDownload],
  error: dummyError,
);
final SKPaymentTransactionWrapper dummyTransaction =
    SKPaymentTransactionWrapper(
  transactionState: SKPaymentTransactionStateWrapper.purchased,
  payment: dummyPayment,
  originalTransaction: dummyOriginalTransaction,
  transactionTimeStamp: 1231231231.00,
  transactionIdentifier: '123123',
  downloads: [dummyDownload],
  error: dummyError,
);

final PriceLocaleWrapper dummyLocale = PriceLocaleWrapper(currencySymbol: '\$');

final SKProductSubscriptionPeriodWrapper dummySubscription =
    SKProductSubscriptionPeriodWrapper(
  numberOfUnits: 1,
  unit: SubscriptionPeriodUnit.month,
);

final SKProductDiscountWrapper dummyDiscount = SKProductDiscountWrapper(
  price: '1.0',
  priceLocale: dummyLocale,
  numberOfPeriods: 1,
  paymentMode: ProductDiscountPaymentMode.payUpFront,
  subscriptionPeriod: dummySubscription,
);

final SKProductWrapper dummyProductWrapper = SKProductWrapper(
  productIdentifier: 'id',
  localizedTitle: 'title',
  localizedDescription: 'description',
  priceLocale: dummyLocale,
  downloadContentVersion: 'version',
  subscriptionGroupIdentifier: 'com.group',
  price: '1.0',
  downloadable: true,
  downloadContentLengths: <int>[1, 2],
  subscriptionPeriod: dummySubscription,
  introductoryPrice: dummyDiscount,
);

final SkProductResponseWrapper dummyProductResponseWrapper =
    SkProductResponseWrapper(
  products: [dummyProductWrapper],
  invalidProductIdentifiers: <String>['123'],
);

Map<String, dynamic> buildLocaleMap(PriceLocaleWrapper local) {
  return {'currencySymbol': local.currencySymbol};
}

Map<String, dynamic> buildSubscriptionPeriodMap(
    SKProductSubscriptionPeriodWrapper sub) {
  return {
    'numberOfUnits': sub.numberOfUnits,
    'unit': SubscriptionPeriodUnit.values.indexOf(sub.unit),
  };
}

Map<String, dynamic> buildDiscountMap(SKProductDiscountWrapper discount) {
  return {
    'price': discount.price,
    'priceLocale': buildLocaleMap(discount.priceLocale),
    'numberOfPeriods': discount.numberOfPeriods,
    'paymentMode':
        ProductDiscountPaymentMode.values.indexOf(discount.paymentMode),
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
    'downloadContentVersion': product.downloadContentVersion,
    'subscriptionGroupIdentifier': product.subscriptionGroupIdentifier,
    'price': product.price,
    'downloadable': product.downloadable,
    'downloadContentLengths': product.downloadContentLengths,
    'subscriptionPeriod':
        buildSubscriptionPeriodMap(product.subscriptionPeriod),
    'introductoryPrice': buildDiscountMap(product.introductoryPrice),
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

Map<String, dynamic> buildDownloadMap(SKDownloadWrapper download) {
  return {
    'contentIdentifier': download.contentIdentifier,
    'state': SKDownloadState.values.indexOf(download.state),
    'contentLength': download.contentLength,
    'contentURL': download.contentURL,
    'contentVersion': download.contentVersion,
    'transactionID': download.transactionID,
    'progress': download.progress,
    'timeRemaining': download.timeRemaining,
    'downloadTimeUnknown': download.downloadTimeUnknown,
    'error': buildErrorMap(download.error)
  };
}

Map<String, dynamic> buildTransactionMap(
    SKPaymentTransactionWrapper transaction) {
  if (transaction == null) {
    return null;
  }
  Map map = <String, dynamic>{
    'transactionState': SKPaymentTransactionStateWrapper.values
        .indexOf(SKPaymentTransactionStateWrapper.purchased),
    'payment': transaction.payment.toMap(),
    'originalTransaction': buildTransactionMap(transaction.originalTransaction),
    'transactionTimeStamp': transaction.transactionTimeStamp,
    'transactionIdentifier': transaction.transactionIdentifier,
    'error': buildErrorMap(transaction.error),
  };
  List downloadList = transaction.downloads.map((SKDownloadWrapper download) {
    return buildDownloadMap(download);
  }).toList();
  map['downloads'] = downloadList;
  return map;
}
