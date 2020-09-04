// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/billing_client_wrappers/enum_converters.dart';

void main() {
  group('BillingResponse', () {
    test('serviceTimeout', () {
      final BillingResponse parsed = BillingResponse.serviceTimeout;
      final BillingResponse expected = BillingResponseConverter().fromJson(-3);

      expect(parsed, equals(expected));
    });

    test('featureNotSupported', () {
      final BillingResponse parsed = BillingResponse.featureNotSupported;
      final BillingResponse expected = BillingResponseConverter().fromJson(-2);

      expect(parsed, equals(expected));
    });

    test('serviceDisconnected', () {
      final BillingResponse parsed = BillingResponse.serviceDisconnected;
      final BillingResponse expected = BillingResponseConverter().fromJson(-1);

      expect(parsed, equals(expected));
    });

    test('ok', () {
      final BillingResponse parsed = BillingResponse.ok;
      final BillingResponse expected = BillingResponseConverter().fromJson(0);

      expect(parsed, equals(expected));
    });

    test('userCanceled', () {
      final BillingResponse parsed = BillingResponse.userCanceled;
      final BillingResponse expected = BillingResponseConverter().fromJson(1);

      expect(parsed, equals(expected));
    });

    test('serviceUnavailable', () {
      final BillingResponse parsed = BillingResponse.serviceUnavailable;
      final BillingResponse expected = BillingResponseConverter().fromJson(2);

      expect(parsed, equals(expected));
    });

    test('billingUnavailable', () {
      final BillingResponse parsed = BillingResponse.billingUnavailable;
      final BillingResponse expected = BillingResponseConverter().fromJson(3);

      expect(parsed, equals(expected));
    });

    test('itemUnavailable', () {
      final BillingResponse parsed = BillingResponse.itemUnavailable;
      final BillingResponse expected = BillingResponseConverter().fromJson(4);

      expect(parsed, equals(expected));
    });

    test('developerError', () {
      final BillingResponse parsed = BillingResponse.developerError;
      final BillingResponse expected = BillingResponseConverter().fromJson(5);

      expect(parsed, equals(expected));
    });

    test('error', () {
      final BillingResponse parsed = BillingResponse.error;
      final BillingResponse expected = BillingResponseConverter().fromJson(6);

      expect(parsed, equals(expected));
    });

    test('itemAlreadyOwned', () {
      final BillingResponse parsed = BillingResponse.itemAlreadyOwned;
      final BillingResponse expected = BillingResponseConverter().fromJson(7);

      expect(parsed, equals(expected));
    });

    test('itemNotOwned', () {
      final BillingResponse parsed = BillingResponse.itemNotOwned;
      final BillingResponse expected = BillingResponseConverter().fromJson(8);

      expect(parsed, equals(expected));
    });
  });
}
