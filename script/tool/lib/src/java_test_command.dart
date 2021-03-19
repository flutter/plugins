// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

class JavaTestCommand extends PluginCommand {
  JavaTestCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner);

  @override
  final String name = 'java-test';

  @override
  final String description = 'Runs the Java tests of the example apps.\n\n'
      'Building the apks of the example apps is required before executing this'
      'command.';

  static const String _gradleWrapper = 'gradlew';

  @override
  Future<Null> run() async {
    checkSharding();
    final Stream<Directory> examplesWithTests = getExamples().where(
        (Directory d) =>
            isFlutterPackage(d, fileSystem) &&
            fileSystem
                .directory(p.join(d.path, 'android', 'app', 'src', 'test'))
                .existsSync());

    final List<String> failingPackages = <String>[];
    final List<String> missingFlutterBuild = <String>[];
    await for (Directory example in examplesWithTests) {
      final String packageName =
          p.relative(example.path, from: packagesDir.path);
      print('\nRUNNING JAVA TESTS for $packageName');

      final Directory androidDirectory =
          fileSystem.directory(p.join(example.path, 'android'));
      if (!fileSystem
          .file(p.join(androidDirectory.path, _gradleWrapper))
          .existsSync()) {
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
      for (String package in failingPackages) {
        print(' * $package');
      }
    }
    if (missingFlutterBuild.isNotEmpty) {
      print('Run "pub global run flutter_plugin_tools build-examples --apk" on'
          'the following packages before executing tests again:');
      for (String package in missingFlutterBuild) {
        print(' * $package');
      }
    }

    if (failingPackages.isNotEmpty || missingFlutterBuild.isNotEmpty) {
      throw ToolExit(1);
    }

    print('All Java tests successful!');
  }
}
