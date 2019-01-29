// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
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

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('canMakePayments', () {
    test('YES', () async {
      stubPlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isTrue);
    });

    test('NO', () async {
      stubPlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isFalse);
    });
  });

  group('Wrapper fromJson tests', () {
    test('Should construct correct SKPaymentWrapper from json', () {
      SKPaymentWrapper payment =
          SKPaymentWrapper.fromJson(buildPaymentMap(dummyPayment));
      testPayment(payment, dummyPayment);
    });
  });

  test('Should construct correct SKError from json', () {
    SKError error = SKError.fromJson(buildErrorMap(dummyError));
    testSKError(error, dummyError);
  });

  test('Should construct correct SKDownloadWrapper from json', () {
    SKDownloadWrapper download =
        SKDownloadWrapper.fromJson(buildDownloadMap(dummyDownload));
    testDownload(download, dummyDownload);
  });

  test('Should construct correct SKTransactionWrapper from json', () {
    SKPaymentTransactionWrapper transaction =
        SKPaymentTransactionWrapper.fromJson(
            buildTransactionMap(dummyTransaction));
    testTransaction(transaction, dummyTransaction);
    if (transaction.originalTransaction != null) {
      testTransaction(transaction.originalTransaction,
          dummyTransaction.originalTransaction);
    }
  });
}

Map<String, dynamic> buildPaymentMap(SKPaymentWrapper paymentWrapper) {
  return {
    'productIdentifier': paymentWrapper.productIdentifier,
    'applicationUsername': paymentWrapper.applicationUsername,
    'requestData': paymentWrapper.requestData,
    'quantity': paymentWrapper.quantity,
    'simulatesAskToBuyInSandbox': paymentWrapper.simulatesAskToBuyInSandbox
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
    'payment': buildPaymentMap(transaction.payment),
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

void testSKError(SKError error, SKError dummyError) {
  expect(error.code, dummyError.code);
  expect(error.domain, dummyError.domain);
  expect(error.userInfo, dummyError.userInfo);
}

void testDownload(SKDownloadWrapper download, SKDownloadWrapper dummyDownload) {
  expect(download.contentIdentifier, dummyDownload.contentIdentifier);
  expect(download.state, dummyDownload.state);
  expect(download.contentLength, dummyDownload.contentLength);
  expect(download.contentURL, dummyDownload.contentURL);
  expect(download.contentVersion, dummyDownload.contentVersion);
  expect(download.transactionID, dummyDownload.transactionID);
  expect(download.progress, dummyDownload.progress);
  expect(download.timeRemaining, dummyDownload.timeRemaining);
  expect(download.downloadTimeUnknown, dummyDownload.downloadTimeUnknown);
  expect(download.error.code, dummyDownload.error.code);
  expect(download.error.domain, dummyDownload.error.domain);
  expect(download.error.userInfo, dummyDownload.error.userInfo);
}

void testPayment(SKPaymentWrapper payment, SKPaymentWrapper dummyPayment) {
  expect(payment.productIdentifier, dummyPayment.productIdentifier);
  expect(payment.applicationUsername, dummyPayment.applicationUsername);
  expect(payment.requestData, dummyPayment.requestData);
  expect(payment.quantity, dummyPayment.quantity);
  expect(payment.simulatesAskToBuyInSandbox,
      dummyPayment.simulatesAskToBuyInSandbox);
}

void testTransaction(SKPaymentTransactionWrapper transaction,
    SKPaymentTransactionWrapper dummyTransaction) {
  // payment
  SKPaymentWrapper payment = transaction.payment;
  SKPaymentWrapper dummyPayment = dummyTransaction.payment;
  testPayment(payment, dummyPayment);
  //download
  SKDownloadWrapper download = transaction.downloads.first;
  SKDownloadWrapper dummyDownload = dummyTransaction.downloads.first;
  testDownload(download, dummyDownload);
  //error
  SKError error = transaction.error;
  SKError dummyError = dummyTransaction.error;
  testSKError(error, dummyError);

  expect(transaction.transactionState, dummyTransaction.transactionState);
  expect(
      transaction.transactionTimeStamp, dummyTransaction.transactionTimeStamp);
  expect(transaction.transactionIdentifier,
      dummyTransaction.transactionIdentifier);
}
