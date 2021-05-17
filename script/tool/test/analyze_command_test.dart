// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/analyze_command.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  RecordingProcessRunner processRunner;
  CommandRunner<void> runner;

  setUp(() {
    initializeFakePackages();
    processRunner = RecordingProcessRunner();
    final AnalyzeCommand analyzeCommand = AnalyzeCommand(
        mockPackagesDir, mockFileSystem,
        processRunner: processRunner);

    runner = CommandRunner<void>('analyze_command', 'Test for analyze_command');
    runner.addCommand(analyzeCommand);
  });

  tearDown(() {
    mockPackagesDir.deleteSync(recursive: true);
  });

  test('analyzes all packages', () async {
    final Directory plugin1Dir = createFakePlugin('a');
    final Directory plugin2Dir = createFakePlugin('b');

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

  group('verifies analysis settings', () {
    test('fails analysis_options.yaml', () async {
      createFakePlugin('foo', withExtraFiles: <List<String>>[
        <String>['analysis_options.yaml']
      ]);

      await expectLater(() => runner.run(<String>['analyze']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('fails .analysis_options', () async {
      createFakePlugin('foo', withExtraFiles: <List<String>>[
        <String>['.analysis_options']
      ]);

      await expectLater(() => runner.run(<String>['analyze']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('takes an allow list', () async {
      final Directory pluginDir =
          createFakePlugin('foo', withExtraFiles: <List<String>>[
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
      createFakePlugin('foo', withExtraFiles: <List<String>>[
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
