// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
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
      final RepositoryPackage plugin =
          RepositoryPackage(createFakePlugin('plugin', packagesDir));

      expect(pluginSupportsPlatform(kPlatformAndroid, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformIos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformLinux, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformMacos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformWeb, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformWindows, plugin), isFalse);
    });

    test('all platforms', () async {
      final RepositoryPackage plugin = RepositoryPackage(createFakePlugin(
          'plugin', packagesDir,
          platformSupport: <String, PlatformSupport>{
            kPlatformAndroid: PlatformSupport.inline,
            kPlatformIos: PlatformSupport.inline,
            kPlatformLinux: PlatformSupport.inline,
            kPlatformMacos: PlatformSupport.inline,
            kPlatformWeb: PlatformSupport.inline,
            kPlatformWindows: PlatformSupport.inline,
          }));

      expect(pluginSupportsPlatform(kPlatformAndroid, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformIos, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformLinux, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformMacos, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformWeb, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformWindows, plugin), isTrue);
    });

    test('some platforms', () async {
      final RepositoryPackage plugin = RepositoryPackage(createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformLinux: PlatformSupport.inline,
          kPlatformWeb: PlatformSupport.inline,
        },
      ));

      expect(pluginSupportsPlatform(kPlatformAndroid, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformIos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformLinux, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformMacos, plugin), isFalse);
      expect(pluginSupportsPlatform(kPlatformWeb, plugin), isTrue);
      expect(pluginSupportsPlatform(kPlatformWindows, plugin), isFalse);
    });

    test('inline plugins are only detected as inline', () async {
      final RepositoryPackage plugin = RepositoryPackage(createFakePlugin(
        'plugin',
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformIos: PlatformSupport.inline,
          kPlatformLinux: PlatformSupport.inline,
          kPlatformMacos: PlatformSupport.inline,
          kPlatformWeb: PlatformSupport.inline,
          kPlatformWindows: PlatformSupport.inline,
        },
      ));

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
      const String pluginName = 'plugin';
      final RepositoryPackage plugin = RepositoryPackage(createFakePlugin(
        pluginName,
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.federated,
          kPlatformIos: PlatformSupport.federated,
          kPlatformLinux: PlatformSupport.federated,
          kPlatformMacos: PlatformSupport.federated,
          kPlatformWeb: PlatformSupport.federated,
          kPlatformWindows: PlatformSupport.federated,
        },
      ));

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
  });
}
