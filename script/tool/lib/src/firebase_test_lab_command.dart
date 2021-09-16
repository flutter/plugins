// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:platform/platform.dart';
import 'package:uuid/uuid.dart';

import 'common/core.dart';
import 'common/gradle.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

const int _exitGcloudAuthFailed = 2;

/// A command to run tests via Firebase test lab.
class FirebaseTestLabCommand extends PackageLoopingCommand {
  /// Creates an instance of the test runner command.
  FirebaseTestLabCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addOption(
      'project',
      defaultsTo: 'flutter-cirrus',
      help: 'The Firebase project name.',
    );
    final String? homeDir = io.Platform.environment['HOME'];
    argParser.addOption('service-key',
        defaultsTo: homeDir == null
            ? null
            : path.join(homeDir, 'gcloud-service-key.json'),
        help: 'The path to the service key for gcloud authentication.\n'
            r'If not provided, \$HOME/gcloud-service-key.json will be '
            r'assumed if $HOME is set.');
    argParser.addOption('test-run-id',
        defaultsTo: const Uuid().v4(),
        help:
            'Optional string to append to the results path, to avoid conflicts. '
            'Randomly chosen on each invocation if none is provided. '
            'The default shown here is just an example.');
    argParser.addOption('build-id',
        defaultsTo:
            io.Platform.environment['CIRRUS_BUILD_ID'] ?? 'unknown_build',
        help:
            'Optional string to append to the results path, to avoid conflicts. '
            r'Defaults to $CIRRUS_BUILD_ID if that is set.');
    argParser.addMultiOption('device',
        splitCommas: false,
        defaultsTo: <String>[
          'model=walleye,version=26',
          'model=flame,version=29'
        ],
        help:
            'Device model(s) to test. See https://cloud.google.com/sdk/gcloud/reference/firebase/test/android/run for more info');
    argParser.addOption('results-bucket',
        defaultsTo: 'gs://flutter_firebase_testlab');
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help: 'Enables the given Dart SDK experiments.',
    );
  }

  @override
  final String name = 'firebase-test-lab';

  @override
  final String description = 'Runs the instrumentation tests of the example '
      'apps on Firebase Test Lab.\n\n'
      'Runs tests in test_instrumentation folder using the '
      'instrumentation_test package.';

  bool _firebaseProjectConfigured = false;

  Future<void> _configureFirebaseProject() async {
    if (_firebaseProjectConfigured) {
      return;
    }

    final String serviceKey = getStringArg('service-key');
    if (serviceKey.isEmpty) {
      print('No --service-key provided; skipping gcloud authorization');
    } else {
      final io.ProcessResult result = await processRunner.run(
        'gcloud',
        <String>[
          'auth',
          'activate-service-account',
          '--key-file=$serviceKey',
        ],
        logOnError: true,
      );
      if (result.exitCode != 0) {
        printError('Unable to activate gcloud account.');
        throw ToolExit(_exitGcloudAuthFailed);
      }
      final int exitCode = await processRunner.runAndStream('gcloud', <String>[
        'config',
        'set',
        'project',
        getStringArg('project'),
      ]);
      print('');
      if (exitCode == 0) {
        print('Firebase project configured.');
      } else {
        logWarning(
            'Warning: gcloud config set returned a non-zero exit code. Continuing anyway.');
      }
    }
    _firebaseProjectConfigured = true;
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final RepositoryPackage example = package.getSingleExampleDeprecated();
    final Directory androidDirectory =
        example.directory.childDirectory('android');
    if (!androidDirectory.existsSync()) {
      return PackageResult.skip(
          '${example.displayName} does not support Android.');
    }

    if (!androidDirectory
        .childDirectory('app')
        .childDirectory('src')
        .childDirectory('androidTest')
        .existsSync()) {
      printError('No androidTest directory found.');
      return PackageResult.fail(
          <String>['No tests ran (use --exclude if this is intentional).']);
    }

    // Ensures that gradle wrapper exists
    final GradleProject project = GradleProject(example.directory,
        processRunner: processRunner, platform: platform);
    if (!await _ensureGradleWrapperExists(project)) {
      return PackageResult.fail(<String>['Unable to build example apk']);
    }

    await _configureFirebaseProject();

    if (!await _runGradle(project, 'app:assembleAndroidTest')) {
      return PackageResult.fail(<String>['Unable to assemble androidTest']);
    }

    final List<String> errors = <String>[];

    // Used within the loop to ensure a unique GCS output location for each
    // test file's run.
    int resultsCounter = 0;
    for (final File test in _findIntegrationTestFiles(package)) {
      final String testName =
          getRelativePosixPath(test, from: package.directory);
      print('Testing $testName...');
      if (!await _runGradle(project, 'app:assembleDebug', testFile: test)) {
        printError('Could not build $testName');
        errors.add('$testName failed to build');
        continue;
      }
      final String buildId = getStringArg('build-id');
      final String testRunId = getStringArg('test-run-id');
      final String resultsDir =
          'plugins_android_test/${package.displayName}/$buildId/$testRunId/${resultsCounter++}/';
      final List<String> args = <String>[
        'firebase',
        'test',
        'android',
        'run',
        '--type',
        'instrumentation',
        '--app',
        'build/app/outputs/apk/debug/app-debug.apk',
        '--test',
        'build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk',
        '--timeout',
        '7m',
        '--results-bucket=${getStringArg('results-bucket')}',
        '--results-dir=$resultsDir',
      ];
      for (final String device in getStringListArg('device')) {
        args.addAll(<String>['--device', device]);
      }
      final int exitCode = await processRunner.runAndStream('gcloud', args,
          workingDir: example.directory);

      if (exitCode != 0) {
        printError('Test failure for $testName');
        errors.add('$testName failed tests');
      }
    }

    if (errors.isEmpty && resultsCounter == 0) {
      printError('No integration tests were run.');
      errors.add('No tests ran (use --exclude if this is intentional).');
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  /// Checks that Gradle has been configured for [project], and if not runs a
  /// Flutter build to generate it.
  ///
  /// Returns true if either gradlew was already present, or the build succeeds.
  Future<bool> _ensureGradleWrapperExists(GradleProject project) async {
    if (!project.isConfigured()) {
      print('Running flutter build apk...');
      final String experiment = getStringArg(kEnableExperiment);
      final int exitCode = await processRunner.runAndStream(
          flutterCommand,
          <String>[
            'build',
            'apk',
            if (experiment.isNotEmpty) '--enable-experiment=$experiment',
          ],
          workingDir: project.androidDirectory);

      if (exitCode != 0) {
        return false;
      }
    }
    return true;
  }

  /// Builds [target] using Gradle in the given [project]. Assumes Gradle is
  /// already configured.
  ///
  /// [testFile] optionally does the Flutter build with the given test file as
  /// the build target.
  ///
  /// Returns true if the command succeeds.
  Future<bool> _runGradle(
    GradleProject project,
    String target, {
    File? testFile,
  }) async {
    final String experiment = getStringArg(kEnableExperiment);
    final String? extraOptions = experiment.isNotEmpty
        ? Uri.encodeComponent('--enable-experiment=$experiment')
        : null;

    final int exitCode = await project.runCommand(
      target,
      arguments: <String>[
        '-Pverbose=true',
        if (testFile != null) '-Ptarget=${testFile.path}',
        if (extraOptions != null) '-Pextra-front-end-options=$extraOptions',
        if (extraOptions != null) '-Pextra-gen-snapshot-options=$extraOptions',
      ],
    );

    if (exitCode != 0) {
      return false;
    }
    return true;
  }

  /// Finds and returns all integration test files for [package].
  Iterable<File> _findIntegrationTestFiles(RepositoryPackage package) sync* {
    final Directory integrationTestDir = package
        .getSingleExampleDeprecated()
        .directory
        .childDirectory('integration_test');

    if (!integrationTestDir.existsSync()) {
      return;
    }

    yield* integrationTestDir
        .listSync(recursive: true, followLinks: true)
        .where((FileSystemEntity file) =>
            file is File && file.basename.endsWith('_test.dart'))
        .cast<File>();
  }
}
