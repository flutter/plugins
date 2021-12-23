// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String kTemporaryPath = 'temporaryPath';
  const String kApplicationSupportPath = 'applicationSupportPath';
  const String kLibraryPath = 'libraryPath';
  const String kApplicationDocumentsPath = 'applicationDocumentsPath';
  const String kExternalCachePaths = 'externalCachePaths';
  const String kExternalStoragePaths = 'externalStoragePaths';
  const String kDownloadsPath = 'downloadsPath';

  group('PathProviderAndroid', () {
    late PathProviderAndroid pathProvider;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      pathProvider = PathProviderAndroid();
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProvider.methodChannel,
              (MethodCall methodCall) async {
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

    tearDown(() {
      log.clear();
    });

    // TODO(stuartmorgan): Change this to a test that it uses a different name,
    // to avoid potential confusion, once the SDK is changed to 2.8+. See
    // https://github.com/flutter/plugins/pull/4617#discussion_r774673962
    test('channel name is compatible with shared method channel', () async {
      expect(
          pathProvider.methodChannel.name, 'plugins.flutter.io/path_provider');
    });

    test('getTemporaryPath', () async {
      final String? path = await pathProvider.getTemporaryPath();
      expect(
        log,
        <Matcher>[isMethodCall('getTemporaryDirectory', arguments: null)],
      );
      expect(path, kTemporaryPath);
    });

    test('getApplicationSupportPath', () async {
      final String? path = await pathProvider.getApplicationSupportPath();
      expect(
        log,
        <Matcher>[
          isMethodCall('getApplicationSupportDirectory', arguments: null)
        ],
      );
      expect(path, kApplicationSupportPath);
    });

    test('getLibraryPath fails', () async {
      try {
        await pathProvider.getLibraryPath();
        fail('should throw UnsupportedError');
      } catch (e) {
        expect(e, isUnsupportedError);
      }
    });

    test('getApplicationDocumentsPath', () async {
      final String? path = await pathProvider.getApplicationDocumentsPath();
      expect(
        log,
        <Matcher>[
          isMethodCall('getApplicationDocumentsDirectory', arguments: null)
        ],
      );
      expect(path, kApplicationDocumentsPath);
    });

    test('getExternalCachePaths succeeds', () async {
      final List<String>? result = await pathProvider.getExternalCachePaths();
      expect(
        log,
        <Matcher>[isMethodCall('getExternalCacheDirectories', arguments: null)],
      );
      expect(result!.length, 1);
      expect(result.first, kExternalCachePaths);
    });

    for (final StorageDirectory? type in <StorageDirectory?>[
      null,
      ...StorageDirectory.values
    ]) {
      test('getExternalStoragePaths (type: $type) android succeeds', () async {
        final List<String>? result =
            await pathProvider.getExternalStoragePaths(type: type);
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

    test('getDownloadsPath fails', () async {
      try {
        await pathProvider.getDownloadsPath();
        fail('should throw UnsupportedError');
      } catch (e) {
        expect(e, isUnsupportedError);
      }
    });
  });
}
