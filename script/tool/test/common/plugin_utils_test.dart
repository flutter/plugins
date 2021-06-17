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
      final Directory plugin = createFakePlugin('plugin', packagesDir);

      expect(pluginSupportsPlatform(kPlatformAndroid, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformIos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformLinux, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformMacos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformWeb, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformWindows, plugin), isFalse);
    });

    test('all platforms', () async {
      final Directory plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
            kPlatformIos: const PlatformDetails(PlatformSupport.inline),
            kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
            kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
            kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
          });

      expect(pluginSupportsPlatform(kPlatformAndroid, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformIos, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformLinux, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformMacos, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformWeb, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformWindows, plugin), isTrue);
    });

    test('some platforms', () async {
      final Directory plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
            kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
            kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
          });

      expect(pluginSupportsPlatform(kPlatformAndroid, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformIos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformLinux, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformMacos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformWeb, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformWindows, plugin), isFalse);
    });

    test('inline plugins are only detected as inline', () async {
      final Directory plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
            kPlatformIos: const PlatformDetails(PlatformSupport.inline),
            kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
            kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
            kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
          });

      expect(
          pluginSupportsPlatform(kPlatformAndroid, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformAndroid, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformIos, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformIos, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformLinux, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformLinux, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformMacos, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformMacos, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformWeb, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWeb, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
    });

    test('federated plugins are only detected as federated', () async {
      final Directory plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.federated),
            kPlatformIos: const PlatformDetails(PlatformSupport.federated),
            kPlatformLinux: const PlatformDetails(PlatformSupport.federated),
            kPlatformMacos: const PlatformDetails(PlatformSupport.federated),
            kPlatformWeb: const PlatformDetails(PlatformSupport.federated),
            kPlatformWindows: const PlatformDetails(PlatformSupport.federated),
          });

      expect(
          pluginSupportsPlatform(kPlatformAndroid, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformAndroid, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformIos, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformIos, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformLinux, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformLinux, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformMacos, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformMacos, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformWeb, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWeb, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
    });

    test('windows without variants is only win32', () async {
      final Directory plugin = createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
        },
      );

      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWin32),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWinUwp),
          isFalse);
    });

    test('windows with both variants matches win32 and winuwp', () async {
      final Directory plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformWindows: const PlatformDetails(
              PlatformSupport.federated,
              variants: <String>[kPlatformVariantWin32, kPlatformVariantWinUwp],
            ),
          });

      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWin32),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWinUwp),
          isTrue);
    });

    test('win32 plugin is only win32', () async {
      final Directory plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformWindows: const PlatformDetails(
              PlatformSupport.federated,
              variants: <String>[kPlatformVariantWin32],
            ),
          });

      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWin32),
          isTrue);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWinUwp),
          isFalse);
    });

    test('winup plugin is only winuwp', () async {
      final Directory plugin = createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.federated,
              variants: <String>[kPlatformVariantWinUwp]),
        },
      );

      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWin32),
          isFalse);
      expect(
          pluginSupportsPlatform(kPlatformWindows, plugin,
              variant: kPlatformVariantWinUwp),
          isTrue);
    });
  });
}
