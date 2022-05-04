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
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$TestCommand', () {
    late FileSystem fileSystem;
    late Platform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final TestCommand command = TestCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>('test_test', 'Test for $TestCommand');
      runner.addCommand(command);
    });

    test('runs flutter test on each plugin', () async {
      final RepositoryPackage plugin1 = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      final RepositoryPackage plugin2 = createFakePlugin('plugin2', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform),
              const <String>['test', '--color'], plugin1.path),
          ProcessCall(getFlutterCommand(mockPlatform),
              const <String>['test', '--color'], plugin2.path),
        ]),
      );
    });

    test('runs flutter test on Flutter package example tests', () async {
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          extraFiles: <String>[
            'test/empty_test.dart',
            'example/test/an_example_test.dart'
          ]);

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform),
              const <String>['test', '--color'], plugin.path),
          ProcessCall(getFlutterCommand(mockPlatform),
              const <String>['test', '--color'], getExampleDir(plugin).path),
        ]),
      );
    });

    test('fails when Flutter tests fail', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      createFakePlugin('plugin2', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <io.Process>[
        MockProcess(exitCode: 1), // plugin 1 test
        MockProcess(), // plugin 2 test
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
            contains('The following packages had errors:'),
            contains('  plugin1'),
          ]));
    });

    test('skips testing plugins without test directory', () async {
      createFakePlugin('plugin1', packagesDir);
      final RepositoryPackage plugin2 = createFakePlugin('plugin2', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform),
              const <String>['test', '--color'], plugin2.path),
        ]),
      );
    });

    test('runs dart run test on non-Flutter packages', () async {
      final RepositoryPackage plugin = createFakePlugin('a', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      final RepositoryPackage package = createFakePackage('b', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(
          runner, <String>['test', '--enable-experiment=exp1']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              getFlutterCommand(mockPlatform),
              const <String>['test', '--color', '--enable-experiment=exp1'],
              plugin.path),
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall(
              'dart',
              const <String>['run', '--enable-experiment=exp1', 'test'],
              package.path),
        ]),
      );
    });

    test('runs dart run test on non-Flutter package examples', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir, extraFiles: <String>[
        'test/empty_test.dart',
        'example/test/an_example_test.dart'
      ]);

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>['run', 'test'], package.path),
          ProcessCall('dart', const <String>['pub', 'get'],
              getExampleDir(package).path),
          ProcessCall('dart', const <String>['run', 'test'],
              getExampleDir(package).path),
        ]),
      );
    });

    test('fails when getting non-Flutter package dependencies fails', () async {
      createFakePackage('a_package', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
        MockProcess(exitCode: 1), // dart pub get
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
            contains('Unable to fetch dependencies'),
            contains('The following packages had errors:'),
            contains('  a_package'),
          ]));
    });

    test('fails when non-Flutter tests fail', () async {
      createFakePackage('a_package', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
        MockProcess(), // dart pub get
        MockProcess(exitCode: 1), // dart pub run test
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
            contains('The following packages had errors:'),
            contains('  a_package'),
          ]));
    });

    test('runs on Chrome for web plugins', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              getFlutterCommand(mockPlatform),
              const <String>['test', '--color', '--platform=chrome'],
              plugin.path),
        ]),
      );
    });

    test('enable-experiment flag', () async {
      final RepositoryPackage plugin = createFakePlugin('a', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);
      final RepositoryPackage package = createFakePackage('b', packagesDir,
          extraFiles: <String>['test/empty_test.dart']);

      await runCapturingPrint(
          runner, <String>['test', '--enable-experiment=exp1']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              getFlutterCommand(mockPlatform),
              const <String>['test', '--color', '--enable-experiment=exp1'],
              plugin.path),
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall(
              'dart',
              const <String>['run', '--enable-experiment=exp1', 'test'],
              package.path),
        ]),
      );
    });
  });
}
