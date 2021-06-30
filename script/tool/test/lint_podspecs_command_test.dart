// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/lint_podspecs_command.dart';
import 'package:path/path.dart' as p;
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
      fileSystem = MemoryFileSystem();
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
      final MockProcess mockLintProcess = MockProcess();
      mockLintProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockLintProcess;
      processRunner.recordedCalls.clear();
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

      processRunner.resultStdout = 'Foo';
      processRunner.resultStderr = 'Bar';

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
                p.join(plugin1Dir.path, 'ios', 'plugin1.podspec'),
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
                p.join(plugin1Dir.path, 'ios', 'plugin1.podspec'),
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

    test('allow warnings for podspecs with known warnings', () async {
      final Directory plugin1Dir = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);

      final List<String> output = await runCapturingPrint(
          runner, <String>['podspecs', '--ignore-warnings=plugin1']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('which', const <String>['pod'], packagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                p.join(plugin1Dir.path, 'plugin1.podspec'),
                '--configuration=Debug',
                '--skip-tests',
                '--use-modular-headers',
                '--allow-warnings',
                '--use-libraries'
              ],
              packagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                p.join(plugin1Dir.path, 'plugin1.podspec'),
                '--configuration=Debug',
                '--skip-tests',
                '--use-modular-headers',
                '--allow-warnings',
              ],
              packagesDir.path),
        ]),
      );

      expect(output, contains('Linting plugin1.podspec'));
    });

    test('fails if linting fails', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);

      // Simulate failure from `pod`.
      final MockProcess mockDriveProcess = MockProcess();
      mockDriveProcess.exitCodeCompleter.complete(1);
      processRunner.processToReturn = mockDriveProcess;

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
  });
}
