// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:test/test.dart';

const PurchaseWrapper dummyPurchase = PurchaseWrapper(
  orderId: 'orderId',
  packageName: 'packageName',
  purchaseTime: 0,
  signature: 'signature',
  sku: 'sku',
  purchaseToken: 'purchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'dummy payload',
  isAcknowledged: true,
  purchaseState: PurchaseStateWrapper.purchased,
  obfuscatedAccountId: 'Account101',
  obfuscatedProfileId: 'Profile103',
);

const PurchaseWrapper dummyUnacknowledgedPurchase = PurchaseWrapper(
  orderId: 'orderId',
  packageName: 'packageName',
  purchaseTime: 0,
  signature: 'signature',
  sku: 'sku',
  purchaseToken: 'purchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'dummy payload',
  isAcknowledged: false,
  purchaseState: PurchaseStateWrapper.purchased,
);

const PurchaseHistoryRecordWrapper dummyPurchaseHistoryRecord =
    PurchaseHistoryRecordWrapper(
  purchaseTime: 0,
  signature: 'signature',
  sku: 'sku',
  purchaseToken: 'purchaseToken',
  originalJson: '',
  developerPayload: 'dummy payload',
);

const PurchaseWrapper dummyOldPurchase = PurchaseWrapper(
  orderId: 'oldOrderId',
  packageName: 'oldPackageName',
  purchaseTime: 0,
  signature: 'oldSignature',
  sku: 'oldSku',
  purchaseToken: 'oldPurchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'old dummy payload',
  isAcknowledged: true,
  purchaseState: PurchaseStateWrapper.purchased,
);

void main() {
  group('PurchaseWrapper', () {
    test('converts from map', () {
      const PurchaseWrapper expected = dummyPurchase;
      final PurchaseWrapper parsed =
          PurchaseWrapper.fromJson(buildPurchaseMap(expected));

      expect(parsed, equals(expected));
    });

    test('fromPurchase() should return correct PurchaseDetail object', () {
      final GooglePlayPurchaseDetails details =
          GooglePlayPurchaseDetails.fromPurchase(dummyPurchase);

      expect(details.purchaseID, dummyPurchase.orderId);
      expect(details.productID, dummyPurchase.sku);
      expect(details.transactionDate, dummyPurchase.purchaseTime.toString());
      expect(details.verificationData, isNotNull);
      expect(details.verificationData.source, kIAPSource);
      expect(details.verificationData.localVerificationData,
          dummyPurchase.originalJson);
      expect(details.verificationData.serverVerificationData,
          dummyPurchase.purchaseToken);
      expect(details.billingClientPurchase, dummyPurchase);
      expect(details.pendingCompletePurchase, false);
    });

    test(
        'fromPurchase() should return set pendingCompletePurchase to true for unacknowledged purchase',
        () {
      final GooglePlayPurchaseDetails details =
          GooglePlayPurchaseDetails.fromPurchase(dummyUnacknowledgedPurchase);

      expect(details.purchaseID, dummyPurchase.orderId);
      expect(details.productID, dummyPurchase.sku);
      expect(details.transactionDate, dummyPurchase.purchaseTime.toString());
      expect(details.verificationData, isNotNull);
      expect(details.verificationData.source, kIAPSource);
      expect(details.verificationData.localVerificationData,
          dummyPurchase.originalJson);
      expect(details.verificationData.serverVerificationData,
          dummyPurchase.purchaseToken);
      expect(details.billingClientPurchase, dummyUnacknowledgedPurchase);
      expect(details.pendingCompletePurchase, true);
    });
  });

  group('PurchaseHistoryRecordWrapper', () {
    test('converts from map', () {
      const PurchaseHistoryRecordWrapper expected = dummyPurchaseHistoryRecord;
      final PurchaseHistoryRecordWrapper parsed =
          PurchaseHistoryRecordWrapper.fromJson(
              buildPurchaseHistoryRecordMap(expected));

      expect(parsed, equals(expected));
    });
  });

  group('PurchasesResultWrapper', () {
    test('parsed from map', () {
      const BillingResponse responseCode = BillingResponse.ok;
      final List<PurchaseWrapper> purchases = <PurchaseWrapper>[
        dummyPurchase,
        dummyPurchase
      ];
      const String debugMessage = 'dummy Message';
      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      final PurchasesResultWrapper expected = PurchasesResultWrapper(
          billingResult: billingResult,
          responseCode: responseCode,
          purchasesList: purchases);
      final PurchasesResultWrapper parsed =
          PurchasesResultWrapper.fromJson(<String, dynamic>{
        'billingResult': buildBillingResultMap(billingResult),
        'responseCode': const BillingResponseConverter().toJson(responseCode),
        'purchasesList': <Map<String, dynamic>>[
          buildPurchaseMap(dummyPurchase),
          buildPurchaseMap(dummyPurchase)
        ]
      });
      expect(parsed.billingResult, equals(expected.billingResult));
      expect(parsed.responseCode, equals(expected.responseCode));
      expect(parsed.purchasesList, containsAll(expected.purchasesList));
    });

    test('parsed from empty map', () {
      final PurchasesResultWrapper parsed =
          PurchasesResultWrapper.fromJson(const <String, dynamic>{});
      expect(
          parsed.billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
      expect(parsed.responseCode, BillingResponse.error);
      expect(parsed.purchasesList, isEmpty);
    });
  });

  group('PurchasesHistoryResult', () {
    test('parsed from map', () {
      const BillingResponse responseCode = BillingResponse.ok;
      final List<PurchaseHistoryRecordWrapper> purchaseHistoryRecordList =
          <PurchaseHistoryRecordWrapper>[
        dummyPurchaseHistoryRecord,
        dummyPurchaseHistoryRecord
      ];
      const String debugMessage = 'dummy Message';
      const BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      final PurchasesHistoryResult expected = PurchasesHistoryResult(
          billingResult: billingResult,
          purchaseHistoryRecordList: purchaseHistoryRecordList);
      final PurchasesHistoryResult parsed =
          PurchasesHistoryResult.fromJson(<String, dynamic>{
        'billingResult': buildBillingResultMap(billingResult),
        'purchaseHistoryRecordList': <Map<String, dynamic>>[
          buildPurchaseHistoryRecordMap(dummyPurchaseHistoryRecord),
          buildPurchaseHistoryRecordMap(dummyPurchaseHistoryRecord)
        ]
      });
      expect(parsed.billingResult, equals(billingResult));
      expect(parsed.purchaseHistoryRecordList,
          containsAll(expected.purchaseHistoryRecordList));
    });

    test('parsed from empty map', () {
      final PurchasesHistoryResult parsed =
          PurchasesHistoryResult.fromJson(const <String, dynamic>{});
      expect(
          parsed.billingResult,
          equals(const BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
      expect(parsed.purchaseHistoryRecordList, isEmpty);
    });
  });
}

Map<String, dynamic> buildPurchaseMap(PurchaseWrapper original) {
  return <String, dynamic>{
    'orderId': original.orderId,
    'packageName': original.packageName,
    'purchaseTime': original.purchaseTime,
    'signature': original.signature,
    'sku': original.sku,
    'purchaseToken': original.purchaseToken,
    'isAutoRenewing': original.isAutoRenewing,
    'originalJson': original.originalJson,
    'developerPayload': original.developerPayload,
    'purchaseState':
        const PurchaseStateConverter().toJson(original.purchaseState),
    'isAcknowledged': original.isAcknowledged,
    'obfuscatedAccountId': original.obfuscatedAccountId,
    'obfuscatedProfileId': original.obfuscatedProfileId,
  };
}

Map<String, dynamic> buildPurchaseHistoryRecordMap(
    PurchaseHistoryRecordWrapper original) {
  return <String, dynamic>{
    'purchaseTime': original.purchaseTime,
    'signature': original.signature,
    'sku': original.sku,
    'purchaseToken': original.purchaseToken,
    'originalJson': original.originalJson,
    'developerPayload': original.developerPayload,
  };
}

Map<String, dynamic> buildBillingResultMap(BillingResultWrapper original) {
  return <String, dynamic>{
    'responseCode':
        const BillingResponseConverter().toJson(original.responseCode),
    'debugMessage': original.debugMessage,
  };
}
