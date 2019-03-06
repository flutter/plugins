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

  final Map<String, dynamic> localeMap = <String, dynamic>{
    'currencySymbol': '\$'
  };
  final Map<String, dynamic> subMap = <String, dynamic>{
    'numberOfUnits': 1,
    'unit': 2
  };
  final Map<String, dynamic> discountMap = <String, dynamic>{
    'price': '1.0',
    'priceLocale': localeMap,
    'numberOfPeriods': 1,
    'paymentMode': 2,
    'subscriptionPeriod': subMap,
  };
  final Map<String, dynamic> productMap = <String, dynamic>{
    'productIdentifier': 'id',
    'localizedTitle': 'title',
    'localizedDescription': 'description',
    'priceLocale': localeMap,
    'downloadContentVersion': 'version',
    'subscriptionGroupIdentifier': 'com.group',
    'price': '1.0',
    'downloadable': true,
    'downloadContentLengths': <int>[1, 2],
    'subscriptionPeriod': subMap,
    'introductoryPrice': discountMap,
  };

  final Map<String, List<dynamic>> productResponseMap = <String, List<dynamic>>{
    'products': <Map<String, dynamic>>[productMap],
    'invalidProductIdentifiers': <String>['123'],
  };