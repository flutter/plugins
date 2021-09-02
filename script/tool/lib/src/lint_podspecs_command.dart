// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

const int _exitUnsupportedPlatform = 2;
const int _exitPodNotInstalled = 3;

/// Lint the CocoaPod podspecs and run unit tests.
///
/// See https://guides.cocoapods.org/terminal/commands.html#pod_lib_lint.
class LintPodspecsCommand extends PackageLoopingCommand {
  /// Creates an instance of the linter command.
  LintPodspecsCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addMultiOption('ignore-warnings',
        help:
            'Do not pass --allow-warnings flag to "pod lib lint" for podspecs '
            'with this basename (example: plugins with known warnings)',
        valueHelp: 'podspec_file_name');
  }

  @override
  final String name = 'podspecs';

  @override
  List<String> get aliases => <String>['podspec'];

  @override
  final String description =
      'Runs "pod lib lint" on all iOS and macOS plugin podspecs.\n\n'
      'This command requires "pod" and "flutter" to be in your path. Runs on macOS only.';

  @override
  Future<void> initializeRun() async {
    if (!platform.isMacOS) {
      printError('This command is only supported on macOS');
      throw ToolExit(_exitUnsupportedPlatform);
    }

    final ProcessResult result = await processRunner.run(
      'which',
      <String>['pod'],
      workingDir: packagesDir,
      logOnError: true,
    );
    if (result.exitCode != 0) {
      printError('Unable to find "pod". Make sure it is in your path.');
      throw ToolExit(_exitPodNotInstalled);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> errors = <String>[];

    final List<File> podspecs = await _podspecsToLint(package);
    if (podspecs.isEmpty) {
      return PackageResult.skip('No podspecs.');
    }

    for (final File podspec in podspecs) {
      if (!await _lintPodspec(podspec)) {
        errors.add(p.basename(podspec.path));
      }
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  Future<List<File>> _podspecsToLint(RepositoryPackage package) async {
    final List<File> podspecs =
        await getFilesForPackage(package).where((File entity) {
      final String filePath = entity.path;
      return path.extension(filePath) == '.podspec';
    }).toList();

    podspecs.sort((File a, File b) => a.basename.compareTo(b.basename));
    return podspecs;
  }

  Future<bool> _lintPodspec(File podspec) async {
    // Do not run the static analyzer on plugins with known analyzer issues.
    final String podspecPath = podspec.path;

    final String podspecBasename = p.basename(podspecPath);
    print('Linting $podspecBasename');

    // Lint plugin as framework (use_frameworks!).
    final ProcessResult frameworkResult =
        await _runPodLint(podspecPath, libraryLint: true);
    print(frameworkResult.stdout);
    print(frameworkResult.stderr);

    // Lint plugin as library.
    final ProcessResult libraryResult =
        await _runPodLint(podspecPath, libraryLint: false);
    print(libraryResult.stdout);
    print(libraryResult.stderr);

    return frameworkResult.exitCode == 0 && libraryResult.exitCode == 0;
  }

  Future<ProcessResult> _runPodLint(String podspecPath,
      {required bool libraryLint}) async {
    final bool allowWarnings = (getStringListArg('ignore-warnings'))
        .contains(p.basenameWithoutExtension(podspecPath));
    final List<String> arguments = <String>[
      'lib',
      'lint',
      podspecPath,
      '--configuration=Debug', // Release targets unsupported arm64 simulators. Use Debug to only build against targeted x86_64 simulator devices.
      '--skip-tests',
      '--use-modular-headers', // Flutter sets use_modular_headers! in its templates.
      if (allowWarnings) '--allow-warnings',
      if (libraryLint) '--use-libraries'
    ];

    print('Running "pod ${arguments.join(' ')}"');
    return processRunner.run('pod', arguments,
        workingDir: packagesDir, stdoutEncoding: utf8, stderrEncoding: utf8);
  }
}
