// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:android_intent/flag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_intent/android_intent.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';

void main() {
  AndroidIntent androidIntent;
  MockMethodChannel mockChannel;
  setUp(() {
    mockChannel = MockMethodChannel();
  });
  group('AndroidIntent', () {
    test('pass right params', () async {
      androidIntent = AndroidIntent.private(
          action: 'action_view',
          data: Uri.encodeFull('https://flutter.io'),
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'));
      androidIntent.launch();
      verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
        'action': 'action_view',
        'data': Uri.encodeFull('https://flutter.io'),
        'flags': androidIntent.convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
      }));
    });
    test('pass null value to action param', () async {
      androidIntent = AndroidIntent.private(
          action: null,
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'));
      androidIntent.launch();
      verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
        'action': null,
      }));
    });

    test('call in ios platform', () async {
      androidIntent = AndroidIntent.private(
          action: null,
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'ios'));
      androidIntent.launch();
      verifyZeroInteractions(mockChannel);
    });
  });
  group('convertFlags ', () {
    androidIntent = const AndroidIntent(
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

class MockMethodChannel extends Mock implements MethodChannel {}
