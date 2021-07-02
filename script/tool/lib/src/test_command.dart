// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

/// A command to run Dart unit tests for packages.
class TestCommand extends PluginCommand {
  /// Creates an instance of the test command.
  TestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help: 'Runs the tests in Dart VM with the given experiments enabled.',
    );
  }

  @override
  final String name = 'test';

  @override
  final String description = 'Runs the Dart tests for all packages.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  Future<void> run() async {
    final List<String> failingPackages = <String>[];
    await for (final Directory packageDir in getPackages()) {
      final String packageName =
          p.relative(packageDir.path, from: packagesDir.path);
      if (!packageDir.childDirectory('test').existsSync()) {
        print('SKIPPING $packageName - no test subdirectory');
        continue;
      }

      print('RUNNING $packageName tests...');

      bool passed;
      if (isFlutterPackage(packageDir)) {
        passed = await _runFlutterTests(packageDir);
      } else {
        passed = await _runDartTests(packageDir);
      }
      if (!passed) {
        failingPackages.add(packageName);
      }
    }

    print('\n\n');
    if (failingPackages.isNotEmpty) {
      print('Tests for the following packages are failing (see above):');
      for (final String package in failingPackages) {
        print(' * $package');
      }
      throw ToolExit(1);
    }

    print('All tests are passing!');
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
