// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_platform_interface/src/noop_in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$InAppPurchasePlatform', () {
    test('$NoopInAppPurchase is the default instance', () {
      expect(InAppPurchasePlatform.instance, isA<NoopInAppPurchase>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        InAppPurchasePlatform.instance = ImplementsInAppPurchasePlatform();
      }, throwsNoSuchMethodError);
    });

    test('Can be extended', () {
      InAppPurchasePlatform.instance = ExtendsInAppPurchasePlatform();
    });

    test('Can be mocked with `implements`', () {
      final MockInAppPurchasePlatform mock = MockInAppPurchasePlatform();
      InAppPurchasePlatform.instance = mock;
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of purchaseUpdatedStream should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.purchaseUpdatedStream,
        throwsUnimplementedError,
      );
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of isAvailable should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.isAvailable(),
        throwsUnimplementedError,
      );
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of queryProductDetails should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.queryProductDetails(<String>{''}),
        throwsUnimplementedError,
      );
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of buyNonConsumable should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.buyNonConsumable(
          purchaseParam: MockPurchaseParam(),
        ),
        throwsUnimplementedError,
      );
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of buyConsumable should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.buyConsumable(
          purchaseParam: MockPurchaseParam(),
        ),
        throwsUnimplementedError,
      );
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of queryPastPurchases should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.queryPastPurchases(),
        throwsUnimplementedError,
      );
    });
  });
}

class ImplementsInAppPurchasePlatform implements InAppPurchasePlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockInAppPurchasePlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        InAppPurchasePlatform {}

class ExtendsInAppPurchasePlatform extends InAppPurchasePlatform {}

class MockPurchaseParam extends Mock implements PurchaseParam {}
