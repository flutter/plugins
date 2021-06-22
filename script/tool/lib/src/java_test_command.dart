// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/process_runner.dart';

/// A command to run the Java tests of Android plugins.
class JavaTestCommand extends PluginCommand {
  /// Creates an instance of the test runner.
  JavaTestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner);

  @override
  final String name = 'java-test';

  @override
  final String description = 'Runs the Java tests of the example apps.\n\n'
      'Building the apks of the example apps is required before executing this'
      'command.';

  static const String _gradleWrapper = 'gradlew';

  @override
  Future<void> run() async {
    final Stream<Directory> examplesWithTests = getExamples().where(
        (Directory d) =>
            isFlutterPackage(d) &&
            (d
                    .childDirectory('android')
                    .childDirectory('app')
                    .childDirectory('src')
                    .childDirectory('test')
                    .existsSync() ||
                d.parent
                    .childDirectory('android')
                    .childDirectory('src')
                    .childDirectory('test')
                    .existsSync()));

    final List<String> failingPackages = <String>[];
    final List<String> missingFlutterBuild = <String>[];
    await for (final Directory example in examplesWithTests) {
      final String packageName =
          p.relative(example.path, from: packagesDir.path);
      print('\nRUNNING JAVA TESTS for $packageName');

      final Directory androidDirectory = example.childDirectory('android');
      if (!androidDirectory.childFile(_gradleWrapper).existsSync()) {
        print('ERROR: Run "flutter build apk" on example app of $packageName'
            'before executing tests.');
        missingFlutterBuild.add(packageName);
        continue;
      }

      final int exitCode = await processRunner.runAndStream(
          p.join(androidDirectory.path, _gradleWrapper),
          <String>['testDebugUnitTest', '--info'],
          workingDir: androidDirectory);
      if (exitCode != 0) {
        failingPackages.add(packageName);
      }
    }

    print('\n\n');
    if (failingPackages.isNotEmpty) {
      print(
          'The Java tests for the following packages are failing (see above for'
          'details):');
      for (final String package in failingPackages) {
        print(' * $package');
      }
    }
    if (missingFlutterBuild.isNotEmpty) {
      print('Run "pub global run flutter_plugin_tools build-examples --apk" on'
          'the following packages before executing tests again:');
      for (final String package in missingFlutterBuild) {
        print(' * $package');
      }
    }

    if (failingPackages.isNotEmpty || missingFlutterBuild.isNotEmpty) {
      throw ToolExit(1);
    }

    print('All Java tests successful!');
  }
}
