// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions/quick_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  QuickActions quickActions;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    quickActions = QuickActions();
    quickActions.channel.setMockMethodCallHandler(
      (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      },
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
    expect(
      log,
      <Matcher>[
        isMethodCall(
          'setShortcutItems',
          arguments: <Map<String, String>>[
            <String, String>{
              'type': type,
              'localizedTitle': localizedTitle,
              'icon': icon,
            }
          ],
        ),
      ],
    );
    log.clear();
  });

  test('clearShortcutItems', () {
    quickActions.clearShortcutItems();
    expect(
      log,
      <Matcher>[
        isMethodCall('clearShortcutItems', arguments: null),
      ],
    );
    log.clear();
  });

  test('runLaunchAction', () {
    quickActions.runLaunchAction(null);
    expect(
      log,
      <Matcher>[
        isMethodCall('getLaunchAction', arguments: null),
      ],
    );
    log.clear();
  });
}
