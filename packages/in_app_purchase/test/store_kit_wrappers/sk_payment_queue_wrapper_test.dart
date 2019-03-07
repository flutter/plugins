// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';
import 'sk_test_stub_objects.dart';

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
      SKPaymentWrapper payment =
          SKPaymentWrapper.fromJson(dummyPayment.toMap());
      expect(payment, equals(dummyPayment));
    });

    test('Should construct correct SKError from json', () {
      SKError error = SKError.fromJson(buildErrorMap(dummyError));
      expect(error, equals(dummyError));
    });

    test('Should construct correct SKDownloadWrapper from json', () {
      SKDownloadWrapper download =
          SKDownloadWrapper.fromJson(buildDownloadMap(dummyDownload));
      expect(download, equals(dummyDownload));
    });

    test('Should construct correct SKTransactionWrapper from json', () {
      SKPaymentTransactionWrapper transaction =
          SKPaymentTransactionWrapper.fromJson(
              buildTransactionMap(dummyTransaction));
      expect(transaction, equals(dummyTransaction));
    });

    test('Should generate correct map of the payment object', () {
      Map map = dummyPayment.toMap();
      expect(map['productIdentifier'], dummyPayment.productIdentifier);
      expect(map['applicationUsername'], dummyPayment.applicationUsername);

      expect(map['requestData'], dummyPayment.requestData);

      expect(map['quantity'], dummyPayment.quantity);

      expect(map['simulatesAskToBuyInSandbox'],
          dummyPayment.simulatesAskToBuyInSandbox);
    });
  });
}
