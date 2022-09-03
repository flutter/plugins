// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
  });

  group('pluginSupportsPlatform', () {
    test('no platforms', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir);

      expect(pluginSupportsPlatform(platformAndroid, plugin), isFalse);
      expect(pluginSupportsPlatform(platformIOS, plugin), isFalse);
      expect(pluginSupportsPlatform(platformLinux, plugin), isFalse);
      expect(pluginSupportsPlatform(platformMacOS, plugin), isFalse);
      expect(pluginSupportsPlatform(platformWeb, plugin), isFalse);
      expect(pluginSupportsPlatform(platformWindows, plugin), isFalse);
    });

    test('all platforms', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
            platformIOS: const PlatformDetails(PlatformSupport.inline),
            platformLinux: const PlatformDetails(PlatformSupport.inline),
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
            platformWeb: const PlatformDetails(PlatformSupport.inline),
            platformWindows: const PlatformDetails(PlatformSupport.inline),
          });

      expect(pluginSupportsPlatform(platformAndroid, plugin), isTrue);
      expect(pluginSupportsPlatform(platformIOS, plugin), isTrue);
      expect(pluginSupportsPlatform(platformLinux, plugin), isTrue);
      expect(pluginSupportsPlatform(platformMacOS, plugin), isTrue);
      expect(pluginSupportsPlatform(platformWeb, plugin), isTrue);
      expect(pluginSupportsPlatform(platformWindows, plugin), isTrue);
    });

    test('some platforms', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
            platformLinux: const PlatformDetails(PlatformSupport.inline),
            platformWeb: const PlatformDetails(PlatformSupport.inline),
          });

      expect(pluginSupportsPlatform(platformAndroid, plugin), isTrue);
      expect(pluginSupportsPlatform(platformIOS, plugin), isFalse);
      expect(pluginSupportsPlatform(platformLinux, plugin), isTrue);
      expect(pluginSupportsPlatform(platformMacOS, plugin), isFalse);
      expect(pluginSupportsPlatform(platformWeb, plugin), isTrue);
      expect(pluginSupportsPlatform(platformWindows, plugin), isFalse);
    });

    test('inline plugins are only detected as inline', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
            platformIOS: const PlatformDetails(PlatformSupport.inline),
            platformLinux: const PlatformDetails(PlatformSupport.inline),
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
            platformWeb: const PlatformDetails(PlatformSupport.inline),
            platformWindows: const PlatformDetails(PlatformSupport.inline),
          });

      expect(
          pluginSupportsPlatform(platformAndroid, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(platformAndroid, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(platformIOS, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(platformIOS, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(platformLinux, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(platformLinux, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(platformMacOS, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(platformMacOS, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(platformWeb, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(platformWeb, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(platformWindows, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(platformWindows, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
    });

    test('federated plugins are only detected as federated', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.federated),
            platformIOS: const PlatformDetails(PlatformSupport.federated),
            platformLinux: const PlatformDetails(PlatformSupport.federated),
            platformMacOS: const PlatformDetails(PlatformSupport.federated),
            platformWeb: const PlatformDetails(PlatformSupport.federated),
            platformWindows: const PlatformDetails(PlatformSupport.federated),
          });

      expect(
          pluginSupportsPlatform(platformAndroid, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(platformAndroid, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(platformIOS, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(platformIOS, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(platformLinux, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(platformLinux, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(platformMacOS, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(platformMacOS, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(platformWeb, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(platformWeb, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(platformWindows, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(platformWindows, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
    });
  });

  group('pluginHasNativeCodeForPlatform', () {
    test('returns false for web', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      expect(pluginHasNativeCodeForPlatform(platformWeb, plugin), isFalse);
    });

    test('returns false for a native-only plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformLinux: const PlatformDetails(PlatformSupport.inline),
          platformMacOS: const PlatformDetails(PlatformSupport.inline),
          platformWindows: const PlatformDetails(PlatformSupport.inline),
        },
      );

      expect(pluginHasNativeCodeForPlatform(platformLinux, plugin), isTrue);
      expect(pluginHasNativeCodeForPlatform(platformMacOS, plugin), isTrue);
      expect(pluginHasNativeCodeForPlatform(platformWindows, plugin), isTrue);
    });

    test('returns true for a native+Dart plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformLinux:
              const PlatformDetails(PlatformSupport.inline, hasDartCode: true),
          platformMacOS:
              const PlatformDetails(PlatformSupport.inline, hasDartCode: true),
          platformWindows:
              const PlatformDetails(PlatformSupport.inline, hasDartCode: true),
        },
      );

      expect(pluginHasNativeCodeForPlatform(platformLinux, plugin), isTrue);
      expect(pluginHasNativeCodeForPlatform(platformMacOS, plugin), isTrue);
      expect(pluginHasNativeCodeForPlatform(platformWindows, plugin), isTrue);
    });

    test('returns false for a Dart-only plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformLinux: const PlatformDetails(PlatformSupport.inline,
              hasNativeCode: false, hasDartCode: true),
          platformMacOS: const PlatformDetails(PlatformSupport.inline,
              hasNativeCode: false, hasDartCode: true),
          platformWindows: const PlatformDetails(PlatformSupport.inline,
              hasNativeCode: false, hasDartCode: true),
        },
      );

      expect(pluginHasNativeCodeForPlatform(platformLinux, plugin), isFalse);
      expect(pluginHasNativeCodeForPlatform(platformMacOS, plugin), isFalse);
      expect(pluginHasNativeCodeForPlatform(platformWindows, plugin), isFalse);
    });
  });
}
