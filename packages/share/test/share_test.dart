// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:mockito/mockito.dart';
import 'package:share/share.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

void main() {
  MockMethodChannel mockChannel;

  setUp(() {
    mockChannel = MockMethodChannel();
    // Re-pipe to mockito for easier verifies.
    Share.channel.setMockMethodCallHandler((MethodCall call) async {
      mockChannel.invokeMethod(call.method, call.arguments);
    });
  });

  test('sharing null fails', () {
    expect(
      () => Share.share(null),
      throwsA(const TypeMatcher<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing empty fails', () {
    expect(
      () => Share.share(''),
      throwsA(const TypeMatcher<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing origin sets the right params', () async {
    await Share.share(
      'some text to share',
      sharePositionOrigin: Rect.fromLTWH(1.0, 2.0, 3.0, 4.0),
    );
    verify(mockChannel.invokeMethod('share', <String, dynamic>{
      'text': 'some text to share',
      'originX': 1.0,
      'originY': 2.0,
      'originWidth': 3.0,
      'originHeight': 4.0,
    }));
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
