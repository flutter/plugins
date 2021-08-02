// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

/// A command to run Dart unit tests for packages.
class TestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  TestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help:
          'Runs Dart unit tests in Dart VM with the given experiments enabled. '
          'See https://github.com/dart-lang/sdk/blob/master/docs/process/experimental-flags.md '
          'for details.',
    );
  }

  @override
  final String name = 'test';

  @override
  final String description = 'Runs the Dart tests for all packages.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  Future<PackageResult> runForPackage(Directory package) async {
    if (!package.childDirectory('test').existsSync()) {
      return PackageResult.skip('No test/ directory.');
    }

    bool passed;
    if (isFlutterPackage(package)) {
      passed = await _runFlutterTests(package);
    } else {
      passed = await _runDartTests(package);
    }
    return passed ? PackageResult.success() : PackageResult.fail();
  }

  /// Runs the Dart tests for a Flutter package, returning true on success.
  Future<bool> _runFlutterTests(Directory package) async {
    final String experiment = getStringArg(kEnableExperiment);

    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>[
        'test',
        '--color',
        if (experiment.isNotEmpty) '--enable-experiment=$experiment',
        // TODO(ditman): Remove this once all plugins are migrated to 'drive'.
        if (isWebPlugin(package)) '--platform=chrome',
      ],
      workingDir: package,
    );
    return exitCode == 0;
  }

  /// Runs the Dart tests for a non-Flutter package, returning true on success.
  Future<bool> _runDartTests(Directory package) async {
    // Unlike `flutter test`, `pub run test` does not automatically get
    // packages
    int exitCode = await processRunner.runAndStream(
      'dart',
      <String>['pub', 'get'],
      workingDir: package,
    );
    if (exitCode != 0) {
      printError('Unable to fetch dependencies.');
      return false;
    }

    final String experiment = getStringArg(kEnableExperiment);

    exitCode = await processRunner.runAndStream(
      'dart',
      <String>[
        'pub',
        'run',
        if (experiment.isNotEmpty) '--enable-experiment=$experiment',
        'test',
      ],
      workingDir: package,
    );

    return exitCode == 0;
  }
}
