// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/lint_podspecs_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$LintPodspecsCommand', () {
    FileSystem fileSystem;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late MockPlatform mockPlatform;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem(style: FileSystemStyle.posix);
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);

      mockPlatform = MockPlatform(isMacOS: true);
      processRunner = RecordingProcessRunner();
      final LintPodspecsCommand command = LintPodspecsCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner =
          CommandRunner<void>('podspec_test', 'Test for $LintPodspecsCommand');
      runner.addCommand(command);
    });

    test('only runs on macOS', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);
      mockPlatform.isMacOS = false;

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspecs'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
        processRunner.recordedCalls,
        equals(<ProcessCall>[]),
      );

      expect(
          output,
          containsAllInOrder(
            <Matcher>[contains('only supported on macOS')],
          ));
    });

    test('runs pod lib lint on a podspec', () async {
      final Directory plugin1Dir = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>[
          'ios/plugin1.podspec',
          'bogus.dart', // Ignore non-podspecs.
        ],
      );

      processRunner.mockProcessesForExecutable['pod'] = <io.Process>[
        MockProcess(stdout: 'Foo', stderr: 'Bar'),
        MockProcess(),
      ];

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspecs']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('which', const <String>['pod'], packagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                plugin1Dir
                    .childDirectory('ios')
                    .childFile('plugin1.podspec')
                    .path,
                '--configuration=Debug',
                '--skip-tests',
                '--use-modular-headers',
                '--use-libraries'
              ],
              packagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                plugin1Dir
                    .childDirectory('ios')
                    .childFile('plugin1.podspec')
                    .path,
                '--configuration=Debug',
                '--skip-tests',
                '--use-modular-headers',
              ],
              packagesDir.path),
        ]),
      );

      expect(output, contains('Linting plugin1.podspec'));
      expect(output, contains('Foo'));
      expect(output, contains('Bar'));
    });

    test('fails if pod is missing', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);

      // Simulate failure from `which pod`.
      processRunner.mockProcessesForExecutable['which'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspecs'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Unable to find "pod". Make sure it is in your path.'),
            ],
          ));
    });

    test('fails if linting as a framework fails', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);

      // Simulate failure from `pod`.
      processRunner.mockProcessesForExecutable['pod'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspecs'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The following packages had errors:'),
              contains('plugin1:\n'
                  '    plugin1.podspec')
            ],
          ));
    });

    test('fails if linting as a static library fails', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);

      // Simulate failure from the second call to `pod`.
      processRunner.mockProcessesForExecutable['pod'] = <io.Process>[
        MockProcess(),
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspecs'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The following packages had errors:'),
              contains('plugin1:\n'
                  '    plugin1.podspec')
            ],
          ));
    });

    test('skips when there are no podspecs', () async {
      createFakePlugin('plugin1', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspecs']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[contains('SKIPPING: No podspecs.')],
          ));
    });
  });
}
