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
    late CommandRunner<void> runner;
    late CreateAllPluginsAppCommand command;
    late FileSystem fileSystem;
    late Directory testRoot;
    late Directory packagesDir;

    setUp(() {
      // Since the core of this command is a call to 'flutter create', the test
      // has to use the real filesystem. Put everything possible in a unique
      // temporary to minimize effect on the host system.
      fileSystem = const LocalFileSystem();
      testRoot = fileSystem.systemTempDirectory.createTempSync();
      packagesDir = testRoot.childDirectory('packages');

      command = CreateAllPluginsAppCommand(
        packagesDir,
        pluginsRoot: testRoot,
      );
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPluginsAppCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      testRoot.deleteSync(recursive: true);
    });

    test('pubspec includes all plugins', () async {
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      await runCapturingPrint(runner, <String>['all-plugins-app']);
      final List<String> pubspec =
          command.appDirectory.childFile('pubspec.yaml').readAsLinesSync();

      expect(
          pubspec,
          containsAll(<Matcher>[
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec has overrides for all plugins', () async {
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      await runCapturingPrint(runner, <String>['all-plugins-app']);
      final List<String> pubspec =
          command.appDirectory.childFile('pubspec.yaml').readAsLinesSync();

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
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['all-plugins-app']);
      final String pubspec =
          command.appDirectory.childFile('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains(RegExp('sdk:\\s*(?:["\']>=|[^])2\\.12\\.')));
    });

    test('handles --output-dir', () async {
      createFakePlugin('plugina', packagesDir);

      final Directory customOutputDir =
          fileSystem.systemTempDirectory.createTempSync();
      await runCapturingPrint(runner,
          <String>['all-plugins-app', '--output-dir=${customOutputDir.path}']);

      expect(command.appDirectory.path,
          customOutputDir.childDirectory('all_plugins').path);
    });

    test('logs exclusions', () async {
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['all-plugins-app', '--exclude=pluginb,pluginc']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Exluding the following plugins from the combined build:',
            '  pluginb',
            '  pluginc',
          ]));
    });
  });
}
