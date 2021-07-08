// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';

/// A command to run the Java tests of Android plugins.
class JavaTestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test runner.
  JavaTestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner);

  static const String _gradleWrapper = 'gradlew';

  @override
  final String name = 'java-test';

  @override
  final String description = 'Runs the Java tests of the example apps.\n\n'
      'Building the apks of the example apps is required before executing this'
      'command.';

  @override
  Future<PackageResult> runForPackage(Directory package) async {
    final Iterable<Directory> examplesWithTests = getExamplesForPlugin(package)
        .where((Directory d) =>
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

    if (examplesWithTests.isEmpty) {
      return PackageResult.skip('No Java unit tests.');
    }

    final List<String> errors = <String>[];
    for (final Directory example in examplesWithTests) {
      final String exampleName = p.relative(example.path, from: package.path);
      print('\nRUNNING JAVA TESTS for $exampleName');

      final Directory androidDirectory = example.childDirectory('android');
      final File gradleFile = androidDirectory.childFile(_gradleWrapper);
      if (!gradleFile.existsSync()) {
        printError('ERROR: Run "flutter build apk" on $exampleName, or run '
            'this tool\'s "build-examples --apk" command, '
            'before executing tests.');
        errors.add('$exampleName has not been built.');
        continue;
      }

      final int exitCode = await processRunner.runAndStream(
          gradleFile.path, <String>['testDebugUnitTest', '--info'],
          workingDir: androidDirectory);
      if (exitCode != 0) {
        errors.add('$exampleName tests failed.');
      }
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }
}
