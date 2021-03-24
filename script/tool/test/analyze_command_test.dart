// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/analyze_command.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  RecordingProcessRunner processRunner;
  CommandRunner runner;

  setUp(() {
    initializeFakePackages();
    processRunner = RecordingProcessRunner();
    final AnalyzeCommand analyzeCommand = AnalyzeCommand(
        mockPackagesDir, mockFileSystem,
        processRunner: processRunner);

    runner = CommandRunner<Null>('analyze_command', 'Test for analyze_command');
    runner.addCommand(analyzeCommand);
  });

  tearDown(() {
    mockPackagesDir.deleteSync(recursive: true);
  });

  test('analyzes all packages', () async {
    final Directory plugin1Dir = await createFakePlugin('a');
    final Directory plugin2Dir = await createFakePlugin('b');

    final MockProcess mockProcess = MockProcess();
    mockProcess.exitCodeCompleter.complete(0);
    processRunner.processToReturn = mockProcess;
    await runner.run(<String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('pub', <String>['global', 'activate', 'tuneup'],
              mockPackagesDir.path),
          ProcessCall('flutter', <String>['packages', 'get'], plugin1Dir.path),
          ProcessCall('flutter', <String>['packages', 'get'], plugin2Dir.path),
          ProcessCall('pub', <String>['global', 'run', 'tuneup', 'check'],
              plugin1Dir.path),
          ProcessCall('pub', <String>['global', 'run', 'tuneup', 'check'],
              plugin2Dir.path),
        ]));
  });

  group('verifies analysis settings', () {
    test('fails analysis_options.yaml', () async {
      await createFakePlugin('foo', withExtraFiles: <List<String>>[
        <String>['analysis_options.yaml']
      ]);

      await expectLater(() => runner.run(<String>['analyze']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('fails .analysis_options', () async {
      await createFakePlugin('foo', withExtraFiles: <List<String>>[
        <String>['.analysis_options']
      ]);

      await expectLater(() => runner.run(<String>['analyze']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('takes an allow list', () async {
      final Directory pluginDir =
          await createFakePlugin('foo', withExtraFiles: <List<String>>[
        <String>['analysis_options.yaml']
      ]);

      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockProcess;
      await runner.run(<String>['analyze', '--custom-analysis', 'foo']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('pub', <String>['global', 'activate', 'tuneup'],
                mockPackagesDir.path),
            ProcessCall('flutter', <String>['packages', 'get'], pluginDir.path),
            ProcessCall('pub', <String>['global', 'run', 'tuneup', 'check'],
                pluginDir.path),
          ]));
    });

    // See: https://github.com/flutter/flutter/issues/78994
    test('takes an empty allow list', () async {
      await createFakePlugin('foo', withExtraFiles: <List<String>>[
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
