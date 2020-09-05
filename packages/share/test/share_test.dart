// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
import 'package:mockito/mockito.dart';
import 'package:share/share.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockMethodChannel mockChannel;

  setUp(() {
    mockChannel = MockMethodChannel();
    // Re-pipe to mockito for easier verifies.
    Share.channel.setMockMethodCallHandler((MethodCall call) async {
      // The explicit type can be void as the only method call has a return type of void.
      await mockChannel.invokeMethod<void>(call.method, call.arguments);
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
      subject: 'some subject to share',
      sharePositionOrigin: const Rect.fromLTWH(1.0, 2.0, 3.0, 4.0),
    );
    verify(mockChannel.invokeMethod<void>('share', <String, dynamic>{
      'text': 'some text to share',
      'subject': 'some subject to share',
      'originX': 1.0,
      'originY': 2.0,
      'originWidth': 3.0,
      'originHeight': 4.0,
    }));
  });

  test('sharing null file fails', () {
    expect(
      () => Share.shareFiles([null]),
      throwsA(const TypeMatcher<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing empty file fails', () {
    expect(
      () => Share.shareFiles(['']),
      throwsA(const TypeMatcher<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing file sets correct mimeType', () async {
    final String path = 'tempfile-83649a.png';
    final File file = File(path);
    try {
      file.createSync();
      await Share.shareFiles([path]);
      verify(mockChannel.invokeMethod('shareFiles', <String, dynamic>{
        'paths': [path],
        'mimeTypes': ['image/png'],
      }));
    } finally {
      file.deleteSync();
    }
  });

  test('sharing file sets passed mimeType', () async {
    final String path = 'tempfile-83649a.png';
    final File file = File(path);
    try {
      file.createSync();
      await Share.shareFiles([path], mimeTypes: ['*/*']);
      verify(mockChannel.invokeMethod('shareFiles', <String, dynamic>{
        'paths': [file.path],
        'mimeTypes': ['*/*'],
      }));
    } finally {
      file.deleteSync();
    }
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
