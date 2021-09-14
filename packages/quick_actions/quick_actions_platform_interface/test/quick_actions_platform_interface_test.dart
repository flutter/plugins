// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions_platform_interface/method_channel/method_channel_quick_actions.dart';
import 'package:quick_actions_platform_interface/platform_interface/quick_actions_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$QuickActionsPlatform', () {
    test('$MethodChannelQuickActions is the default instance', () {
      expect(QuickActionsPlatform.instance, isA<MethodChannelQuickActions>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        QuickActionsPlatform.instance = ImplementsQuickActionsPlatform();
      }, throwsNoSuchMethodError);
    });

    test('Can be extended', () {
      QuickActionsPlatform.instance = ExtendsQuickActionsPlatform();
    });

    test(
        'Default implementation of initialize() should throw unimplemented error',
        () {
      // Arrange
      final QuickActionsPlatform = ExtendsQuickActionsPlatform();

      // Act & Assert
      expect(
        () => QuickActionsPlatform.initialize((type) {}),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setShortcutItems() should throw unimplemented error',
        () {
      // Arrange
      final QuickActionsPlatform = ExtendsQuickActionsPlatform();

      // Act & Assert
      expect(
        () => QuickActionsPlatform.setShortcutItems([]),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of clearShortcutItems() should throw unimplemented error',
        () {
      // Arrange
      final QuickActionsPlatform = ExtendsQuickActionsPlatform();

      // Act & Assert
      expect(
        () => QuickActionsPlatform.clearShortcutItems(),
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
