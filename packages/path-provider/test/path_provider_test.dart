// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/test.dart';

void main() {
  test('Path provider control test', () async {
    final List<MethodCall> log = <MethodCall>[];
    String response;
    const channel = const MethodChannel('plugins.flutter.io/path_provider');

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return response;
    });

    Directory directory = await getTemporaryDirectory();

    expect(log, equals(<MethodCall>[new MethodCall('getTemporaryDirectory')]));
    expect(directory, isNull);
    log.clear();

    directory = await getApplicationDocumentsDirectory();

    expect(
        log,
        equals(
            <MethodCall>[new MethodCall('getApplicationDocumentsDirectory')]));
    expect(directory, isNull);

    final String fakePath = "/foo/bar/baz";
    response = fakePath;

    directory = await getTemporaryDirectory();
    expect(directory.path, equals(fakePath));

    directory = await getApplicationDocumentsDirectory();
    expect(directory.path, equals(fakePath));
  });
}
