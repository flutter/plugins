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

      runner = CommandRunner<Null>('get_changed_packages_command',
          'Test for $GetChangedPackagesCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      cleanupPackages();
    });

    test('No files changed should have empty output', () async {
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(output, isEmpty);
    });

    test('Some none plugin files changed have empty output', () async {
      gitDiffResponse = ".cirrus";
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(output, isEmpty);
    });

    test('plugin code changed should output the plugin', () async {
      gitDiffResponse = "packages/plugin1/plugin1.dart";
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(output, equals(['plugin1']));
    });

    test(
        'multiple files in one plugin changed should output the same plugin once',
        () async {
      gitDiffResponse = '''
packages/plugin1/plugin1.dart
packages/plugin1/ios/plugin1.m
''';
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(output, equals(['plugin1']));
    });

    test(
        'multiple plugins changed should output those plugins with , separated',
        () async {
      gitDiffResponse = '''
packages/plugin1/plugin1.dart
packages/plugin2/ios/plugin1.m
''';
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(output, equals(['plugin1,plugin2']));
    });

    test(
        'multiple plugins inside the same plugin group changed should output the plugin group name',
        () async {
      gitDiffResponse = '''
packages/plugin1/plugin1/plugin1.dart
packages/plugin1/plugin1_platform_interface/plugin1_platform_interface.dart
packages/plugin1/plugin1_web/plugin1_web.dart
''';
      final List<String> output = await runCapturingPrint(
          runner, <String>['get-changed-packages', '--base_sha=master']);

      expect(output, equals(['plugin1']));
    });
  });
}
