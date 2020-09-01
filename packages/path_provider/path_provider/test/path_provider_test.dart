// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory;
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

void main() {
  group('PathProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() async {
      PathProviderPlatform.instance = MockPathProviderPlatform();
      // This is required because we manually register the Linux path provider when on the Linux platform.
      // Will be removed when automatic registration of dart plugins is implemented.
      // See this issue https://github.com/flutter/flutter/issues/52267 for details
      disablePathProviderPlatformOverride = true;
    });

    test('getTemporaryDirectory', () async {
      Directory result = await getTemporaryDirectory();
      expect(result.path, kTemporaryPath);
    });

    test('getApplicationSupportDirectory', () async {
      Directory result = await getApplicationSupportDirectory();
      expect(result.path, kApplicationSupportPath);
    });

    test('getLibraryDirectory', () async {
      Directory result = await getLibraryDirectory();
      expect(result.path, kLibraryPath);
    });

    test('getApplicationDocumentsDirectory', () async {
      Directory result = await getApplicationDocumentsDirectory();
      expect(result.path, kApplicationDocumentsPath);
    });

    test('getExternalStorageDirectory', () async {
      Directory result = await getExternalStorageDirectory();
      expect(result.path, kExternalStoragePath);
    });

    test('getExternalCacheDirectories', () async {
      List<Directory> result = await getExternalCacheDirectories();
      expect(result.length, 1);
      expect(result.first.path, kExternalCachePath);
    });

    test('getExternalStorageDirectories', () async {
      List<Directory> result = await getExternalStorageDirectories();
      expect(result.length, 1);
      expect(result.first.path, kExternalStoragePath);
    });

    test('getDownloadsDirectory', () async {
      Directory result = await getDownloadsDirectory();
      expect(result.path, kDownloadsPath);
    });
  });
}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  Future<String> getTemporaryPath() async {
    return kTemporaryPath;
  }

  Future<String> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  Future<String> getLibraryPath() async {
    return kLibraryPath;
  }

  Future<String> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  Future<String> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  Future<List<String>> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  Future<List<String>> getExternalStoragePaths({
    StorageDirectory type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  Future<String> getDownloadsPath() async {
    return kDownloadsPath;
  }
}
