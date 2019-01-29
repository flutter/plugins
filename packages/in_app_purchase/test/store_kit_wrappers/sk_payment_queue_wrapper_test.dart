// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

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
      SKPaymentWrapper dummyPaymentWrapper = SKPaymentWrapper(
          productIdentifier: 'prod-id',
          applicationUsername: 'app-user-name',
          requestData: 'fake-data-utf8',
          quantity: 2,
          simulatesAskToBuyInSandbox: true);
      SKPaymentWrapper paymentWrapper =
          SKPaymentWrapper.fromJson(buildPaymentMap(dummyPaymentWrapper));
      expect(paymentWrapper.productIdentifier,
          dummyPaymentWrapper.productIdentifier);
      expect(paymentWrapper.applicationUsername,
          dummyPaymentWrapper.applicationUsername);
      expect(paymentWrapper.requestData, dummyPaymentWrapper.requestData);
      expect(paymentWrapper.quantity, dummyPaymentWrapper.quantity);
      expect(paymentWrapper.simulatesAskToBuyInSandbox,
          dummyPaymentWrapper.simulatesAskToBuyInSandbox);
    });
  });

  test('Should construct correct SKError from json', () {
    SKError dummyError =
        SKError(code: 111, domain: 'dummy-domain', userInfo: {'key': 'value'});
    SKError error = SKError.fromJson(buildErrorMap(dummyError));
    expect(error.code, dummyError.code);
    expect(error.domain, dummyError.domain);
    expect(error.userInfo, dummyError.userInfo);
  });

  test('Should construct correct SKDownloadWrapper from json', () {
    SKDownloadWrapper dummyDownload = SKDownloadWrapper(
        contentIdentifier: 'id',
        state: SKDownloadState.failed,
        contentLength: 32,
        contentURL: 'https://download.com',
        contentVersion: '0.0.1',
        transactionID: 'tranID',
        progress: 0.6,
        timeRemaining: 1231231,
        downloadTimeUnknown: false,
        error: SKError(
            code: 111, domain: 'dummy-domain', userInfo: {'key': 'value'}));
    SKDownloadWrapper download =
        SKDownloadWrapper.fromJson(buildDownloadMap(dummyDownload));
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
