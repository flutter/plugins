// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:git/git.dart';
import 'package:mockito/mockito.dart';
import "package:test/test.dart";
import "package:flutter_plugin_tools/src/get_changed_packages_command.dart";
import 'util.dart';

class MockGitDir extends Mock implements GitDir {}

class MockProcessResult extends Mock implements ProcessResult {}

void main() {
  group('$GetChangedPackagesCommand', () {
    CommandRunner<GetChangedPackagesCommand> runner;
    RecordingProcessRunner processRunner;
    List<List<String>> gitDirCommands;
    String gitDiffResponse;

    setUp(() {
      gitDirCommands = <List<String>>[];
      gitDiffResponse = '';
      final MockGitDir gitDir = MockGitDir();
      when(gitDir.runCommand(any)).thenAnswer((Invocation invocation) {
        gitDirCommands.add(invocation.positionalArguments[0]);
        final MockProcessResult mockProcessResult = MockProcessResult();
        if (invocation.positionalArguments[0][0] == 'diff') {
          when<String>(mockProcessResult.stdout).thenReturn(gitDiffResponse);
        }
        return Future<ProcessResult>.value(mockProcessResult);
      });
      initializeFakePackages();
      processRunner = RecordingProcessRunner();
      final GetChangedPackagesCommand command = GetChangedPackagesCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner, gitDir: gitDir);

      runner = CommandRunner<Null>(
          'get_changed_packages_command', 'Test for $GetChangedPackagesCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      cleanupPackages();
    });

    test('No plugins changed', () async {
      gitDiffResponse = ".cirrus";
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(
        output, isEmpty
      );
    });
  });
}
