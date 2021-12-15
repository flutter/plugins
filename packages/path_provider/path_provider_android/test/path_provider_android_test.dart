// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_android/path_provider_android.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String kTemporaryPath = 'temporaryPath';
  const String kApplicationSupportPath = 'applicationSupportPath';
  const String kLibraryPath = 'libraryPath';
  const String kApplicationDocumentsPath = 'applicationDocumentsPath';
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

    test('getLibraryPath', () async {
      final String? path = await pathProvider.getLibraryPath();
      expect(
        log,
        <Matcher>[isMethodCall('getLibraryDirectory', arguments: null)],
      );
      expect(path, kLibraryPath);
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

    test('getDownloadsPath', () async {
      final String? result = await pathProvider.getDownloadsPath();
      expect(
        log,
        <Matcher>[isMethodCall('getDownloadsDirectory', arguments: null)],
      );
      expect(result, kDownloadsPath);
    });

    test('getExternalCachePaths throws', () async {
      expect(pathProvider.getExternalCachePaths(), throwsA(isUnsupportedError));
    });

    test('getExternalStoragePath throws', () async {
      expect(
          pathProvider.getExternalStoragePath(), throwsA(isUnsupportedError));
    });

    test('getExternalStoragePaths throws', () async {
      expect(
          pathProvider.getExternalStoragePaths(), throwsA(isUnsupportedError));
    });
  });
}
