// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/test_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('$TestCommand', () {
    late FileSystem fileSystem;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final TestCommand command =
          TestCommand(packagesDir, processRunner: processRunner);

      runner = CommandRunner<void>('test_test', 'Test for $TestCommand');
      runner.addCommand(command);
    });

    test('runs flutter test on each plugin', () async {
      final Directory plugin1Dir =
          createFakePlugin('plugin1', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);
      final Directory plugin2Dir =
          createFakePlugin('plugin2', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);

      await runner.run(<String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['test', '--color'], plugin1Dir.path),
          ProcessCall(
              'flutter', const <String>['test', '--color'], plugin2Dir.path),
        ]),
      );
    });

    test('skips testing plugins without test directory', () async {
      createFakePlugin('plugin1', packagesDir);
      final Directory plugin2Dir =
          createFakePlugin('plugin2', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);

      await runner.run(<String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['test', '--color'], plugin2Dir.path),
        ]),
      );
    });

    test('runs pub run test on non-Flutter packages', () async {
      final Directory pluginDir =
          createFakePlugin('a', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);
      final Directory packageDir =
          createFakePackage('b', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);

      await runner.run(<String>['test', '--enable-experiment=exp1']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              const <String>['test', '--color', '--enable-experiment=exp1'],
              pluginDir.path),
          ProcessCall('dart', const <String>['pub', 'get'], packageDir.path),
          ProcessCall(
              'dart',
              const <String>['pub', 'run', '--enable-experiment=exp1', 'test'],
              packageDir.path),
        ]),
      );
    });

    test('runs on Chrome for web plugins', () async {
      final Directory pluginDir = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <List<String>>[
          <String>['test', 'empty_test.dart'],
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformWeb: PlatformSupport.inline,
        },
      );

      await runner.run(<String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              const <String>['test', '--color', '--platform=chrome'],
              pluginDir.path),
        ]),
      );
    });

    test('enable-experiment flag', () async {
      final Directory pluginDir =
          createFakePlugin('a', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);
      final Directory packageDir =
          createFakePackage('b', packagesDir, extraFiles: <List<String>>[
        <String>['test', 'empty_test.dart'],
      ]);

      await runner.run(<String>['test', '--enable-experiment=exp1']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              const <String>['test', '--color', '--enable-experiment=exp1'],
              pluginDir.path),
          ProcessCall('dart', const <String>['pub', 'get'], packageDir.path),
          ProcessCall(
              'dart',
              const <String>['pub', 'run', '--enable-experiment=exp1', 'test'],
              packageDir.path),
        ]),
      );
    });
  });
}
