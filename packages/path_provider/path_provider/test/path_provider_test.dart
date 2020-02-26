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

const String kTestPath = 'testDirectory';

void main() {
  group('PathProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() async {
      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    test('getTemporaryDirectory', () async {
      Directory result = await getTemporaryDirectory();
      expect(result.path, kTestPath);
    });

    test('getApplicationSupportDirectory', () async {
      Directory result = await getApplicationSupportDirectory();
      expect(result.path, kTestPath);
    });

    test('getLibraryDirectory', () async {
      Directory result = await getLibraryDirectory();
      expect(result.path, kTestPath);
    });

    test('getApplicationDocumentsDirectory', () async {
      Directory result = await getApplicationDocumentsDirectory();
      expect(result.path, kTestPath);
    });

    test('getExternalStorageDirectory', () async {
      Directory result = await getExternalStorageDirectory();
      expect(result.path, kTestPath);
    });

    test('getExternalCacheDirectories', () async {
      List<Directory> result = await getExternalCacheDirectories();
      expect(result.length, 1);
      expect(result.first.path, kTestPath);
    });

    test('getExternalStorageDirectories', () async {
      List<Directory> result = await getExternalStorageDirectories();
      expect(result.length, 1);
      expect(result.first.path, kTestPath);
    });

    test('getDownloadsDirectory', () async {
      Directory result = await getDownloadsDirectory();
      expect(result.path, kTestPath);
    });
  });
}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  Future<String> getTemporaryPath() async {
    return kTestPath;
  }

  Future<String> getApplicationSupportPath() async {
    return kTestPath;
  }

  Future<String> getLibraryPath() async {
    return kTestPath;
  }

  Future<String> getApplicationDocumentsPath() async {
    return kTestPath;
  }

  Future<String> getExternalStoragePath() async {
    return kTestPath;
  }

  Future<List<String>> getExternalCachePaths() async {
    return <String>[kTestPath];
  }

  Future<List<String>> getExternalStoragePaths({
    AndroidStorageDirectory type,
  }) async {
    return <String>[kTestPath];
  }

  Future<String> getDownloadsPath() async {
    return kTestPath;
  }
}
