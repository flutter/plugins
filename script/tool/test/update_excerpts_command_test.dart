// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/update_excerpts_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    final MockGitDir gitDir = MockGitDir();
    when(gitDir.path).thenReturn(packagesDir.parent.path);
    processRunner = RecordingProcessRunner();
    final UpdateExcerptsCommand command = UpdateExcerptsCommand(
      packagesDir,
      processRunner: processRunner,
      platform: MockPlatform(),
      gitDir: gitDir,
    );

    runner = CommandRunner<void>(
        'update_excerpts_command', 'Test for update_excerpts_command');
    runner.addCommand(command);
  });

  test('runs pub get before running scripts', () async {
    final RepositoryPackage package = createFakePlugin('a_package', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);
    final Directory example = getExampleDir(package);

    await runCapturingPrint(runner, <String>['update-excerpts']);

    expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          ProcessCall('dart', const <String>['pub', 'get'], example.path),
          ProcessCall(
              'dart',
              const <String>[
                'run',
                'build_runner',
                'build',
                '--config',
                'excerpt',
                '--output',
                'excerpts',
                '--delete-conflicting-outputs',
              ],
              example.path),
        ]));
  });

  test('runs when config is present', () async {
    final RepositoryPackage package = createFakePlugin('a_package', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);
    final Directory example = getExampleDir(package);

    final List<String> output =
        await runCapturingPrint(runner, <String>['update-excerpts']);

    expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          ProcessCall(
              'dart',
              const <String>[
                'run',
                'build_runner',
                'build',
                '--config',
                'excerpt',
                '--output',
                'excerpts',
                '--delete-conflicting-outputs',
              ],
              example.path),
          ProcessCall(
              'dart',
              const <String>[
                'run',
                'code_excerpt_updater',
                '--write-in-place',
                '--yaml',
                '--no-escape-ng-interpolation',
                '../README.md',
              ],
              example.path),
        ]));

    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Ran for 1 package(s)'),
        ]));
  });

  test('skips when no config is present', () async {
    createFakePlugin('a_package', packagesDir);

    final List<String> output =
        await runCapturingPrint(runner, <String>['update-excerpts']);

    expect(processRunner.recordedCalls, isEmpty);

    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Skipped 1 package(s)'),
        ]));
  });

  test('restores pubspec even if running the script fails', () async {
    final RepositoryPackage package = createFakePlugin('a_package', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);

    processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
      MockProcess(exitCode: 1), // dart pub get
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts'], errorHandler: (Error e) {
      commandError = e;
    });

    // Check that it's definitely a failure in a step between making the changes
    // and restoring the original.
    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('a_package:\n'
              '    Unable to get script dependencies')
        ]));

    final String examplePubspecContent =
        package.getExamples().first.pubspecFile.readAsStringSync();
    expect(examplePubspecContent, isNot(contains('code_excerpter')));
    expect(examplePubspecContent, isNot(contains('code_excerpt_updater')));
  });

  test('fails if pub get fails', () async {
    createFakePlugin('a_package', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);

    processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
      MockProcess(exitCode: 1), // dart pub get
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('a_package:\n'
              '    Unable to get script dependencies')
        ]));
  });

  test('fails if extraction fails', () async {
    createFakePlugin('a_package', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);

    processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
      MockProcess(), // dart pub get
      MockProcess(exitCode: 1), // dart run build_runner ...
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('a_package:\n'
              '    Unable to extract excerpts')
        ]));
  });

  test('fails if injection fails', () async {
    createFakePlugin('a_package', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);

    processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
      MockProcess(), // dart pub get
      MockProcess(), // dart run build_runner ...
      MockProcess(exitCode: 1), // dart run code_excerpt_updater ...
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('a_package:\n'
              '    Unable to inject excerpts')
        ]));
  });

  test('fails if files are changed with --fail-on-change', () async {
    createFakePlugin('a_plugin', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);

    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess(stdout: changedFilePath),
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts', '--fail-on-change'],
        errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('README.md is out of sync with its source excerpts'),
        ]));
  });

  test('fails if git ls-files fails', () async {
    createFakePlugin('a_plugin', packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath]);

    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess(exitCode: 1)
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts', '--fail-on-change'],
        errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to determine local file state'),
        ]));
  });
}
