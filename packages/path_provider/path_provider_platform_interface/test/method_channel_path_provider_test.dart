// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/src/enums.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';

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
    late MethodChannelPathProvider methodChannelPathProvider;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      methodChannelPathProvider = MethodChannelPathProvider();

      methodChannelPathProvider.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
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

    setUp(() {});

    tearDown(() {
      log.clear();
    });

    test('getTemporaryPath', () async {
      final String? path = await methodChannelPathProvider.getTemporaryPath();
      expect(
        log,
        <Matcher>[isMethodCall('getTemporaryDirectory', arguments: null)],
      );
      expect(path, kTemporaryPath);
    });

    test('getApplicationSupportPath', () async {
      final String? path =
          await methodChannelPathProvider.getApplicationSupportPath();
      expect(
        log,
        <Matcher>[
          isMethodCall('getApplicationSupportDirectory', arguments: null)
        ],
      );
      expect(path, kApplicationSupportPath);
    });

    test('getLibraryPath', () async {
      final String? path = await methodChannelPathProvider.getLibraryPath();
      expect(
        log,
        <Matcher>[isMethodCall('getLibraryDirectory', arguments: null)],
      );
      expect(path, kLibraryPath);
    });

    test('getApplicationDocumentsPath', () async {
      final String? path =
          await methodChannelPathProvider.getApplicationDocumentsPath();
      expect(
        log,
        <Matcher>[
          isMethodCall('getApplicationDocumentsDirectory', arguments: null)
        ],
      );
      expect(path, kApplicationDocumentsPath);
    });

    test('getExternalCachePaths', () async {
      final List<String>? result =
          await methodChannelPathProvider.getExternalCachePaths();
      expect(
        log,
        <Matcher>[isMethodCall('getExternalCacheDirectories', arguments: null)],
      );
      expect(result!.length, 1);
      expect(result.first, kExternalCachePaths);
    });

    for (StorageDirectory? type in <StorageDirectory?>[
      null,
      ...StorageDirectory.values
    ]) {
      test('getExternalStoragePaths (type: $type)', () async {
        final List<String>? result =
            await methodChannelPathProvider.getExternalStoragePaths(type: type);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'getExternalStorageDirectories',
              arguments: <String, dynamic>{'type': type?.index},
            )
          ],
        );

        expect(result!.length, 1);
        expect(result.first, kExternalStoragePaths);
      });
    } // end of for-loop

    test('getDownloadsPath', () async {
      final String? result = await methodChannelPathProvider.getDownloadsPath();
      expect(
        log,
        <Matcher>[isMethodCall('getDownloadsDirectory', arguments: null)],
      );
      expect(result, kDownloadsPath);
    });
  });
}
