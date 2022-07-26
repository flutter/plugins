// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/dependabot_check_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late FileSystem fileSystem;
  late Directory root;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    root = fileSystem.currentDirectory;
    packagesDir = root.childDirectory('packages');

    final MockGitDir gitDir = MockGitDir();
    when(gitDir.path).thenReturn(root.path);

    final DependabotCheckCommand command = DependabotCheckCommand(
      packagesDir,
      gitDir: gitDir,
    );
    runner = CommandRunner<void>(
        'dependabot_test', 'Test for $DependabotCheckCommand');
    runner.addCommand(command);
  });

  void _setDependabotCoverage({
    Iterable<String> gradleDirs = const <String>[],
  }) {
    final Iterable<String> gradleEntries =
        gradleDirs.map((String directory) => '''
  - package-ecosystem: "gradle"
    directory: "/$directory"
    schedule:
      interval: "daily"
''');
    final File configFile =
        root.childDirectory('.github').childFile('dependabot.yml');
    configFile.createSync(recursive: true);
    configFile.writeAsStringSync('''
version: 2
updates:
${gradleEntries.join('\n')}
''');
  }

  test('skips with no supported ecosystems', () async {
    _setDependabotCoverage();
    createFakePackage('a_package', packagesDir);

    final List<String> output =
        await runCapturingPrint(runner, <String>['dependabot-check']);

    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('SKIPPING: No supported package ecosystems'),
        ]));
  });

  test('fails for app missing Gradle coverage', () async {
    _setDependabotCoverage();
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.directory
        .childDirectory('example')
        .childDirectory('android')
        .childDirectory('app')
        .createSync(recursive: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['dependabot-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing Gradle coverage.'),
          contains('a_package/example:\n'
              '    Missing Gradle coverage')
        ]));
  });

  test('fails for plugin missing Gradle coverage', () async {
    _setDependabotCoverage();
    final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir);
    plugin.directory.childDirectory('android').createSync(recursive: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['dependabot-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing Gradle coverage.'),
          contains('a_plugin:\n'
              '    Missing Gradle coverage')
        ]));
  });

  test('passes for correct Gradle coverage', () async {
    _setDependabotCoverage(gradleDirs: <String>[
      'packages/a_plugin/android',
      'packages/a_plugin/example/android/app',
    ]);
    final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir);
    // Test the plugin.
    plugin.directory.childDirectory('android').createSync(recursive: true);
    // And its example app.
    plugin.directory
        .childDirectory('example')
        .childDirectory('android')
        .childDirectory('app')
        .createSync(recursive: true);

    final List<String> output =
        await runCapturingPrint(runner, <String>['dependabot-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 2 package(s)')]));
  });
}
