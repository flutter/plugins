// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:android_intent/flag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_intent/android_intent.dart';

void main() {
  AndroidIntent androidIntent;
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/android_intent');
  final List<MethodCall> log = <MethodCall>[];
  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return '';
    });
    log.clear();
  });
  group('AndroidIntent', () {
    test('pass right params', () async {
      if (Platform.isIOS) {
      } else if (Platform.isAndroid) {
        androidIntent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull('https://flutter.io'),
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        androidIntent.launch();
        expect(
          log,
          <Matcher>[
            isMethodCall('launch', arguments: <String, Object>{
              'action': 'action_view',
              'data': Uri.encodeFull('https://flutter.io'),
              'flags': androidIntent
                  .convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
            })
          ],
        );
      }
    });
    test('pass wrong params', () async {
      if (Platform.isIOS) {
      } else if (Platform.isAndroid) {
        androidIntent = AndroidIntent(
          action: null,
        );
        androidIntent.launch();
        expect(
          log,
          <Matcher>[
            isMethodCall('launch', arguments: <String, Object>{
              'action': null,
            })
          ],
        );
      }
    });
  });
  group('Flags: ', () {
    androidIntent = AndroidIntent(
      action: 'action_view',
    );
    test('add filled flag list', () async {
      final List<int> flags = <int>[];
      flags.add(Flag.FLAG_ACTIVITY_NEW_TASK);
      flags.add(Flag.FLAG_ACTIVITY_NEW_DOCUMENT);
      expect(
        androidIntent.convertFlags(flags),
        268959744,
      );
    });
    test('add flags whose values are not power of 2', () async {
      final List<int> flags = <int>[];
      flags.add(100);
      flags.add(10);
      expect(
        () => androidIntent.convertFlags(flags),
        throwsArgumentError,
      );
    });
    test('add empty flag list', () async {
      final List<int> flags = <int>[];
      expect(
        androidIntent.convertFlags(flags),
        0,
      );
    });
  });
}
