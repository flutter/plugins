// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_tools/src/create_all_plugins_app_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('$CreateAllPluginsAppCommand', () {
    CommandRunner<void> runner;
    FileSystem fileSystem;
    Directory testRoot;
    Directory packagesDir;
    Directory appDir;

    setUp(() {
      // Since the core of this command is a call to 'flutter create', the test
      // has to use the real filesystem. Put everything possible in a unique
      // temporary to minimize affect on the host system.
      fileSystem = const LocalFileSystem();
      testRoot = fileSystem.systemTempDirectory.createTempSync();
      packagesDir = testRoot.childDirectory('packages');

      final CreateAllPluginsAppCommand command = CreateAllPluginsAppCommand(
        packagesDir,
        fileSystem,
        pluginsRoot: testRoot,
      );
      appDir = command.appDirectory;
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPluginsAppCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      testRoot.deleteSync(recursive: true);
    });

    test('pubspec includes all plugins', () async {
      createFakePlugin('plugina', packagesDirectory: packagesDir);
      createFakePlugin('pluginb', packagesDirectory: packagesDir);
      createFakePlugin('pluginc', packagesDirectory: packagesDir);

      await runner.run(<String>['all-plugins-app']);
      final List<String> pubspec =
          appDir.childFile('pubspec.yaml').readAsLinesSync();

      expect(
          pubspec,
          containsAll(<Matcher>[
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec has overrides for all plugins', () async {
      createFakePlugin('plugina', packagesDirectory: packagesDir);
      createFakePlugin('pluginb', packagesDirectory: packagesDir);
      createFakePlugin('pluginc', packagesDirectory: packagesDir);

      await runner.run(<String>['all-plugins-app']);
      final List<String> pubspec =
          appDir.childFile('pubspec.yaml').readAsLinesSync();

      expect(
          pubspec,
          containsAllInOrder(<Matcher>[
            contains('dependency_overrides:'),
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec is compatible with null-safe app code', () async {
      createFakePlugin('plugina', packagesDirectory: packagesDir);

      await runner.run(<String>['all-plugins-app']);
      final String pubspec =
          appDir.childFile('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains(RegExp('sdk:\\s*(?:["\']>=|[^])2\\.12\\.')));
    });
  });
}
