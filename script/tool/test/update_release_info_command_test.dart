// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/update_release_info_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;
  late MockGitDir gitDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    processRunner = RecordingProcessRunner();

    gitDir = MockGitDir();
    when(gitDir.path).thenReturn(packagesDir.parent.path);
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      final List<String> arguments =
          invocation.positionalArguments[0]! as List<String>;
      // Route git calls through a process runner, to make mock output
      // consistent with other processes. Attach the first argument to the
      // command to make targeting the mock results easier.
      final String gitCommand = arguments.removeAt(0);
      return processRunner.run('git-$gitCommand', arguments);
    });

    final UpdateReleaseInfoCommand command = UpdateReleaseInfoCommand(
      packagesDir,
      gitDir: gitDir,
    );
    runner = CommandRunner<void>(
        'update_release_info_command', 'Test for update_release_info_command');
    runner.addCommand(command);
  });

  group('flags', () {
    test('fails if --changelog is missing', () async {
      Exception? commandError;
      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
      ], exceptionHandler: (Exception e) {
        commandError = e;
      });

      expect(commandError, isA<UsageException>());
    });

    test('fails if --changelog is blank', () async {
      Exception? commandError;
      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
        '--changelog',
        '',
      ], exceptionHandler: (Exception e) {
        commandError = e;
      });

      expect(commandError, isA<UsageException>());
    });

    test('fails if --version is missing', () async {
      Exception? commandError;
      await runCapturingPrint(
          runner, <String>['update-release-info', '--changelog', ''],
          exceptionHandler: (Exception e) {
        commandError = e;
      });

      expect(commandError, isA<UsageException>());
    });

    test('fails if --version is an unknown value', () async {
      Exception? commandError;
      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=foo',
        '--changelog',
        '',
      ], exceptionHandler: (Exception e) {
        commandError = e;
      });

      expect(commandError, isA<UsageException>());
    });
  });

  group('changelog', () {
    test('adds new NEXT section', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## 1.0.0

* Previous changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
        '--changelog',
        'A change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## NEXT

* A change.

$originalChangelog''';

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('  Added a NEXT section.'),
        ]),
      );
      expect(newChangelog, expectedChangeLog);
    });

    test('adds to existing NEXT section', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## NEXT

* Already-pending changes.

## 1.0.0

* Old changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
        '--changelog',
        'A change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## NEXT

* A change.
* Already-pending changes.

## 1.0.0

* Old changes.
''';

      expect(output,
          containsAllInOrder(<Matcher>[contains('  Updated NEXT section.')]));
      expect(newChangelog, expectedChangeLog);
    });

    test('adds new version section', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## 1.0.0

* Previous changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'A change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## 1.0.1

* A change.

$originalChangelog''';

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('  Added a 1.0.1 section.'),
        ]),
      );
      expect(newChangelog, expectedChangeLog);
    });

    test('converts existing NEXT section to version section', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## NEXT

* Already-pending changes.

## 1.0.0

* Old changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'A change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## 1.0.1

* A change.
* Already-pending changes.

## 1.0.0

* Old changes.
''';

      expect(output,
          containsAllInOrder(<Matcher>[contains('  Updated NEXT section.')]));
      expect(newChangelog, expectedChangeLog);
    });

    test('treats multiple lines as multiple list items', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## 1.0.0

* Previous changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'First change.\nSecond change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## 1.0.1

* First change.
* Second change.

$originalChangelog''';

      expect(newChangelog, expectedChangeLog);
    });

    test('adds a period to any lines missing it, and removes whitespace',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## 1.0.0

* Previous changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'First change  \nSecond change'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## 1.0.1

* First change.
* Second change.

$originalChangelog''';

      expect(newChangelog, expectedChangeLog);
    });

    test('handles non-standard changelog format', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
# 1.0.0

* A version with the wrong heading format.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
        '--changelog',
        'A change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## NEXT

* A change.

$originalChangelog''';

      expect(output,
          containsAllInOrder(<Matcher>[contains('  Added a NEXT section.')]));
      expect(newChangelog, expectedChangeLog);
    });

    test('adds to existing NEXT section using - list style', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## NEXT

 - Already-pending changes.

## 1.0.0

 - Previous changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
        '--changelog',
        'A change.'
      ]);

      final String newChangelog = package.changelogFile.readAsStringSync();
      const String expectedChangeLog = '''
## NEXT

 - A change.
 - Already-pending changes.

## 1.0.0

 - Previous changes.
''';

      expect(output,
          containsAllInOrder(<Matcher>[contains('  Updated NEXT section.')]));
      expect(newChangelog, expectedChangeLog);
    });

    test('skips for "minimal" when there are no changes at all', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.1');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: '''
packages/different_package/test/plugin_test.dart
'''),
      ];
      final String originalChangelog = package.changelogFile.readAsStringSync();

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minimal',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '1.0.1');
      expect(package.changelogFile.readAsStringSync(), originalChangelog);
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No changes to package'),
            contains('Skipped 1 package')
          ]));
    });

    test('fails if CHANGELOG.md is missing', () async {
      createFakePackage('a_package', packagesDir, includeCommonFiles: false);

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minor',
        '--changelog',
        'A change.',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(output,
          containsAllInOrder(<Matcher>[contains('  Missing CHANGELOG.md.')]));
    });

    test('fails if CHANGELOG.md has unexpected NEXT block format', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      const String originalChangelog = '''
## NEXT

Some free-form text that isn't a list.

## 1.0.0

- Previous changes.
''';
      package.changelogFile.writeAsStringSync(originalChangelog);

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minor',
        '--changelog',
        'A change.',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('  Existing NEXT section has unrecognized format.')
          ]));
    });
  });

  group('pubspec', () {
    test('does not change for --next', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.0');

      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=next',
        '--changelog',
        'A change.'
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '1.0.0');
    });

    test('updates bugfix version for pre-1.0 without existing build number',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '0.1.0');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '0.1.0+1');
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('  Incremented version to 0.1.0+1')]));
    });

    test('updates bugfix version for pre-1.0 with existing build number',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '0.1.0+2');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '0.1.0+3');
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('  Incremented version to 0.1.0+3')]));
    });

    test('updates bugfix version for post-1.0', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.1');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=bugfix',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '1.0.2');
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('  Incremented version to 1.0.2')]));
    });

    test('updates minor version for pre-1.0', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '0.1.0+2');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minor',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '0.1.1');
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('  Incremented version to 0.1.1')]));
    });

    test('updates minor version for post-1.0', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.1');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minor',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '1.1.0');
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('  Incremented version to 1.1.0')]));
    });

    test('updates bugfix version for "minimal" with publish-worthy changes',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.1');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: '''
packages/a_package/lib/plugin.dart
'''),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minimal',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '1.0.2');
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('  Incremented version to 1.0.2')]));
    });

    test('no version change for "minimal" with non-publish-worthy changes',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '1.0.1');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: '''
packages/a_package/test/plugin_test.dart
'''),
      ];

      await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minimal',
        '--changelog',
        'A change.',
      ]);

      final String version = package.parsePubspec().version?.toString() ?? '';
      expect(version, '1.0.1');
    });

    test('fails if there is no version in pubspec', () async {
      createFakePackage('a_package', packagesDir, version: null);

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-release-info',
        '--version=minor',
        '--changelog',
        'A change.',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
              <Matcher>[contains('Could not determine current version.')]));
    });
  });
}
