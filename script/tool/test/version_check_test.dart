// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/version_check_command.dart';
import 'package:git/git.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'util.dart';

void testAllowedVersion(
  String masterVersion,
  String headVersion, {
  bool allowed = true,
  NextVersionType nextVersionType,
}) {
  final Version master = Version.parse(masterVersion);
  final Version head = Version.parse(headVersion);
  final Map<Version, NextVersionType> allowedVersions =
      getAllowedNextVersions(master, head);
  if (allowed) {
    expect(allowedVersions, contains(head));
    if (nextVersionType != null) {
      expect(allowedVersions[head], equals(nextVersionType));
    }
  } else {
    expect(allowedVersions, isNot(contains(head)));
  }
}

class MockGitDir extends Mock implements GitDir {}

class MockProcessResult extends Mock implements io.ProcessResult {}

void main() {
  group('$VersionCheckCommand', () {
    CommandRunner<void> runner;
    RecordingProcessRunner processRunner;
    List<List<String>> gitDirCommands;
    String gitDiffResponse;
    Map<String, String> gitShowResponses;

    setUp(() {
      gitDirCommands = <List<String>>[];
      gitDiffResponse = '';
      gitShowResponses = <String, String>{};
      final MockGitDir gitDir = MockGitDir();
      when(gitDir.runCommand(any)).thenAnswer((Invocation invocation) {
        gitDirCommands.add(invocation.positionalArguments[0] as List<String>);
        final MockProcessResult mockProcessResult = MockProcessResult();
        if (invocation.positionalArguments[0][0] == 'diff') {
          when<String>(mockProcessResult.stdout as String)
              .thenReturn(gitDiffResponse);
        } else if (invocation.positionalArguments[0][0] == 'show') {
          final String response =
              gitShowResponses[invocation.positionalArguments[0][1]];
          if (response == null) {
            throw const io.ProcessException('git', <String>['show']);
          }
          when<String>(mockProcessResult.stdout as String).thenReturn(response);
        } else if (invocation.positionalArguments[0][0] == 'merge-base') {
          when<String>(mockProcessResult.stdout as String).thenReturn('abc123');
        }
        return Future<io.ProcessResult>.value(mockProcessResult);
      });
      initializeFakePackages();
      processRunner = RecordingProcessRunner();
      final VersionCheckCommand command = VersionCheckCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner, gitDir: gitDir);

      runner = CommandRunner<void>(
          'version_check_command', 'Test for $VersionCheckCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      cleanupPackages();
    });

    test('allows valid version', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin/pubspec.yaml';
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
        'HEAD:packages/plugin/pubspec.yaml': 'version: 2.0.0',
      };
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);

      expect(
        output,
        containsAllInOrder(<String>[
          'No version check errors found!',
        ]),
      );
      expect(gitDirCommands.length, equals(3));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>['diff', '--name-only', 'master', 'HEAD']),
            equals(<String>['show', 'master:packages/plugin/pubspec.yaml']),
            equals(<String>['show', 'HEAD:packages/plugin/pubspec.yaml']),
          ]));
    });

    test('denies invalid version', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin/pubspec.yaml';
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 0.0.1',
        'HEAD:packages/plugin/pubspec.yaml': 'version: 0.2.0',
      };
      final Future<List<String>> result = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
      expect(gitDirCommands.length, equals(3));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>['diff', '--name-only', 'master', 'HEAD']),
            equals(<String>['show', 'master:packages/plugin/pubspec.yaml']),
            equals(<String>['show', 'HEAD:packages/plugin/pubspec.yaml']),
          ]));
    });

    test('allows valid version without explicit base-sha', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin/pubspec.yaml';
      gitShowResponses = <String, String>{
        'abc123:packages/plugin/pubspec.yaml': 'version: 1.0.0',
        'HEAD:packages/plugin/pubspec.yaml': 'version: 2.0.0',
      };
      final List<String> output =
          await runCapturingPrint(runner, <String>['version-check']);

      expect(
        output,
        containsAllInOrder(<String>[
          'No version check errors found!',
        ]),
      );
    });

    test('allows valid version for new package.', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin/pubspec.yaml';
      gitShowResponses = <String, String>{
        'HEAD:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };
      final List<String> output =
          await runCapturingPrint(runner, <String>['version-check']);

      expect(
        output,
        containsAllInOrder(<String>[
          'No version check errors found!',
        ]),
      );
    });

    test('denies invalid version without explicit base-sha', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin/pubspec.yaml';
      gitShowResponses = <String, String>{
        'abc123:packages/plugin/pubspec.yaml': 'version: 0.0.1',
        'HEAD:packages/plugin/pubspec.yaml': 'version: 0.2.0',
      };
      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['version-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('gracefully handles missing pubspec.yaml', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin/pubspec.yaml';
      mockFileSystem.currentDirectory
          .childDirectory('packages')
          .childDirectory('plugin')
          .childFile('pubspec.yaml')
          .deleteSync();
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);

      expect(
        output,
        orderedEquals(<String>[
          'Determine diff with base sha: master',
          'Checking versions for packages/plugin/pubspec.yaml...',
          '  Deleted; skipping.',
          'No version check errors found!',
        ]),
      );
      expect(gitDirCommands.length, equals(1));
      expect(gitDirCommands.first.join(' '),
          equals('diff --name-only master HEAD'));
    });

    test('allows minor changes to platform interfaces', () async {
      createFakePlugin('plugin_platform_interface',
          includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin_platform_interface/pubspec.yaml';
      gitShowResponses = <String, String>{
        'master:packages/plugin_platform_interface/pubspec.yaml':
            'version: 1.0.0',
        'HEAD:packages/plugin_platform_interface/pubspec.yaml':
            'version: 1.1.0',
      };
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      expect(
        output,
        containsAllInOrder(<String>[
          'No version check errors found!',
        ]),
      );
      expect(gitDirCommands.length, equals(3));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>['diff', '--name-only', 'master', 'HEAD']),
            equals(<String>[
              'show',
              'master:packages/plugin_platform_interface/pubspec.yaml'
            ]),
            equals(<String>[
              'show',
              'HEAD:packages/plugin_platform_interface/pubspec.yaml'
            ]),
          ]));
    });

    test('disallows breaking changes to platform interfaces', () async {
      createFakePlugin('plugin_platform_interface',
          includeChangeLog: true, includeVersion: true);
      gitDiffResponse = 'packages/plugin_platform_interface/pubspec.yaml';
      gitShowResponses = <String, String>{
        'master:packages/plugin_platform_interface/pubspec.yaml':
            'version: 1.0.0',
        'HEAD:packages/plugin_platform_interface/pubspec.yaml':
            'version: 2.0.0',
      };
      final Future<List<String>> output = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        throwsA(const TypeMatcher<ToolExit>()),
      );
      expect(gitDirCommands.length, equals(3));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>['diff', '--name-only', 'master', 'HEAD']),
            equals(<String>[
              'show',
              'master:packages/plugin_platform_interface/pubspec.yaml'
            ]),
            equals(<String>[
              'show',
              'HEAD:packages/plugin_platform_interface/pubspec.yaml'
            ]),
          ]));
    });

    test('Allow empty lines in front of the first version in CHANGELOG',
        () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.1');
      const String changelog = '''



## 1.0.1

* Some changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      expect(
        output,
        containsAllInOrder(<String>[
          'Checking the first version listed in CHANGELOG.md matches the version in pubspec.yaml for plugin.',
          'plugin passed version check',
          'No version check errors found!'
        ]),
      );
    });

    test('Throws if versions in changelog and pubspec do not match', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.1');
      const String changelog = '''
## 1.0.2

* Some changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final Future<List<String>> output = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        throwsA(const TypeMatcher<ToolExit>()),
      );
      try {
        final List<String> outputValue = await output;
        await expectLater(
          outputValue,
          containsAllInOrder(<String>[
            '''
  versions for plugin in CHANGELOG.md and pubspec.yaml do not match.
  The version in pubspec.yaml is 1.0.1.
  The first version listed in CHANGELOG.md is 1.0.2.
  ''',
          ]),
        );
      } on ToolExit catch (_) {}
    });

    test('Success if CHANGELOG and pubspec versions match', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.1');
      const String changelog = '''
## 1.0.1

* Some changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      expect(
        output,
        containsAllInOrder(<String>[
          'Checking the first version listed in CHANGELOG.md matches the version in pubspec.yaml for plugin.',
          'plugin passed version check',
          'No version check errors found!'
        ]),
      );
    });

    test(
        'Fail if pubspec version only matches an older version listed in CHANGELOG',
        () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.0');
      const String changelog = '''
## 1.0.1

* Some changes.

## 1.0.0

* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final Future<List<String>> output = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        throwsA(const TypeMatcher<ToolExit>()),
      );
      try {
        final List<String> outputValue = await output;
        await expectLater(
          outputValue,
          containsAllInOrder(<String>[
            '''
  versions for plugin in CHANGELOG.md and pubspec.yaml do not match.
  The version in pubspec.yaml is 1.0.0.
  The first version listed in CHANGELOG.md is 1.0.1.
  ''',
          ]),
        );
      } on ToolExit catch (_) {}
    });

    test('Allow NEXT as a placeholder for gathering CHANGELOG entries',
        () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.0');
      const String changelog = '''
## NEXT

* Some changes that won't be published until the next time there's a release.

## 1.0.0

* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        containsAllInOrder(<String>[
          'Found NEXT; validating next version in the CHANGELOG.',
          'plugin passed version check',
          'No version check errors found!',
        ]),
      );
    });

    test('Fail if NEXT is left in the CHANGELOG when adding a version bump',
        () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.1');
      const String changelog = '''
## 1.0.1

* Some changes.

## NEXT

* Some changes that should have been folded in 1.0.1.

## 1.0.0

* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final Future<List<String>> output = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        throwsA(const TypeMatcher<ToolExit>()),
      );
      try {
        final List<String> outputValue = await output;
        await expectLater(
          outputValue,
          containsAllInOrder(<String>[
            '''
  versions for plugin in CHANGELOG.md and pubspec.yaml do not match.
  The version in pubspec.yaml is 1.0.0.
  The first version listed in CHANGELOG.md is 1.0.1.
  ''',
          ]),
        );
      } on ToolExit catch (_) {}
    });

    test('Fail if the version changes without replacing NEXT', () async {
      createFakePlugin('plugin', includeChangeLog: true, includeVersion: true);

      final Directory pluginDirectory =
          mockPackagesDir.childDirectory('plugin');

      createFakePubspec(pluginDirectory,
          isFlutter: true, includeVersion: true, version: '1.0.1');
      const String changelog = '''
## NEXT

* Some changes that should be listed as part of 1.0.1.

## 1.0.0

* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final Future<List<String>> output = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        throwsA(const TypeMatcher<ToolExit>()),
      );
      try {
        final List<String> outputValue = await output;
        await expectLater(
          outputValue,
          containsAllInOrder(<String>[
            '''
  versions for plugin in CHANGELOG.md and pubspec.yaml do not match.
  The version in pubspec.yaml is 1.0.0.
  The first version listed in CHANGELOG.md is 1.0.1.
  ''',
          ]),
        );
      } on ToolExit catch (_) {}
    });
  });

  group('Pre 1.0', () {
    test('nextVersion allows patch version', () {
      testAllowedVersion('0.12.0', '0.12.0+1',
          nextVersionType: NextVersionType.PATCH);
      testAllowedVersion('0.12.0+4', '0.12.0+5',
          nextVersionType: NextVersionType.PATCH);
    });

    test('nextVersion does not allow jumping patch', () {
      testAllowedVersion('0.12.0', '0.12.0+2', allowed: false);
      testAllowedVersion('0.12.0+2', '0.12.0+4', allowed: false);
    });

    test('nextVersion does not allow going back', () {
      testAllowedVersion('0.12.0', '0.11.0', allowed: false);
      testAllowedVersion('0.12.0+2', '0.12.0+1', allowed: false);
      testAllowedVersion('0.12.0+1', '0.12.0', allowed: false);
    });

    test('nextVersion allows minor version', () {
      testAllowedVersion('0.12.0', '0.12.1',
          nextVersionType: NextVersionType.MINOR);
      testAllowedVersion('0.12.0+4', '0.12.1',
          nextVersionType: NextVersionType.MINOR);
    });

    test('nextVersion does not allow jumping minor', () {
      testAllowedVersion('0.12.0', '0.12.2', allowed: false);
      testAllowedVersion('0.12.0+2', '0.12.3', allowed: false);
    });
  });

  group('Releasing 1.0', () {
    test('nextVersion allows releasing 1.0', () {
      testAllowedVersion('0.12.0', '1.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
      testAllowedVersion('0.12.0+4', '1.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
    });

    test('nextVersion does not allow jumping major', () {
      testAllowedVersion('0.12.0', '2.0.0', allowed: false);
      testAllowedVersion('0.12.0+4', '2.0.0', allowed: false);
    });

    test('nextVersion does not allow un-releasing', () {
      testAllowedVersion('1.0.0', '0.12.0+4', allowed: false);
      testAllowedVersion('1.0.0', '0.12.0', allowed: false);
    });
  });

  group('Post 1.0', () {
    test('nextVersion allows patch jumps', () {
      testAllowedVersion('1.0.1', '1.0.2',
          nextVersionType: NextVersionType.PATCH);
      testAllowedVersion('1.0.0', '1.0.1',
          nextVersionType: NextVersionType.PATCH);
    });

    test('nextVersion does not allow build jumps', () {
      testAllowedVersion('1.0.1', '1.0.1+1', allowed: false);
      testAllowedVersion('1.0.0+5', '1.0.0+6', allowed: false);
    });

    test('nextVersion does not allow skipping patches', () {
      testAllowedVersion('1.0.1', '1.0.3', allowed: false);
      testAllowedVersion('1.0.0', '1.0.6', allowed: false);
    });

    test('nextVersion allows minor version jumps', () {
      testAllowedVersion('1.0.1', '1.1.0',
          nextVersionType: NextVersionType.MINOR);
      testAllowedVersion('1.0.0', '1.1.0',
          nextVersionType: NextVersionType.MINOR);
    });

    test('nextVersion does not allow skipping minor versions', () {
      testAllowedVersion('1.0.1', '1.2.0', allowed: false);
      testAllowedVersion('1.1.0', '1.3.0', allowed: false);
    });

    test('nextVersion allows breaking changes', () {
      testAllowedVersion('1.0.1', '2.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
      testAllowedVersion('1.0.0', '2.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
    });

    test('nextVersion does not allow skipping major versions', () {
      testAllowedVersion('1.0.1', '3.0.0', allowed: false);
      testAllowedVersion('1.1.0', '2.3.0', allowed: false);
    });
  });
}
