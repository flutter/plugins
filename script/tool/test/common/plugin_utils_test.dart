// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
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

      expect(pluginSupportsPlatform('android', plugin), isFalse);
      expect(pluginSupportsPlatform('ios', plugin), isFalse);
      expect(pluginSupportsPlatform('linux', plugin), isFalse);
      expect(pluginSupportsPlatform('macos', plugin), isFalse);
      expect(pluginSupportsPlatform('web', plugin), isFalse);
      expect(pluginSupportsPlatform('windows', plugin), isFalse);
    });

    test('all platforms', () async {
      final Directory plugin = createFakePlugin(
        'plugin',
        packagesDir,
        isAndroidPlugin: true,
        isIosPlugin: true,
        isLinuxPlugin: true,
        isMacOsPlugin: true,
        isWebPlugin: true,
        isWindowsPlugin: true,
      );

      expect(pluginSupportsPlatform('android', plugin), isTrue);
      expect(pluginSupportsPlatform('ios', plugin), isTrue);
      expect(pluginSupportsPlatform('linux', plugin), isTrue);
      expect(pluginSupportsPlatform('macos', plugin), isTrue);
      expect(pluginSupportsPlatform('web', plugin), isTrue);
      expect(pluginSupportsPlatform('windows', plugin), isTrue);
    });

    test('some platforms', () async {
      final Directory plugin = createFakePlugin(
        'plugin',
        packagesDir,
        isAndroidPlugin: true,
        isIosPlugin: false,
        isLinuxPlugin: true,
        isMacOsPlugin: false,
        isWebPlugin: true,
        isWindowsPlugin: false,
      );

      expect(pluginSupportsPlatform('android', plugin), isTrue);
      expect(pluginSupportsPlatform('ios', plugin), isFalse);
      expect(pluginSupportsPlatform('linux', plugin), isTrue);
      expect(pluginSupportsPlatform('macos', plugin), isFalse);
      expect(pluginSupportsPlatform('web', plugin), isTrue);
      expect(pluginSupportsPlatform('windows', plugin), isFalse);
    });

    test('inline plugins are only detected as inline', () async {
      // createFakePlugin makes non-federated pubspec entries.
      final Directory plugin = createFakePlugin(
        'plugin',
        packagesDir,
        isAndroidPlugin: true,
        isIosPlugin: true,
        isLinuxPlugin: true,
        isMacOsPlugin: true,
        isWebPlugin: true,
        isWindowsPlugin: true,
      );

      expect(
          pluginSupportsPlatform('android', plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform('android', plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform('ios', plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform('ios', plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform('linux', plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform('linux', plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform('macos', plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform('macos', plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform('web', plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform('web', plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
      expect(
          pluginSupportsPlatform('windows', plugin,
              requiredMode: PlatformSupport.inline),
          isTrue);
      expect(
          pluginSupportsPlatform('windows', plugin,
              requiredMode: PlatformSupport.federated),
          isFalse);
    });

    test('federated plugins are only detected as federated', () async {
      const String pluginName = 'plugin';
      final Directory plugin = createFakePlugin(
        pluginName,
        packagesDir,
        isAndroidPlugin: true,
        isIosPlugin: true,
        isLinuxPlugin: true,
        isMacOsPlugin: true,
        isWebPlugin: true,
        isWindowsPlugin: true,
      );

      createFakePubspec(
        plugin,
        name: pluginName,
        androidSupport: PlatformSupport.federated,
        iosSupport: PlatformSupport.federated,
        linuxSupport: PlatformSupport.federated,
        macosSupport: PlatformSupport.federated,
        webSupport: PlatformSupport.federated,
        windowsSupport: PlatformSupport.federated,
      );

      expect(
          pluginSupportsPlatform('android', plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform('android', plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform('ios', plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform('ios', plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform('linux', plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform('linux', plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform('macos', plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform('macos', plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform('web', plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform('web', plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
      expect(
          pluginSupportsPlatform('windows', plugin,
              requiredMode: PlatformSupport.federated),
          isTrue);
      expect(
          pluginSupportsPlatform('windows', plugin,
              requiredMode: PlatformSupport.inline),
          isFalse);
    });
  });
}
