// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/test.dart';

void main() {
  const channel = const MethodChannel('plugins.flutter.io/path_provider');
  final List<MethodCall> log = <MethodCall>[];
  String response;

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    return response;
  });

  tearDown(() {
    log.clear();
  });

  test('getTemporaryDirectory test', () async {
    response = null;
    Directory directory = await getTemporaryDirectory();
    expect(log, equals(<MethodCall>[new MethodCall('getTemporaryDirectory')]));
    expect(directory, isNull);
  });

  test('getApplicationDocumentsDirectory test', () async {
    response = null;
    Directory directory = await getApplicationDocumentsDirectory();
    expect(
      log,
      equals(<MethodCall>[new MethodCall('getApplicationDocumentsDirectory')]),
    );
    expect(directory, isNull);
  });

  test('TemporaryDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    Directory directory = await getTemporaryDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ApplicationDocumentsDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    Directory directory = await getApplicationDocumentsDirectory();
    expect(directory.path, equals(fakePath));
  });
}
