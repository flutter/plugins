// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/new/src/camera_testing.dart';
import 'package:camera/new/src/common/native_texture.dart';

void main() {
  group('Camera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      CameraTesting.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'NativeTexture#allocate':
            return 15;
        }

        throw ArgumentError.value(
          methodCall.method,
          'methodCall.method',
          'No method found for',
        );
      });
    });

    setUp(() {
      log.clear();
      CameraTesting.nextHandle = 0;
    });

    group('$NativeTexture', () {
      test('allocate', () async {
        final NativeTexture texture = await NativeTexture.allocate();

        expect(texture.textureId, 15);
        expect(log, <Matcher>[
          isMethodCall(
            '$NativeTexture#allocate',
            arguments: <String, dynamic>{'textureHandle': 0},
          )
        ]);
      });
    });
  });
}
