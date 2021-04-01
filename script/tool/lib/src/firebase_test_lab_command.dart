// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'common.dart';

class FirebaseTestLabCommand extends PluginCommand {
  FirebaseTestLabCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
    Print print = print,
  })  : _print = print,
        super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addOption(
      'project',
      defaultsTo: 'flutter-infra',
      help: 'The Firebase project name.',
    );
    argParser.addOption('service-key',
        defaultsTo:
            p.join(io.Platform.environment['HOME'], 'gcloud-service-key.json'));
    argParser.addOption('test-run-id',
        defaultsTo: Uuid().v4(),
        help:
            'Optional string to append to the results path, to avoid conflicts. '
            'Randomly chosen on each invocation if none is provided. '
            'The default shown here is just an example.');
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

  static const String _gradleWrapper = 'gradlew';

  final Print _print;

  Completer<void> _firebaseProjectConfigured;

  Future<void> _configureFirebaseProject() async {
    if (_firebaseProjectConfigured != null) {
      return _firebaseProjectConfigured.future;
    } else {
      _firebaseProjectConfigured = Completer<void>();
    }
    await processRunner.runAndExitOnError('gcloud', <String>[
      'auth',
      'activate-service-account',
      '--key-file=${argResults['service-key']}',
    ]);
    final int exitCode = await processRunner.runAndStream('gcloud', <String>[
      'config',
      'set',
      'project',
      argResults['project'] as String,
    ]);
    if (exitCode == 0) {
      _print('\nFirebase project configured.');
      return;
    } else {
      _print(
          '\nWarning: gcloud config set returned a non-zero exit code. Continuing anyway.');
    }
    _firebaseProjectConfigured.complete(null);
  }

  @override
  Future<void> run() async {
    checkSharding();
    final Stream<Directory> packagesWithTests = getPackages().where(
        (Directory d) =>
            isFlutterPackage(d, fileSystem) &&
            fileSystem
                .directory(p.join(
                    d.path, 'example', 'android', 'app', 'src', 'androidTest'))
                .existsSync());

    final List<String> failingPackages = <String>[];
    final List<String> missingFlutterBuild = <String>[];
    int resultsCounter =
        0; // We use a unique GCS bucket for each Firebase Test Lab run
    await for (final Directory package in packagesWithTests) {
      // See https://github.com/flutter/flutter/issues/38983

      final Directory exampleDirectory =
          fileSystem.directory(p.join(package.path, 'example'));
      final String packageName =
          p.relative(package.path, from: packagesDir.path);
      _print('\nRUNNING FIREBASE TEST LAB TESTS for $packageName');

      final Directory androidDirectory =
          fileSystem.directory(p.join(exampleDirectory.path, 'android'));

      final String enableExperiment = argResults[kEnableExperiment] as String;
      final String encodedEnableExperiment =
          Uri.encodeComponent('--enable-experiment=$enableExperiment');

      // Ensures that gradle wrapper exists
      if (!fileSystem
          .file(p.join(androidDirectory.path, _gradleWrapper))
          .existsSync()) {
        final int exitCode = await processRunner.runAndStream(
            'flutter',
            <String>[
              'build',
              'apk',
              if (enableExperiment.isNotEmpty)
                '--enable-experiment=$enableExperiment',
            ],
            workingDir: androidDirectory);

        if (exitCode != 0) {
          failingPackages.add(packageName);
          continue;
        }
        continue;
      }

      await _configureFirebaseProject();

      int exitCode = await processRunner.runAndStream(
          p.join(androidDirectory.path, _gradleWrapper),
          <String>[
            'app:assembleAndroidTest',
            '-Pverbose=true',
            if (enableExperiment.isNotEmpty)
              '-Pextra-front-end-options=$encodedEnableExperiment',
            if (enableExperiment.isNotEmpty)
              '-Pextra-gen-snapshot-options=$encodedEnableExperiment',
          ],
          workingDir: androidDirectory);

      if (exitCode != 0) {
        failingPackages.add(packageName);
        continue;
      }

      // Look for tests recursively in folders that start with 'test' and that
      // live in the root or example folders.
      bool isTestDir(FileSystemEntity dir) {
        return dir is Directory &&
            (p.basename(dir.path).startsWith('test') ||
                p.basename(dir.path) == 'integration_test');
      }

      final List<Directory> testDirs =
          package.listSync().where(isTestDir).cast<Directory>().toList();
      final Directory example =
          fileSystem.directory(p.join(package.path, 'example'));
      testDirs.addAll(
          example.listSync().where(isTestDir).cast<Directory>().toList());
      for (final Directory testDir in testDirs) {
        bool isE2ETest(FileSystemEntity file) {
          return file.path.endsWith('_e2e.dart') ||
              (file.parent.basename == 'integration_test' &&
                  file.path.endsWith('_test.dart'));
        }

        final List<FileSystemEntity> testFiles = testDir
            .listSync(recursive: true, followLinks: true)
            .where(isE2ETest)
            .toList();
        for (final FileSystemEntity test in testFiles) {
          exitCode = await processRunner.runAndStream(
              p.join(androidDirectory.path, _gradleWrapper),
              <String>[
                'app:assembleDebug',
                '-Pverbose=true',
                '-Ptarget=${test.path}',
                if (enableExperiment.isNotEmpty)
                  '-Pextra-front-end-options=$encodedEnableExperiment',
                if (enableExperiment.isNotEmpty)
                  '-Pextra-gen-snapshot-options=$encodedEnableExperiment',
              ],
              workingDir: androidDirectory);

          if (exitCode != 0) {
            failingPackages.add(packageName);
            continue;
          }
          final String buildId = io.Platform.environment['CIRRUS_BUILD_ID'];
          final String testRunId = argResults['test-run-id'] as String;
          final String resultsDir =
              'plugins_android_test/$packageName/$buildId/$testRunId/${resultsCounter++}/';
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
            '5m',
            '--results-bucket=${argResults['results-bucket']}',
            '--results-dir=$resultsDir',
          ];
          for (final String device in argResults['device'] as List<String>) {
            args.addAll(<String>['--device', device]);
          }
          exitCode = await processRunner.runAndStream('gcloud', args,
              workingDir: exampleDirectory);

          if (exitCode != 0) {
            failingPackages.add(packageName);
            continue;
          }
        }
      }
    }

    _print('\n\n');
    if (failingPackages.isNotEmpty) {
      _print(
          'The instrumentation tests for the following packages are failing (see above for'
          'details):');
      for (final String package in failingPackages) {
        _print(' * $package');
      }
    }
    if (missingFlutterBuild.isNotEmpty) {
      _print('Run "pub global run flutter_plugin_tools build-examples --apk" on'
          'the following packages before executing tests again:');
      for (final String package in missingFlutterBuild) {
        _print(' * $package');
      }
    }

    if (failingPackages.isNotEmpty || missingFlutterBuild.isNotEmpty) {
      throw ToolExit(1);
    }

    _print('All Firebase Test Lab tests successful!');
  }
}
