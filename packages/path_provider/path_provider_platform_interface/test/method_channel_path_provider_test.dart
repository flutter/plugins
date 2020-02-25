// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String kTemporaryDirectory = 'temporaryDirectory';
  const String kApplicationSupportDirectory = 'applicationSupportDirectory';
  const String kLibraryDirectory = 'libraryDirectory';
  const String kApplicationDocumentsDirectory = 'applicationDocumentsDirectory';
  const String kExternalCacheDirectories = 'externalCacheDirectories';
  const String kExternalStorageDirectories = 'externalStorageDirectories';
  const String kDownloadsDirectory = 'downloadsDirectory';

  group('$MethodChannelPathProvider', () {
    MethodChannelPathProvider methodChannelPathProvider;

    setUp(() async {
      methodChannelPathProvider = MethodChannelPathProvider();

      methodChannelPathProvider.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getTemporaryDirectory':
            return kTemporaryDirectory;
          case 'getApplicationSupportDirectory':
            return kApplicationSupportDirectory;
          case 'getLibraryDirectory':
            return kLibraryDirectory;
          case 'getApplicationDocumentsDirectory':
            return kApplicationDocumentsDirectory;
          case 'getExternalStorageDirectories':
            return <String>[kExternalStorageDirectories];
          case 'getExternalCacheDirectories':
            return <String>[kExternalCacheDirectories];
          case 'getDownloadsDirectory':
            return kDownloadsDirectory;
          default:
            return null;
        }
      });
    });

    test('getTemporaryDirectory', () async {
      final Directory result =
          await methodChannelPathProvider.getTemporaryDirectory();
      expect(result.path, kTemporaryDirectory);
    });
    test('getApplicationSupportDirectory', () async {
      final Directory result =
          await methodChannelPathProvider.getApplicationSupportDirectory();
      expect(result.path, kApplicationSupportDirectory);
    });

    test('getLibraryDirectory', () async {
      methodChannelPathProvider
          .setMockPathProviderPlatform(FakePlatform(operatingSystem: 'ios'));
      final Directory result =
          await methodChannelPathProvider.getLibraryDirectory();
      expect(result.path, kLibraryDirectory);
    });
    test('getApplicationDocumentsDirectory', () async {
      final Directory result =
          await methodChannelPathProvider.getApplicationDocumentsDirectory();
      expect(result.path, kApplicationDocumentsDirectory);
    });
    test('getExternalCacheDirectories', () async {
      methodChannelPathProvider.setMockPathProviderPlatform(
          FakePlatform(operatingSystem: 'android'));
      final List<Directory> result =
          await methodChannelPathProvider.getExternalCacheDirectories();

      expect(result.length, 1);
      expect(result.first.path, kExternalCacheDirectories);
    });
    test('getExternalStorageDirectories', () async {
      methodChannelPathProvider.setMockPathProviderPlatform(
          FakePlatform(operatingSystem: 'android'));
      final List<Directory> result =
          await methodChannelPathProvider.getExternalStorageDirectories();

      expect(result.length, 1);
      expect(result.first.path, kExternalStorageDirectories);
    });
    test('getDownloadsDirectory', () async {
      methodChannelPathProvider
          .setMockPathProviderPlatform(FakePlatform(operatingSystem: 'macos'));
      final Directory result =
          await methodChannelPathProvider.getDownloadsDirectory();

      expect(result.path, kDownloadsDirectory);
    });
  });
}
