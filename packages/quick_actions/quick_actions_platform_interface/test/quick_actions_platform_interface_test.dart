// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions_platform_interface/method_channel/method_channel_quick_actions.dart';
import 'package:quick_actions_platform_interface/platform_interface/quick_actions_platform.dart';
import 'package:quick_actions_platform_interface/types/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Store the initial instance before any tests change it.
  final QuickActionsPlatform initialInstance = QuickActionsPlatform.instance;

  group('$QuickActionsPlatform', () {
    test('$MethodChannelQuickActions is the default instance', () {
      expect(initialInstance, isA<MethodChannelQuickActions>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        QuickActionsPlatform.instance = ImplementsQuickActionsPlatform();
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
      QuickActionsPlatform.instance = ExtendsQuickActionsPlatform();
    });

    test(
        'Default implementation of initialize() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsQuickActionsPlatform quickActionsPlatform =
          ExtendsQuickActionsPlatform();

      // Act & Assert
      expect(
        () => quickActionsPlatform.initialize((String type) {}),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setShortcutItems() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsQuickActionsPlatform quickActionsPlatform =
          ExtendsQuickActionsPlatform();

      // Act & Assert
      expect(
        () => quickActionsPlatform.setShortcutItems(<ShortcutItem>[]),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of clearShortcutItems() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsQuickActionsPlatform quickActionsPlatform =
          ExtendsQuickActionsPlatform();

      // Act & Assert
      expect(
        () => quickActionsPlatform.clearShortcutItems(),
        throwsUnimplementedError,
      );
    });
  });
}

class ImplementsQuickActionsPlatform implements QuickActionsPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsQuickActionsPlatform extends QuickActionsPlatform {}
