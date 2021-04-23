// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/publish_check_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$PublishCheckProcessRunner tests', () {
    PublishCheckProcessRunner processRunner;
    CommandRunner<void> runner;

    setUp(() {
      initializeFakePackages();
      processRunner = PublishCheckProcessRunner();
      final PublishCheckCommand publishCheckCommand = PublishCheckCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(publishCheckCommand);
    });

    tearDown(() {
      mockPackagesDir.deleteSync(recursive: true);
    });

    test('publish check all packages', () async {
      final Directory plugin1Dir = createFakePlugin('a');
      final Directory plugin2Dir = createFakePlugin('b');

      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );
      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );
      await runner.run(<String>['publish-check']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin1Dir.path),
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin2Dir.path),
          ]));
    });

    test('fail on negative test', () async {
      createFakePlugin('a');

      final MockProcess process = MockProcess();
      process.stdoutController.close(); // ignore: unawaited_futures
      process.stderrController.close(); // ignore: unawaited_futures
      process.exitCodeCompleter.complete(1);

      processRunner.processesToReturn.add(process);

      expect(
        () => runner.run(<String>['publish-check']),
        throwsA(isA<ToolExit>()),
      );
    });

    test('fail on bad pubspec', () async {
      final Directory dir = createFakePlugin('c');
      await dir.childFile('pubspec.yaml').writeAsString('bad-yaml');

      final MockProcess process = MockProcess();
      processRunner.processesToReturn.add(process);

      expect(() => runner.run(<String>['publish-check']),
          throwsA(isA<ToolExit>()));
    });
  });
}

class PublishCheckProcessRunner extends RecordingProcessRunner {
  final Queue<MockProcess> processesToReturn = Queue<MockProcess>();

  @override
  io.Process get processToReturn => processesToReturn.removeFirst();
}
