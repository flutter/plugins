// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/analyze_command.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:test/test.dart';

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
    processRunner = RecordingProcessRunner();
    final AnalyzeCommand analyzeCommand =
        AnalyzeCommand(packagesDir, processRunner: processRunner);

    runner = CommandRunner<void>('analyze_command', 'Test for analyze_command');
    runner.addCommand(analyzeCommand);
  });

  test('analyzes all packages', () async {
    final Directory plugin1Dir = createFakePlugin('a', packagesDir);
    final Directory plugin2Dir = createFakePlugin('b', packagesDir);

    final MockProcess mockProcess = MockProcess();
    mockProcess.exitCodeCompleter.complete(0);
    processRunner.processToReturn = mockProcess;
    await runner.run(<String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['packages', 'get'], plugin1Dir.path),
          ProcessCall(
              'flutter', const <String>['packages', 'get'], plugin2Dir.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              plugin1Dir.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              plugin2Dir.path),
        ]));
  });

  test('skips flutter pub get for examples', () async {
    final Directory plugin1Dir = createFakePlugin('a', packagesDir);

    final MockProcess mockProcess = MockProcess();
    mockProcess.exitCodeCompleter.complete(0);
    processRunner.processToReturn = mockProcess;
    await runner.run(<String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['packages', 'get'], plugin1Dir.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              plugin1Dir.path),
        ]));
  });

  test('don\'t elide a non-contained example package', () async {
    final Directory plugin1Dir = createFakePlugin('a', packagesDir);
    final Directory plugin2Dir = createFakePlugin('example', packagesDir);

    final MockProcess mockProcess = MockProcess();
    mockProcess.exitCodeCompleter.complete(0);
    processRunner.processToReturn = mockProcess;
    await runner.run(<String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['packages', 'get'], plugin1Dir.path),
          ProcessCall(
              'flutter', const <String>['packages', 'get'], plugin2Dir.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              plugin1Dir.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              plugin2Dir.path),
        ]));
  });

  test('uses a separate analysis sdk', () async {
    final Directory pluginDir = createFakePlugin('a', packagesDir);

    final MockProcess mockProcess = MockProcess();
    mockProcess.exitCodeCompleter.complete(0);
    processRunner.processToReturn = mockProcess;
    await runner.run(<String>['analyze', '--analysis-sdk', 'foo/bar/baz']);

    expect(
      processRunner.recordedCalls,
      orderedEquals(<ProcessCall>[
        ProcessCall(
          'flutter',
          const <String>['packages', 'get'],
          pluginDir.path,
        ),
        ProcessCall(
          'foo/bar/baz/bin/dart',
          const <String>['analyze', '--fatal-infos'],
          pluginDir.path,
        ),
      ]),
    );
  });

  group('verifies analysis settings', () {
    test('fails analysis_options.yaml', () async {
      createFakePlugin('foo', packagesDir, extraFiles: <List<String>>[
        <String>['analysis_options.yaml']
      ]);

      await expectLater(() => runner.run(<String>['analyze']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('fails .analysis_options', () async {
      createFakePlugin('foo', packagesDir, extraFiles: <List<String>>[
        <String>['.analysis_options']
      ]);

      await expectLater(() => runner.run(<String>['analyze']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('takes an allow list', () async {
      final Directory pluginDir =
          createFakePlugin('foo', packagesDir, extraFiles: <List<String>>[
        <String>['analysis_options.yaml']
      ]);

      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockProcess;
      await runner.run(<String>['analyze', '--custom-analysis', 'foo']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'flutter', const <String>['packages', 'get'], pluginDir.path),
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                pluginDir.path),
          ]));
    });

    // See: https://github.com/flutter/flutter/issues/78994
    test('takes an empty allow list', () async {
      createFakePlugin('foo', packagesDir, extraFiles: <List<String>>[
        <String>['analysis_options.yaml']
      ]);

      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockProcess;

      await expectLater(
          () => runner.run(<String>['analyze', '--custom-analysis', '']),
          throwsA(const TypeMatcher<ToolExit>()));
    });
  });
}
