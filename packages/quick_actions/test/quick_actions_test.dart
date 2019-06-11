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
    verify(mockChannel.invokeMethod<void>(
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
    verify(mockChannel.invokeMethod<void>('clearShortcutItems'));
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
