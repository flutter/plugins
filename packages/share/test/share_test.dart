// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share/share.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required for MethodChannels

  late FakeMethodChannel fakeChannel;

  setUp(() {
    fakeChannel = FakeMethodChannel();
    // Re-pipe to our fake to verify invocations.
    Share.channel.setMockMethodCallHandler((MethodCall call) async {
      // The explicit type can be void as the only method call has a return type of void.
      await fakeChannel.invokeMethod<void>(call.method, call.arguments);
    });
  });

  test('sharing empty fails', () {
    expect(
      () => Share.share(''),
      throwsA(isA<AssertionError>()),
    );
    expect(fakeChannel.invocation, isNull);
  });

  test('sharing origin sets the right params', () async {
    await Share.share(
      'some text to share',
      subject: 'some subject to share',
      sharePositionOrigin: const Rect.fromLTWH(1.0, 2.0, 3.0, 4.0),
    );

    expect(
      fakeChannel.invocation,
      equals({
        'share': {
          'text': 'some text to share',
          'subject': 'some subject to share',
          'originX': 1.0,
          'originY': 2.0,
          'originWidth': 3.0,
          'originHeight': 4.0,
        }
      }),
    );
  });

  test('sharing empty file fails', () {
    expect(
      () => Share.shareFiles(['']),
      throwsA(isA<AssertionError>()),
    );
    expect(fakeChannel.invocation, isNull);
  });

  test('sharing file sets correct mimeType', () async {
    final String path = 'tempfile-83649a.png';
    final File file = File(path);
    try {
      file.createSync();

      await Share.shareFiles([path]);

      expect(
        fakeChannel.invocation,
        equals({
          'shareFiles': {
            'paths': [path],
            'mimeTypes': ['image/png'],
          }
        }),
      );
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

      expect(
        fakeChannel.invocation,
        equals({
          'shareFiles': {
            'paths': [file.path],
            'mimeTypes': ['*/*'],
          }
        }),
      );
    } finally {
      file.deleteSync();
    }
  });
}

class FakeMethodChannel extends Fake implements MethodChannel {
  Map<String, dynamic>? invocation;

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    this.invocation = {method: arguments};
    return null;
  }
}
