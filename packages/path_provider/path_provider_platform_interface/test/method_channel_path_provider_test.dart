// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String kTemporaryPath = 'temporaryPath';
  const String kApplicationSupportPath = 'applicationSupportPath';
  const String kLibraryPath = 'libraryPath';
  const String kApplicationDocumentsPath = 'applicationDocumentsPath';
  const String kExternalCachePaths = 'externalCachePaths';
  const String kExternalStoragePaths = 'externalStoragePaths';
  const String kDownloadsPath = 'downloadsPath';

  group('$MethodChannelPathProvider', () {
    MethodChannelPathProvider methodChannelPathProvider;

    setUp(() async {
      methodChannelPathProvider = MethodChannelPathProvider();

      methodChannelPathProvider.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getTemporaryDirectory':
            return kTemporaryPath;
          case 'getApplicationSupportDirectory':
            return kApplicationSupportPath;
          case 'getLibraryDirectory':
            return kLibraryPath;
          case 'getApplicationDocumentsDirectory':
            return kApplicationDocumentsPath;
          case 'getExternalStorageDirectories':
            return <String>[kExternalStoragePaths];
          case 'getExternalCacheDirectories':
            return <String>[kExternalCachePaths];
          case 'getDownloadsDirectory':
            return kDownloadsPath;
          default:
            return null;
        }
      });
    });

    test('getTemporaryPath', () async {
      final String result =
          await methodChannelPathProvider.getTemporaryPath();
      expect(result, kTemporaryPath);
    });

    test('getApplicationSupportPath', () async {
      final String result =
          await methodChannelPathProvider.getApplicationSupportPath();
      expect(result, kApplicationSupportPath);
    });

    test('getLibraryPath', () async {
      methodChannelPathProvider
          .setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));
      final String result =
          await methodChannelPathProvider.getLibraryPath();
      expect(result, kLibraryPath);
    });

    test('getApplicationDocumentsPath', () async {
      final String result =
          await methodChannelPathProvider.getApplicationDocumentsPath();
      expect(result, kApplicationDocumentsPath);
    });

    test('getExternalCachePaths', () async {
      methodChannelPathProvider.setMockPathProviderPlatform(
          FakePlatform(operatingSystem: 'android'));
      final List<String> result =
          await methodChannelPathProvider.getExternalCachePaths();

      expect(result.length, 1);
      expect(result.first, kExternalCachePaths);
    });

    test('getExternalStoragePaths', () async {
      methodChannelPathProvider.setMockPathProviderPlatform(
          FakePlatform(operatingSystem: 'android'));
      final List<String> result =
          await methodChannelPathProvider.getExternalStoragePaths();

      expect(result.length, 1);
      expect(result.first, kExternalStoragePaths);
    });

    test('getDownloadsPath', () async {
      methodChannelPathProvider
          .setMockPathProviderPlatform(FakePlatform(operatingSystem: 'macos'));
      final String result =
          await methodChannelPathProvider.getDownloadsPath();

      expect(result, kDownloadsPath);
    });
  });
}
