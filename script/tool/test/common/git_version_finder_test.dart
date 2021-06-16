// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_plugin_tools/src/common/git_version_finder.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'plugin_command_test.mocks.dart';

void main() {
  late List<List<String>?> gitDirCommands;
  late String gitDiffResponse;
  late MockGitDir gitDir;
  String? mergeBaseResponse;

  setUp(() {
    gitDirCommands = <List<String>?>[];
    gitDiffResponse = '';
    gitDir = MockGitDir();
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      gitDirCommands.add(invocation.positionalArguments[0] as List<String>?);
      final MockProcessResult mockProcessResult = MockProcessResult();
      if (invocation.positionalArguments[0][0] == 'diff') {
        when<String?>(mockProcessResult.stdout as String?)
            .thenReturn(gitDiffResponse);
      } else if (invocation.positionalArguments[0][0] == 'merge-base') {
        when<String?>(mockProcessResult.stdout as String?)
            .thenReturn(mergeBaseResponse);
      }
      return Future<ProcessResult>.value(mockProcessResult);
    });
  });

  test('No git diff should result no files changed', () async {
    final GitVersionFinder finder = GitVersionFinder(gitDir, 'some base sha');
    final List<String> changedFiles = await finder.getChangedFiles();

    expect(changedFiles, isEmpty);
  });

  test('get correct files changed based on git diff', () async {
    gitDiffResponse = '''
file1/file1.cc
file2/file2.cc
''';
    final GitVersionFinder finder = GitVersionFinder(gitDir, 'some base sha');
    final List<String> changedFiles = await finder.getChangedFiles();

    expect(changedFiles, equals(<String>['file1/file1.cc', 'file2/file2.cc']));
  });

  test('get correct pubspec change based on git diff', () async {
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';
    final GitVersionFinder finder = GitVersionFinder(gitDir, 'some base sha');
    final List<String> changedFiles = await finder.getChangedPubSpecs();

    expect(changedFiles, equals(<String>['file1/pubspec.yaml']));
  });

  test('use correct base sha if not specified', () async {
    mergeBaseResponse = 'shaqwiueroaaidf12312jnadf123nd';
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';

    final GitVersionFinder finder = GitVersionFinder(gitDir, null);
    await finder.getChangedFiles();
    verify(gitDir.runCommand(
        <String>['diff', '--name-only', mergeBaseResponse!, 'HEAD']));
  });

  test('use correct base sha if specified', () async {
    const String customBaseSha = 'aklsjdcaskf12312';
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';
    final GitVersionFinder finder = GitVersionFinder(gitDir, customBaseSha);
    await finder.getChangedFiles();
    verify(gitDir
        .runCommand(<String>['diff', '--name-only', customBaseSha, 'HEAD']));
  });
}

class MockProcessResult extends Mock implements ProcessResult {}
