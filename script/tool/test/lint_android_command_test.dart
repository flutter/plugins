// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/lint_android_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$LintAndroidCommand', () {
    FileSystem fileSystem;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late MockPlatform mockPlatform;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem(style: FileSystemStyle.posix);
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      mockPlatform = MockPlatform();
      processRunner = RecordingProcessRunner();
      final LintAndroidCommand command = LintAndroidCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
          'lint_android_test', 'Test for $LintAndroidCommand');
      runner.addCommand(command);
    });

    test('runs gradle lint', () async {
      final Directory pluginDir =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });

      final Directory androidDir =
          pluginDir.childDirectory('example').childDirectory('android');

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            androidDir.childFile('gradlew').path,
            const <String>['plugin1:lintDebug'],
            androidDir.path,
          ),
        ]),
      );

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin1'),
            contains('No issues found!'),
          ]));
    });

    test('fails if gradlew is missing', () async {
      createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['lint-android'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Build example before linting'),
            ],
          ));
    });

    test('fails if linting finds issues', () async {
      createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });

      processRunner.mockProcessesForExecutable['gradlew'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['lint-android'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Build example before linting'),
            ],
          ));
    });

    test('skips non-Android plugins', () async {
      createFakePlugin('plugin1', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(
                  'SKIPPING: Plugin does not have an Android implemenatation.')
            ],
          ));
    });

    test('skips non-inline plugins', () async {
      createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.federated)
          });

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(
                  'SKIPPING: Plugin does not have an Android implemenatation.')
            ],
          ));
    });
  });
}
