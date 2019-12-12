// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');
  final List<MethodCall> log = <MethodCall>[];
  dynamic response;

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    return response;
  });

  setUp(() {
    setMockPathProviderPlatform(FakePlatform(operatingSystem: 'android'));
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

  test('getApplicationSupportDirectory test', () async {
    response = null;
    final Directory directory = await getApplicationSupportDirectory();
    expect(
      log,
      <Matcher>[
        isMethodCall('getApplicationSupportDirectory', arguments: null)
      ],
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

  test('getApplicationSupportDirectory test', () async {
    response = null;
    final Directory directory = await getApplicationSupportDirectory();
    expect(
      log,
      <Matcher>[
        isMethodCall('getApplicationSupportDirectory', arguments: null)
      ],
    );
    expect(directory, isNull);
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

  test('getLibraryDirectory Android test', () async {
    try {
      await getLibraryDirectory();
      fail('should throw UnsupportedError');
    } catch (e) {
      expect(e, isUnsupportedError);
    }
  });
  test('getLibraryDirectory iOS test', () async {
    setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));

    final Directory directory = await getLibraryDirectory();
    expect(
      log,
      <Matcher>[isMethodCall('getLibraryDirectory', arguments: null)],
    );
    expect(directory, isNull);
  });

  test('getExternalStorageDirectory iOS test', () async {
    setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));

    try {
      await getExternalStorageDirectory();
      fail('should throw UnsupportedError');
    } catch (e) {
      expect(e, isUnsupportedError);
    }
  });

  test('getExternalCacheDirectories test', () async {
    response = <String>[];
    final List<Directory> directories = await getExternalCacheDirectories();
    expect(
      log,
      <Matcher>[isMethodCall('getExternalCacheDirectories', arguments: null)],
    );
    expect(directories, <Directory>[]);
  });

  test('getExternalCacheDirectories iOS test', () async {
    setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));

    try {
      await getExternalCacheDirectories();
      fail('should throw UnsupportedError');
    } catch (e) {
      expect(e, isUnsupportedError);
    }
  });

  for (StorageDirectory type
      in StorageDirectory.values + <StorageDirectory>[null]) {
    test('getExternalStorageDirectories test (type: $type)', () async {
      response = <String>[];
      final List<Directory> directories =
          await getExternalStorageDirectories(type: type);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'getExternalStorageDirectories',
            arguments: <String, dynamic>{'type': type?.index},
          )
        ],
      );
      expect(directories, <Directory>[]);
    });
  }

  test('getExternalStorageDirectories iOS test', () async {
    setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));

    try {
      await getExternalStorageDirectories(type: StorageDirectory.music);
      fail('should throw UnsupportedError');
    } catch (e) {
      expect(e, isUnsupportedError);
    }
  });

  test('TemporaryDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getTemporaryDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ApplicationSupportDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getApplicationSupportDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ApplicationDocumentsDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getApplicationDocumentsDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ApplicationSupportDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getApplicationSupportDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ApplicationLibraryDirectory path test', () async {
    setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));

    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getLibraryDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ExternalStorageDirectory path test', () async {
    final String fakePath = "/foo/bar/baz";
    response = fakePath;
    final Directory directory = await getExternalStorageDirectory();
    expect(directory.path, equals(fakePath));
  });

  test('ExternalCacheDirectories path test', () async {
    final List<String> paths = <String>["/foo/bar/baz", "/foo/bar/baz2"];
    response = paths;
    final List<Directory> directories = await getExternalCacheDirectories();
    expect(directories.map((Directory d) => d.path).toList(), equals(paths));
  });

  test('ExternalStorageDirectories path test', () async {
    final List<String> paths = <String>["/foo/bar/baz", "/foo/bar/baz2"];
    response = paths;
    final List<Directory> directories = await getExternalStorageDirectories(
      type: StorageDirectory.music,
    );
    expect(directories.map((Directory d) => d.path).toList(), equals(paths));
  });
}
