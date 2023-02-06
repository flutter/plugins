// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/package_looping_command.dart';
import 'package:flutter_plugin_tools/src/common/process_runner.dart';
import 'package:git/git.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../util.dart';
import 'package_command_test.mocks.dart';

// Constants for colorized output start and end.
const String _startElapsedTimeColor = '\x1B[90m';
const String _startErrorColor = '\x1B[31m';
const String _startHeadingColor = '\x1B[36m';
const String _startSkipColor = '\x1B[90m';
const String _startSkipWithWarningColor = '\x1B[93m';
const String _startSuccessColor = '\x1B[32m';
const String _startWarningColor = '\x1B[33m';
const String _endColor = '\x1B[0m';

// The filename within a package containing warnings to log during runForPackage.
enum _ResultFileType {
  /// A file containing errors to return.
  errors,

  /// A file containing warnings that should be logged.
  warns,

  /// A file indicating that the package should be skipped, and why.
  skips,

  /// A file indicating that the package should throw.
  throws,
}

// The filename within a package containing errors to return from runForPackage.
const String _errorFile = 'errors';
// The filename within a package indicating that it should be skipped.
const String _skipFile = 'skip';
// The filename within a package containing warnings to log during runForPackage.
const String _warningFile = 'warnings';
// The filename within a package indicating that it should throw.
const String _throwFile = 'throw';

/// Writes a file to [package] to control the behavior of
/// [TestPackageLoopingCommand] for that package.
void _addResultFile(RepositoryPackage package, _ResultFileType type,
    {String? contents}) {
  final File file = package.directory.childFile(_filenameForType(type));
  file.createSync();
  if (contents != null) {
    file.writeAsStringSync(contents);
  }
}

String _filenameForType(_ResultFileType type) {
  switch (type) {
    case _ResultFileType.errors:
      return _errorFile;
    case _ResultFileType.warns:
      return _warningFile;
    case _ResultFileType.skips:
      return _skipFile;
    case _ResultFileType.throws:
      return _throwFile;
  }
}

void main() {
  late FileSystem fileSystem;
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late Directory thirdPartyPackagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockPlatform = MockPlatform();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    thirdPartyPackagesDir = packagesDir.parent
        .childDirectory('third_party')
        .childDirectory('packages');
  });

  /// Creates a TestPackageLoopingCommand instance that uses [gitDiffResponse]
  /// for git diffs, and logs output to [printOutput].
  TestPackageLoopingCommand createTestCommand({
    String gitDiffResponse = '',
    bool hasLongOutput = true,
    PackageLoopingType packageLoopingType = PackageLoopingType.topLevelOnly,
    bool failsDuringInit = false,
    bool warnsDuringInit = false,
    bool warnsDuringCleanup = false,
    bool captureOutput = false,
    String? customFailureListHeader,
    String? customFailureListFooter,
  }) {
    // Set up the git diff response.
    final MockGitDir gitDir = MockGitDir();
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      final List<String> arguments =
          invocation.positionalArguments[0]! as List<String>;
      final MockProcessResult mockProcessResult = MockProcessResult();
      if (arguments[0] == 'diff') {
        when<String?>(mockProcessResult.stdout as String?)
            .thenReturn(gitDiffResponse);
      }
      return Future<io.ProcessResult>.value(mockProcessResult);
    });

    return TestPackageLoopingCommand(
      packagesDir,
      platform: mockPlatform,
      hasLongOutput: hasLongOutput,
      packageLoopingType: packageLoopingType,
      failsDuringInit: failsDuringInit,
      warnsDuringInit: warnsDuringInit,
      warnsDuringCleanup: warnsDuringCleanup,
      customFailureListHeader: customFailureListHeader,
      customFailureListFooter: customFailureListFooter,
      captureOutput: captureOutput,
      gitDir: gitDir,
    );
  }

  /// Runs [command] with the given [arguments], and returns its output.
  Future<List<String>> runCommand(
    TestPackageLoopingCommand command, {
    List<String> arguments = const <String>[],
    void Function(Error error)? errorHandler,
  }) async {
    late CommandRunner<void> runner;
    runner = CommandRunner<void>('test_package_looping_command',
        'Test for base package looping functionality');
    runner.addCommand(command);
    return runCapturingPrint(
      runner,
      <String>[command.name, ...arguments],
      errorHandler: errorHandler,
    );
  }

  group('tool exit', () {
    test('is handled during initializeRun', () async {
      final TestPackageLoopingCommand command =
          createTestCommand(failsDuringInit: true);

      expect(() => runCommand(command), throwsA(isA<ToolExit>()));
    });

    test('does not stop looping on error', () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage failingPackage =
          createFakePlugin('package_b', packagesDir);
      createFakePackage('package_c', packagesDir);
      _addResultFile(failingPackage, _ResultFileType.errors);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      Error? commandError;
      final List<String> output =
          await runCommand(command, errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startHeadingColor}Running for package_b...$_endColor',
            '${_startHeadingColor}Running for package_c...$_endColor',
          ]));
    });

    test('does not stop looping on exceptions', () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage failingPackage =
          createFakePlugin('package_b', packagesDir);
      createFakePackage('package_c', packagesDir);
      _addResultFile(failingPackage, _ResultFileType.throws);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      Error? commandError;
      final List<String> output =
          await runCommand(command, errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startHeadingColor}Running for package_b...$_endColor',
            '${_startHeadingColor}Running for package_c...$_endColor',
          ]));
    });
  });

  group('package iteration', () {
    test('includes plugins and packages', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand();
      await runCommand(command);

      expect(command.checkedPackages,
          unorderedEquals(<String>[plugin.path, package.path]));
    });

    test('includes third_party/packages', () async {
      final RepositoryPackage package1 =
          createFakePackage('a_package', packagesDir);
      final RepositoryPackage package2 =
          createFakePackage('another_package', thirdPartyPackagesDir);

      final TestPackageLoopingCommand command = createTestCommand();
      await runCommand(command);

      expect(command.checkedPackages,
          unorderedEquals(<String>[package1.path, package2.path]));
    });

    test('includes all subpackages when requested', () async {
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          examples: <String>['example1', 'example2']);
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      final RepositoryPackage subPackage = createFakePackage(
          'sub_package', package.directory,
          examples: <String>[]);

      final TestPackageLoopingCommand command = createTestCommand(
          packageLoopingType: PackageLoopingType.includeAllSubpackages);
      await runCommand(command);

      expect(
          command.checkedPackages,
          unorderedEquals(<String>[
            plugin.path,
            getExampleDir(plugin).childDirectory('example1').path,
            getExampleDir(plugin).childDirectory('example2').path,
            package.path,
            getExampleDir(package).path,
            subPackage.path,
          ]));
    });

    test('includes examples when requested', () async {
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          examples: <String>['example1', 'example2']);
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      final RepositoryPackage subPackage =
          createFakePackage('sub_package', package.directory);

      final TestPackageLoopingCommand command = createTestCommand(
          packageLoopingType: PackageLoopingType.includeExamples);
      await runCommand(command);

      expect(
          command.checkedPackages,
          unorderedEquals(<String>[
            plugin.path,
            getExampleDir(plugin).childDirectory('example1').path,
            getExampleDir(plugin).childDirectory('example2').path,
            package.path,
            getExampleDir(package).path,
          ]));
      expect(command.checkedPackages, isNot(contains(subPackage.path)));
    });

    test('excludes subpackages when main package is excluded', () async {
      final RepositoryPackage excluded = createFakePlugin(
          'a_plugin', packagesDir,
          examples: <String>['example1', 'example2']);
      final RepositoryPackage included =
          createFakePackage('a_package', packagesDir);
      final RepositoryPackage subpackage =
          createFakePackage('sub_package', excluded.directory);

      final TestPackageLoopingCommand command = createTestCommand(
          packageLoopingType: PackageLoopingType.includeAllSubpackages);
      await runCommand(command, arguments: <String>['--exclude=a_plugin']);

      final Iterable<RepositoryPackage> examples = excluded.getExamples();

      expect(
          command.checkedPackages,
          unorderedEquals(<String>[
            included.path,
            getExampleDir(included).path,
          ]));
      expect(command.checkedPackages, isNot(contains(excluded.path)));
      expect(examples.length, 2);
      for (final RepositoryPackage example in examples) {
        expect(command.checkedPackages, isNot(contains(example.path)));
      }
      expect(command.checkedPackages, isNot(contains(subpackage.path)));
    });

    test('excludes examples when main package is excluded', () async {
      final RepositoryPackage excluded = createFakePlugin(
          'a_plugin', packagesDir,
          examples: <String>['example1', 'example2']);
      final RepositoryPackage included =
          createFakePackage('a_package', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand(
          packageLoopingType: PackageLoopingType.includeExamples);
      await runCommand(command, arguments: <String>['--exclude=a_plugin']);

      final Iterable<RepositoryPackage> examples = excluded.getExamples();

      expect(
          command.checkedPackages,
          unorderedEquals(<String>[
            included.path,
            getExampleDir(included).path,
          ]));
      expect(command.checkedPackages, isNot(contains(excluded.path)));
      expect(examples.length, 2);
      for (final RepositoryPackage example in examples) {
        expect(command.checkedPackages, isNot(contains(example.path)));
      }
    });

    test('skips unsupported Flutter versions when requested', () async {
      final RepositoryPackage excluded = createFakePlugin(
          'a_plugin', packagesDir,
          flutterConstraint: '>=2.10.0');
      final RepositoryPackage included =
          createFakePackage('a_package', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand(
          packageLoopingType: PackageLoopingType.includeAllSubpackages,
          hasLongOutput: false);
      final List<String> output = await runCommand(command, arguments: <String>[
        '--skip-if-not-supporting-flutter-version=2.5.0'
      ]);

      expect(
          command.checkedPackages,
          unorderedEquals(<String>[
            included.path,
            getExampleDir(included).path,
          ]));
      expect(command.checkedPackages, isNot(contains(excluded.path)));

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for a_package...$_endColor',
            '${_startHeadingColor}Running for a_plugin...$_endColor',
            '$_startSkipColor  SKIPPING: Does not support Flutter 2.5.0$_endColor',
          ]));
    });

    test('skips unsupported Dart versions when requested', () async {
      final RepositoryPackage excluded = createFakePackage(
          'excluded_package', packagesDir,
          dartConstraint: '>=2.17.0 <3.0.0');
      final RepositoryPackage included =
          createFakePackage('a_package', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand(
          packageLoopingType: PackageLoopingType.includeAllSubpackages,
          hasLongOutput: false);
      final List<String> output = await runCommand(command,
          arguments: <String>['--skip-if-not-supporting-dart-version=2.14.0']);

      expect(
          command.checkedPackages,
          unorderedEquals(<String>[
            included.path,
            getExampleDir(included).path,
          ]));
      expect(command.checkedPackages, isNot(contains(excluded.path)));

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for a_package...$_endColor',
            '${_startHeadingColor}Running for excluded_package...$_endColor',
            '$_startSkipColor  SKIPPING: Does not support Dart 2.14.0$_endColor',
          ]));
    });
  });

  group('output', () {
    test('has the expected package headers for long-form output', () async {
      createFakePlugin('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand();
      final List<String> output = await runCommand(command);

      const String separator =
          '============================================================';
      expect(
          output,
          containsAllInOrder(<String>[
            '$_startHeadingColor\n$separator\n|| Running for package_a\n$separator\n$_endColor',
            '$_startHeadingColor\n$separator\n|| Running for package_b\n$separator\n$_endColor',
          ]));
    });

    test('has the expected package headers for short-form output', () async {
      createFakePlugin('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startHeadingColor}Running for package_b...$_endColor',
          ]));
    });

    test('prints timing info in long-form output when requested', () async {
      createFakePlugin('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand();
      final List<String> output =
          await runCommand(command, arguments: <String>['--log-timing']);

      const String separator =
          '============================================================';
      expect(
          output,
          containsAllInOrder(<String>[
            '$_startHeadingColor\n$separator\n|| Running for package_a [@0:00]\n$separator\n$_endColor',
            '$_startElapsedTimeColor\n[package_a completed in 0m 0s]$_endColor',
            '$_startHeadingColor\n$separator\n|| Running for package_b [@0:00]\n$separator\n$_endColor',
            '$_startElapsedTimeColor\n[package_b completed in 0m 0s]$_endColor',
          ]));
    });

    test('prints timing info in short-form output when requested', () async {
      createFakePlugin('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output =
          await runCommand(command, arguments: <String>['--log-timing']);

      expect(
          output,
          containsAllInOrder(<String>[
            '$_startHeadingColor[0:00] Running for package_a...$_endColor',
            '$_startHeadingColor[0:00] Running for package_b...$_endColor',
          ]));
      // Short-form output should not include elapsed time.
      expect(output, isNot(contains('[package_a completed in 0m 0s]')));
    });

    test('shows the success message when nothing fails', () async {
      createFakePackage('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '\n',
            '${_startSuccessColor}No issues found!$_endColor',
          ]));
    });

    test('shows failure summaries when something fails without extra details',
        () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage failingPackage1 =
          createFakePlugin('package_b', packagesDir);
      createFakePackage('package_c', packagesDir);
      final RepositoryPackage failingPackage2 =
          createFakePlugin('package_d', packagesDir);
      _addResultFile(failingPackage1, _ResultFileType.errors);
      _addResultFile(failingPackage2, _ResultFileType.errors);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      Error? commandError;
      final List<String> output =
          await runCommand(command, errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<String>[
            '\n',
            '${_startErrorColor}The following packages had errors:$_endColor',
            '$_startErrorColor  package_b$_endColor',
            '$_startErrorColor  package_d$_endColor',
            '${_startErrorColor}See above for full details.$_endColor',
          ]));
    });

    test('uses custom summary header and footer if provided', () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage failingPackage1 =
          createFakePlugin('package_b', packagesDir);
      createFakePackage('package_c', packagesDir);
      final RepositoryPackage failingPackage2 =
          createFakePlugin('package_d', packagesDir);
      _addResultFile(failingPackage1, _ResultFileType.errors);
      _addResultFile(failingPackage2, _ResultFileType.errors);

      final TestPackageLoopingCommand command = createTestCommand(
          hasLongOutput: false,
          customFailureListHeader: 'This is a custom header',
          customFailureListFooter: 'And a custom footer!');
      Error? commandError;
      final List<String> output =
          await runCommand(command, errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<String>[
            '\n',
            '${_startErrorColor}This is a custom header$_endColor',
            '$_startErrorColor  package_b$_endColor',
            '$_startErrorColor  package_d$_endColor',
            '${_startErrorColor}And a custom footer!$_endColor',
          ]));
    });

    test('shows failure summaries when something fails with extra details',
        () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage failingPackage1 =
          createFakePlugin('package_b', packagesDir);
      createFakePackage('package_c', packagesDir);
      final RepositoryPackage failingPackage2 =
          createFakePlugin('package_d', packagesDir);
      _addResultFile(failingPackage1, _ResultFileType.errors,
          contents: 'just one detail');
      _addResultFile(failingPackage2, _ResultFileType.errors,
          contents: 'first detail\nsecond detail');

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      Error? commandError;
      final List<String> output =
          await runCommand(command, errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<String>[
            '\n',
            '${_startErrorColor}The following packages had errors:$_endColor',
            '$_startErrorColor  package_b:\n    just one detail$_endColor',
            '$_startErrorColor  package_d:\n    first detail\n    second detail$_endColor',
            '${_startErrorColor}See above for full details.$_endColor',
          ]));
    });

    test('is captured, not printed, when requested', () async {
      createFakePlugin('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(captureOutput: true);
      final List<String> output = await runCommand(command);

      expect(output, isEmpty);

      // None of the output should be colorized when captured.
      const String separator =
          '============================================================';
      expect(
          command.capturedOutput,
          containsAllInOrder(<String>[
            '\n$separator\n|| Running for package_a\n$separator\n',
            '\n$separator\n|| Running for package_b\n$separator\n',
            'No issues found!',
          ]));
    });

    test('logs skips', () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage skipPackage =
          createFakePackage('package_b', packagesDir);
      _addResultFile(skipPackage, _ResultFileType.skips,
          contents: 'For a reason');

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startHeadingColor}Running for package_b...$_endColor',
            '$_startSkipColor  SKIPPING: For a reason$_endColor',
          ]));
    });

    test('logs exclusions', () async {
      createFakePackage('package_a', packagesDir);
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output =
          await runCommand(command, arguments: <String>['--exclude=package_b']);

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startSkipColor}Not running for package_b; excluded$_endColor',
          ]));
    });

    test('logs warnings', () async {
      final RepositoryPackage warnPackage =
          createFakePackage('package_a', packagesDir);
      _addResultFile(warnPackage, _ResultFileType.warns,
          contents: 'Warning 1\nWarning 2');
      createFakePackage('package_b', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startWarningColor}Warning 1$_endColor',
            '${_startWarningColor}Warning 2$_endColor',
            '${_startHeadingColor}Running for package_b...$_endColor',
          ]));
    });

    test('logs unhandled exceptions as errors', () async {
      createFakePackage('package_a', packagesDir);
      final RepositoryPackage failingPackage =
          createFakePlugin('package_b', packagesDir);
      createFakePackage('package_c', packagesDir);
      _addResultFile(failingPackage, _ResultFileType.throws);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      Error? commandError;
      final List<String> output =
          await runCommand(command, errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<String>[
            '${_startErrorColor}Exception: Uh-oh$_endColor',
            '${_startErrorColor}The following packages had errors:$_endColor',
            '$_startErrorColor  package_b:\n    Unhandled exception$_endColor',
          ]));
    });

    test('prints run summary on success', () async {
      final RepositoryPackage warnPackage1 =
          createFakePackage('package_a', packagesDir);
      _addResultFile(warnPackage1, _ResultFileType.warns,
          contents: 'Warning 1\nWarning 2');

      createFakePackage('package_b', packagesDir);

      final RepositoryPackage skipPackage =
          createFakePackage('package_c', packagesDir);
      _addResultFile(skipPackage, _ResultFileType.skips,
          contents: 'For a reason');

      final RepositoryPackage skipAndWarnPackage =
          createFakePackage('package_d', packagesDir);
      _addResultFile(skipAndWarnPackage, _ResultFileType.warns,
          contents: 'Warning');
      _addResultFile(skipAndWarnPackage, _ResultFileType.skips,
          contents: 'See warning');

      final RepositoryPackage warnPackage2 =
          createFakePackage('package_e', packagesDir);
      _addResultFile(warnPackage2, _ResultFileType.warns,
          contents: 'Warning 1\nWarning 2');

      createFakePackage('package_f', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '------------------------------------------------------------',
            'Ran for 4 package(s) (2 with warnings)',
            'Skipped 2 package(s) (1 with warnings)',
            '\n',
            '${_startSuccessColor}No issues found!$_endColor',
          ]));
      // The long-form summary should not be printed for short-form commands.
      expect(output, isNot(contains('Run summary:')));
      expect(output, isNot(contains(contains('package a - ran'))));
    });

    test('counts exclusions as skips in run summary', () async {
      createFakePackage('package_a', packagesDir);

      final TestPackageLoopingCommand command =
          createTestCommand(hasLongOutput: false);
      final List<String> output =
          await runCommand(command, arguments: <String>['--exclude=package_a']);

      expect(
          output,
          containsAllInOrder(<String>[
            '------------------------------------------------------------',
            'Skipped 1 package(s)',
            '\n',
            '${_startSuccessColor}No issues found!$_endColor',
          ]));
    });

    test('prints long-form run summary for long-output commands', () async {
      final RepositoryPackage warnPackage1 =
          createFakePackage('package_a', packagesDir);
      _addResultFile(warnPackage1, _ResultFileType.warns,
          contents: 'Warning 1\nWarning 2');

      createFakePackage('package_b', packagesDir);

      final RepositoryPackage skipPackage =
          createFakePackage('package_c', packagesDir);
      _addResultFile(skipPackage, _ResultFileType.skips,
          contents: 'For a reason');

      final RepositoryPackage skipAndWarnPackage =
          createFakePackage('package_d', packagesDir);
      _addResultFile(skipAndWarnPackage, _ResultFileType.warns,
          contents: 'Warning');
      _addResultFile(skipAndWarnPackage, _ResultFileType.skips,
          contents: 'See warning');

      final RepositoryPackage warnPackage2 =
          createFakePackage('package_e', packagesDir);
      _addResultFile(warnPackage2, _ResultFileType.warns,
          contents: 'Warning 1\nWarning 2');

      createFakePackage('package_f', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand();
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '------------------------------------------------------------',
            'Run overview:',
            '  package_a - ${_startWarningColor}ran (with warning)$_endColor',
            '  package_b - ${_startSuccessColor}ran$_endColor',
            '  package_c - ${_startSkipColor}skipped$_endColor',
            '  package_d - ${_startSkipWithWarningColor}skipped (with warning)$_endColor',
            '  package_e - ${_startWarningColor}ran (with warning)$_endColor',
            '  package_f - ${_startSuccessColor}ran$_endColor',
            '',
            'Ran for 4 package(s) (2 with warnings)',
            'Skipped 2 package(s) (1 with warnings)',
            '\n',
            '${_startSuccessColor}No issues found!$_endColor',
          ]));
    });

    test('prints exclusions as skips in long-form run summary', () async {
      createFakePackage('package_a', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand();
      final List<String> output =
          await runCommand(command, arguments: <String>['--exclude=package_a']);

      expect(
          output,
          containsAllInOrder(<String>[
            '  package_a - ${_startSkipColor}excluded$_endColor',
            '',
            'Skipped 1 package(s)',
            '\n',
            '${_startSuccessColor}No issues found!$_endColor',
          ]));
    });

    test('handles warnings outside of runForPackage', () async {
      createFakePackage('package_a', packagesDir);

      final TestPackageLoopingCommand command = createTestCommand(
        hasLongOutput: false,
        warnsDuringCleanup: true,
        warnsDuringInit: true,
      );
      final List<String> output = await runCommand(command);

      expect(
          output,
          containsAllInOrder(<String>[
            '${_startWarningColor}Warning during initializeRun$_endColor',
            '${_startHeadingColor}Running for package_a...$_endColor',
            '${_startWarningColor}Warning during completeRun$_endColor',
            '------------------------------------------------------------',
            'Ran for 1 package(s)',
            '2 warnings not associated with a package',
            '\n',
            '${_startSuccessColor}No issues found!$_endColor',
          ]));
    });
  });
}

class TestPackageLoopingCommand extends PackageLoopingCommand {
  TestPackageLoopingCommand(
    Directory packagesDir, {
    required Platform platform,
    this.hasLongOutput = true,
    this.packageLoopingType = PackageLoopingType.topLevelOnly,
    this.customFailureListHeader,
    this.customFailureListFooter,
    this.failsDuringInit = false,
    this.warnsDuringInit = false,
    this.warnsDuringCleanup = false,
    this.captureOutput = false,
    ProcessRunner processRunner = const ProcessRunner(),
    GitDir? gitDir,
  }) : super(packagesDir,
            processRunner: processRunner, platform: platform, gitDir: gitDir);

  final List<String> checkedPackages = <String>[];
  final List<String> capturedOutput = <String>[];

  final String? customFailureListHeader;
  final String? customFailureListFooter;

  final bool failsDuringInit;
  final bool warnsDuringInit;
  final bool warnsDuringCleanup;

  @override
  bool hasLongOutput;

  @override
  PackageLoopingType packageLoopingType;

  @override
  String get failureListHeader =>
      customFailureListHeader ?? super.failureListHeader;

  @override
  String get failureListFooter =>
      customFailureListFooter ?? super.failureListFooter;

  @override
  bool captureOutput;

  @override
  final String name = 'loop-test';

  @override
  final String description = 'sample package looping command';

  @override
  Future<void> initializeRun() async {
    if (warnsDuringInit) {
      logWarning('Warning during initializeRun');
    }
    if (failsDuringInit) {
      throw ToolExit(2);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    checkedPackages.add(package.path);
    final File warningFile = package.directory.childFile(_warningFile);
    if (warningFile.existsSync()) {
      final List<String> warnings = warningFile.readAsLinesSync();
      warnings.forEach(logWarning);
    }
    final File skipFile = package.directory.childFile(_skipFile);
    if (skipFile.existsSync()) {
      return PackageResult.skip(skipFile.readAsStringSync());
    }
    final File errorFile = package.directory.childFile(_errorFile);
    if (errorFile.existsSync()) {
      return PackageResult.fail(errorFile.readAsLinesSync());
    }
    final File throwFile = package.directory.childFile(_throwFile);
    if (throwFile.existsSync()) {
      throw Exception('Uh-oh');
    }
    return PackageResult.success();
  }

  @override
  Future<void> completeRun() async {
    if (warnsDuringInit) {
      logWarning('Warning during completeRun');
    }
  }

  @override
  Future<void> handleCapturedOutput(List<String> output) async {
    capturedOutput.addAll(output);
  }
}

class MockProcessResult extends Mock implements io.ProcessResult {}
