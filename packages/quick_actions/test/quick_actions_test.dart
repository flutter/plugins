// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

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
        return 'non empty response';
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

  test('initialize', () async {
    final Completer<bool> quickActionsHandler = Completer<bool>();
    quickActions.initialize((_) => quickActionsHandler.complete(true));
    expect(
      log,
      <Matcher>[
        isMethodCall('getLaunchAction', arguments: null),
      ],
    );
    log.clear();

    expect(quickActionsHandler.future, completion(isTrue));
  });

  test('Shortcut item can be constructed', () {
    const String type = 'type';
    const String localizedTitle = 'title';
    const String icon = 'foo';

    const ShortcutItem item =
        ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon);

    expect(item.type, type);
    expect(item.localizedTitle, localizedTitle);
    expect(item.icon, icon);
  });
}
