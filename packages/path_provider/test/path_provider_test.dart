// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');
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
    final Directory directory = await getTemporaryDirectory();
    expect(
      log,
      <Matcher>[isMethodCall('getTemporaryDirectory', arguments: null)],
    );
    expect(directory, isNull);
  });

  test('getApplicationDocumentsDirectory test', () async {
    response = null;
    final Directory directory = await getApplicationDocumentsDirectory();
    expect(
      log,
      <Matcher>[
        isMethodCall('getApplicationDocumentsDirectory', arguments: null)
      ],
    );
    expect(directory, isNull);
  });

  test('TemporaryDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getTemporaryDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ApplicationDocumentsDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getApplicationDocumentsDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('getExternalStorageDirectory test', () async {
    response = null;
    final Directory directory = await getExternalStorageDirectory();
    expect(
      log,
      <Matcher>[isMethodCall('getStorageDirectory', arguments: null)],
    );
    expect(directory, isNull);
  });

  test('getExternalCacheDirectories test', () async {
    response = null;
    final List<Directory> directories = await getExternalCacheDirectories();
    expect(
      log,
      <Matcher>[isMethodCall('getExternalCacheDirectories', arguments: null)],
    );
    expect(directories, <Directory>[]);
  });

  test('getExternalStorageDirectories test', () async {
    response = null;
    final List<Directory> directories =
        await getExternalStorageDirectories("music");
    expect(
      log,
      <Matcher>[
        isMethodCall(
          'getExternalStorageDirectories',
          arguments: const <String, String>{'type': 'music'},
        )
      ],
    );
    expect(directories, <Directory>[]);
  });
}
