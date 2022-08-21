// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$InAppPurchasePlatform', () {
    test('Cannot be implemented with `implements`', () {
      expect(() {
        InAppPurchasePlatform.instance = ImplementsInAppPurchasePlatform();
        // In versions of `package:plugin_platform_interface` prior to fixing
        // https://github.com/flutter/flutter/issues/109339, an attempt to
        // implement a platform interface using `implements` would sometimes
        // throw a `NoSuchMethodError` and other times throw an
        // `AssertionError`.  After the issue is fixed, an `AssertionError` will
        // always be thrown.  For the purpose of this test, we don't really care
        // what exception is thrown, so just allow any exception.
      }, throwsA(anything));
    });

    test('Can be extended', () {
      InAppPurchasePlatform.instance = ExtendsInAppPurchasePlatform();
    });

    test('Can be mocked with `implements`', () {
      InAppPurchasePlatform.instance = MockInAppPurchasePlatform();
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of purchaseStream should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.purchaseStream,
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
        'Default implementation of completePurchase should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.completePurchase(MockPurchaseDetails()),
        throwsUnimplementedError,
      );
    });

    test(
        // ignore: lines_longer_than_80_chars
        'Default implementation of restorePurchases should throw unimplemented error',
        () {
      final ExtendsInAppPurchasePlatform inAppPurchasePlatform =
          ExtendsInAppPurchasePlatform();

      expect(
        () => inAppPurchasePlatform.restorePurchases(),
        throwsUnimplementedError,
      );
    });
  });

  group('$InAppPurchasePlatformAddition', () {
    setUp(() {
      InAppPurchasePlatformAddition.instance = null;
    });

    test('Default instance is null', () {
      expect(InAppPurchasePlatformAddition.instance, isNull);
    });

    test('Can be implemented.', () {
      InAppPurchasePlatformAddition.instance =
          ImplementsInAppPurchasePlatformAddition();
    });

    test('InAppPurchasePlatformAddition Can be extended', () {
      InAppPurchasePlatformAddition.instance =
          ExtendsInAppPurchasePlatformAddition();
    });

    test('Can not be a `InAppPurchasePlatform`', () {
      expect(
          () => InAppPurchasePlatformAddition.instance =
              ExtendsInAppPurchasePlatformAdditionIsPlatformInterface(),
          throwsAssertionError);
    });

    test('Provider can provide', () {
      ImplementsInAppPurchasePlatformAdditionProvider.register();
      final ImplementsInAppPurchasePlatformAdditionProvider provider =
          ImplementsInAppPurchasePlatformAdditionProvider();
      final InAppPurchasePlatformAddition? addition =
          provider.getPlatformAddition();
      expect(addition.runtimeType, ExtendsInAppPurchasePlatformAddition);
    });

    test('Provider can provide `null`', () {
      final ImplementsInAppPurchasePlatformAdditionProvider provider =
          ImplementsInAppPurchasePlatformAdditionProvider();
      final InAppPurchasePlatformAddition? addition =
          provider.getPlatformAddition();
      expect(addition, isNull);
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

class MockPurchaseDetails extends Mock implements PurchaseDetails {}

class ImplementsInAppPurchasePlatformAddition
    implements InAppPurchasePlatformAddition {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsInAppPurchasePlatformAddition
    extends InAppPurchasePlatformAddition {}

class ImplementsInAppPurchasePlatformAdditionProvider
    implements InAppPurchasePlatformAdditionProvider {
  static void register() {
    InAppPurchasePlatformAddition.instance =
        ExtendsInAppPurchasePlatformAddition();
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    return InAppPurchasePlatformAddition.instance as T;
  }
}

class ExtendsInAppPurchasePlatformAdditionIsPlatformInterface
    extends InAppPurchasePlatform
    implements ExtendsInAppPurchasePlatformAddition {}
