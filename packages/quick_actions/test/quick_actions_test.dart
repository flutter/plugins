// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:test/test.dart';

void main() {
  MockMethodChannel mockChannel;
  QuickActions quickActions;

  setUp(() {
    mockChannel = MockMethodChannel();
    quickActions = QuickActions.private(
      mockChannel,
    );
  });

  test('setShortcutItems with demo data', () async {
    const String type = 'type';
    const String localizedTitle = 'localizedTitle';
    const String icon = 'icon';
    await quickActions.setShortcutItems(
      const <ShortcutItem>[
        ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon)
      ],
    );
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    verify(mockChannel.invokeMethod(
      'setShortcutItems',
      <Map<String, String>>[
        <String, String>{
          'type': type,
          'localizedTitle': localizedTitle,
          'icon': icon,
        }
      ],
    ));
  });

  test('initialize', () {
    quickActions.initialize((_) {});
    verify(mockChannel.setMethodCallHandler(any));
  });

  test('clearShortcutItems', () {
    quickActions.clearShortcutItems();
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    verify(mockChannel.invokeMethod('clearShortcutItems'));
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
