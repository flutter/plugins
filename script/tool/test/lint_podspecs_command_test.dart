// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/lint_podspecs_command.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$LintPodspecsCommand', () {
    CommandRunner<Null> runner;
    MockPlatform mockPlatform;
    final RecordingProcessRunner processRunner = RecordingProcessRunner();
    List<String> printedMessages;

    setUp(() {
      initializeFakePackages();

      printedMessages = <String>[];
      mockPlatform = MockPlatform();
      when(mockPlatform.isMacOS).thenReturn(true);
      final LintPodspecsCommand command = LintPodspecsCommand(
        mockPackagesDir,
        mockFileSystem,
        processRunner: processRunner,
        platform: mockPlatform,
        print: (Object message) => printedMessages.add(message.toString()),
      );

      runner =
          CommandRunner<Null>('podspec_test', 'Test for $LintPodspecsCommand');
      runner.addCommand(command);
      final MockProcess mockLintProcess = MockProcess();
      mockLintProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockLintProcess;
      processRunner.recordedCalls.clear();
    });

    tearDown(() {
      cleanupPackages();
    });

    test('only runs on macOS', () async {
      createFakePlugin('plugin1', withExtraFiles: <List<String>>[
        <String>['plugin1.podspec'],
      ]);

      when(mockPlatform.isMacOS).thenReturn(false);
      await runner.run(<String>['podspecs']);

      expect(
        processRunner.recordedCalls,
        equals(<ProcessCall>[]),
      );
    });

    test('runs pod lib lint on a podspec', () async {
      Directory plugin1Dir =
          createFakePlugin('plugin1', withExtraFiles: <List<String>>[
        <String>['ios', 'plugin1.podspec'],
        <String>['bogus.dart'], // Ignore non-podspecs.
      ]);

      processRunner.resultStdout = 'Foo';
      processRunner.resultStderr = 'Bar';

      await runner.run(<String>['podspecs']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('which', <String>['pod'], mockPackagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                p.join(plugin1Dir.path, 'ios', 'plugin1.podspec'),
                '--configuration=Debug',
                '--skip-tests',
                '--use-libraries'
              ],
              mockPackagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                p.join(plugin1Dir.path, 'ios', 'plugin1.podspec'),
                '--configuration=Debug',
                '--skip-tests',
              ],
              mockPackagesDir.path),
        ]),
      );

      expect(
          printedMessages, contains('Linting plugin1.podspec'));
      expect(printedMessages, contains('Foo'));
      expect(printedMessages, contains('Bar'));
    });

    test('skips podspecs with known issues', () async {
      createFakePlugin('plugin1', withExtraFiles: <List<String>>[
        <String>['plugin1.podspec']
      ]);
      createFakePlugin('plugin2', withExtraFiles: <List<String>>[
        <String>['plugin2.podspec']
      ]);

      await runner
          .run(<String>['podspecs', '--skip=plugin1', '--skip=plugin2']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('which', <String>['pod'], mockPackagesDir.path),
        ]),
      );
    });

    test('allow warnings for podspecs with known warnings', () async {
      Directory plugin1Dir =
          createFakePlugin('plugin1', withExtraFiles: <List<String>>[
        <String>['plugin1.podspec'],
      ]);

      await runner.run(<String>['podspecs', '--ignore-warnings=plugin1']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('which', <String>['pod'], mockPackagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                p.join(plugin1Dir.path, 'plugin1.podspec'),
                '--configuration=Debug',
                '--skip-tests',
                '--allow-warnings',
                '--use-libraries'
              ],
              mockPackagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                p.join(plugin1Dir.path, 'plugin1.podspec'),
                '--configuration=Debug',
                '--skip-tests',
                '--allow-warnings',
              ],
              mockPackagesDir.path),
        ]),
      );

      expect(
          printedMessages, contains('Linting plugin1.podspec'));
    });
  });
}

class MockPlatform extends Mock implements Platform {}
