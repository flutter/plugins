// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_platform_images/ios_platform_images.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/ios_platform_images');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('resolveURL', () async {
    expect(await IosPlatformImages.resolveURL('foobar'), '42');
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
