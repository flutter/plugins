// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/test_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
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
      final Directory plugin1Dir = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      final Directory plugin2Dir = createFakePlugin('plugin2', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(runner, <String>['test']);

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

    test('fails when Flutter tests fail', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      createFakePlugin('plugin2', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      processRunner.mockProcessesForExecutable['flutter'] = <io.Process>[
        MockProcess.failing(), // plugin 1 test
        MockProcess.succeeding(), // plugin 2 test
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Tests for the following packages are failing'),
            contains(' * plugin1'),
          ]));
    });

    test('skips testing plugins without test directory', () async {
      createFakePlugin('plugin1', packagesDir);
      final Directory plugin2Dir = createFakePlugin('plugin2', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['test', '--color'], plugin2Dir.path),
        ]),
      );
    });

    test('runs pub run test on non-Flutter packages', () async {
      final Directory pluginDir = createFakePlugin('a', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      final Directory packageDir = createFakePackage('b', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(
          runner, <String>['test', '--enable-experiment=exp1']);

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

    test('fails when getting non-Flutter package dependencies fails', () async {
      createFakePackage('a_package', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
        MockProcess.failing(), // dart pub get
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Tests for the following packages are failing'),
          ]));
    });

    test('fails when non-Flutter tests fail', () async {
      createFakePackage('a_package', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
        MockProcess.succeeding(), // dart pub get
        MockProcess.failing(), // dart pub run test
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Tests for the following packages are failing'),
          ]));
    });

    test('runs on Chrome for web plugins', () async {
      final Directory pluginDir = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
        platformSupport: <String, PlatformSupport>{
          kPlatformWeb: PlatformSupport.inline,
        },
      );

      await runCapturingPrint(runner, <String>['test']);

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
      final Directory pluginDir = createFakePlugin('a', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      final Directory packageDir = createFakePackage('b', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(
          runner, <String>['test', '--enable-experiment=exp1']);

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
