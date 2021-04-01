// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common.dart';

typedef Print = void Function(Object object);

/// Lint the CocoaPod podspecs and run unit tests.
///
/// See https://guides.cocoapods.org/terminal/commands.html#pod_lib_lint.
class LintPodspecsCommand extends PluginCommand {
  LintPodspecsCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
    this.platform = const LocalPlatform(),
    Print print = print,
  })  : _print = print,
        super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addMultiOption('skip',
        help:
            'Skip all linting for podspecs with this basename (example: federated plugins with placeholder podspecs)',
        valueHelp: 'podspec_file_name');
    argParser.addMultiOption('ignore-warnings',
        help:
            'Do not pass --allow-warnings flag to "pod lib lint" for podspecs with this basename (example: plugins with known warnings)',
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

  final Platform platform;

  final Print _print;

  @override
  Future<void> run() async {
    if (!platform.isMacOS) {
      _print('Detected platform is not macOS, skipping podspec lint');
      return;
    }

    checkSharding();

    await processRunner.runAndExitOnError('which', <String>['pod'],
        workingDir: packagesDir);

    _print('Starting podspec lint test');

    final List<String> failingPlugins = <String>[];
    for (final File podspec in await _podspecsToLint()) {
      if (!await _lintPodspec(podspec)) {
        failingPlugins.add(p.basenameWithoutExtension(podspec.path));
      }
    }

    _print('\n\n');
    if (failingPlugins.isNotEmpty) {
      _print('The following plugins have podspec errors (see above):');
      failingPlugins.forEach((String plugin) {
        _print(' * $plugin');
      });
      throw ToolExit(1);
    }
  }

  Future<List<File>> _podspecsToLint() async {
    final List<File> podspecs = await getFiles().where((File entity) {
      final String filePath = entity.path;
      return p.extension(filePath) == '.podspec' &&
          !(argResults['skip'] as List<String>)
              .contains(p.basenameWithoutExtension(filePath));
    }).toList();

    podspecs.sort(
        (File a, File b) => p.basename(a.path).compareTo(p.basename(b.path)));
    return podspecs;
  }

  Future<bool> _lintPodspec(File podspec) async {
    // Do not run the static analyzer on plugins with known analyzer issues.
    final String podspecPath = podspec.path;

    final String podspecBasename = p.basename(podspecPath);
    _print('Linting $podspecBasename');

    // Lint plugin as framework (use_frameworks!).
    final ProcessResult frameworkResult =
        await _runPodLint(podspecPath, libraryLint: true);
    _print(frameworkResult.stdout);
    _print(frameworkResult.stderr);

    // Lint plugin as library.
    final ProcessResult libraryResult =
        await _runPodLint(podspecPath, libraryLint: false);
    _print(libraryResult.stdout);
    _print(libraryResult.stderr);

    return frameworkResult.exitCode == 0 && libraryResult.exitCode == 0;
  }

  Future<ProcessResult> _runPodLint(String podspecPath,
      {bool libraryLint}) async {
    final bool allowWarnings = (argResults['ignore-warnings'] as List<String>)
        .contains(p.basenameWithoutExtension(podspecPath));
    final List<String> arguments = <String>[
      'lib',
      'lint',
      podspecPath,
      '--configuration=Debug', // Release targets unsupported arm64 simulators. Use Debug to only build against targeted x86_64 simulator devices.
      '--skip-tests',
      if (allowWarnings) '--allow-warnings',
      if (libraryLint) '--use-libraries'
    ];

    _print('Running "pod ${arguments.join(' ')}"');
    return processRunner.run('pod', arguments,
        workingDir: packagesDir, stdoutEncoding: utf8, stderrEncoding: utf8);
  }
}
