// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

/// A command to run Dart unit tests for packages.
class TestCommand extends PluginCommand {
  /// Creates an instance of the test command.
  TestCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
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
      if (!fileSystem.directory(p.join(packageDir.path, 'test')).existsSync()) {
        print('SKIPPING $packageName - no test subdirectory');
        continue;
      }

      print('RUNNING $packageName tests...');

      final String enableExperiment = argResults[kEnableExperiment] as String;

      // `flutter test` automatically gets packages.  `pub run test` does not.  :(
      int exitCode = 0;
      if (isFlutterPackage(packageDir, fileSystem)) {
        final List<String> args = <String>[
          'test',
          '--color',
          if (enableExperiment.isNotEmpty)
            '--enable-experiment=$enableExperiment',
        ];

        if (isWebPlugin(packageDir, fileSystem)) {
          args.add('--platform=chrome');
        }
        exitCode = await processRunner.runAndStream(
          'flutter',
          args,
          workingDir: packageDir,
        );
      } else {
        exitCode = await processRunner.runAndStream(
          'pub',
          <String>['get'],
          workingDir: packageDir,
        );
        if (exitCode == 0) {
          exitCode = await processRunner.runAndStream(
            'pub',
            <String>[
              'run',
              if (enableExperiment.isNotEmpty)
                '--enable-experiment=$enableExperiment',
              'test',
            ],
            workingDir: packageDir,
          );
        }
      }
      if (exitCode != 0) {
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
}
