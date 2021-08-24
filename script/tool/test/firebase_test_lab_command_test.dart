// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/firebase_test_lab_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$FirebaseTestLabCommand', () {
    FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final FirebaseTestLabCommand command = FirebaseTestLabCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
          'firebase_test_lab_command', 'Test for $FirebaseTestLabCommand');
      runner.addCommand(command);
    });

    test('fails if gcloud auth fails', () async {
      processRunner.mockProcessesForExecutable['gcloud'] = <Process>[
        MockProcess(exitCode: 1)
      ];
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['firebase-test-lab'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to activate gcloud account.'),
          ]));
    });

    test('retries gcloud set', () async {
      processRunner.mockProcessesForExecutable['gcloud'] = <Process>[
        MockProcess(), // auth
        MockProcess(exitCode: 1), // config
      ];
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['firebase-test-lab']);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Warning: gcloud config set returned a non-zero exit code. Continuing anyway.'),
          ]));
    });

    test('only runs gcloud configuration once', () async {
      createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);
      createFakePlugin('plugin2', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin1'),
          contains('Firebase project configured.'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('Running for plugin2'),
          contains('Testing example/integration_test/bar_test.dart...'),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'gcloud',
              'auth activate-service-account --key-file=${Platform.environment['HOME']}/gcloud-service-key.json'
                  .split(' '),
              null),
          ProcessCall(
              'gcloud', 'config set project flutter-infra'.split(' '), null),
          ProcessCall(
              '/packages/plugin1/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin1/example/android'),
          ProcessCall(
              '/packages/plugin1/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin1/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin1/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin1/buildId/testRunId/0/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin1/example'),
          ProcessCall(
              '/packages/plugin2/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin2/example/android'),
          ProcessCall(
              '/packages/plugin2/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin2/example/integration_test/bar_test.dart'
                  .split(' '),
              '/packages/plugin2/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin2/buildId/testRunId/0/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin2/example'),
        ]),
      );
    });

    test('runs integration tests', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/integration_test/should_not_run.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Firebase project configured.'),
          contains('Testing example/integration_test/bar_test.dart...'),
          contains('Testing example/integration_test/foo_test.dart...'),
        ]),
      );
      expect(output, isNot(contains('test/plugin_test.dart')));
      expect(output,
          isNot(contains('example/integration_test/should_not_run.dart')));

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'gcloud',
              'auth activate-service-account --key-file=${Platform.environment['HOME']}/gcloud-service-key.json'
                  .split(' '),
              null),
          ProcessCall(
              'gcloud', 'config set project flutter-infra'.split(' '), null),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/bar_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/0/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/1/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('fails if a test fails', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      processRunner.mockProcessesForExecutable['gcloud'] = <Process>[
        MockProcess(), // auth
        MockProcess(), // config
        MockProcess(exitCode: 1), // integration test #1
        MockProcess(), // integration test #2
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=flame,version=29',
          '--device',
          'model=seoul,version=26',
          '--test-run-id',
          'testRunId',
          '--build-id',
          'buildId',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Testing example/integration_test/bar_test.dart...'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('plugin:\n'
              '    example/integration_test/bar_test.dart failed tests'),
        ]),
      );
    });

    test('fails for packages with no androidTest directory', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
      ]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=flame,version=29',
          '--device',
          'model=seoul,version=26',
          '--test-run-id',
          'testRunId',
          '--build-id',
          'buildId',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No androidTest directory found.'),
          contains('The following packages had errors:'),
          contains('plugin:\n'
              '    No tests ran (use --exclude if this is intentional).'),
        ]),
      );
    });

    test('fails for packages with no integration test files', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=flame,version=29',
          '--device',
          'model=seoul,version=26',
          '--test-run-id',
          'testRunId',
          '--build-id',
          'buildId',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No integration tests were run'),
          contains('The following packages had errors:'),
          contains('plugin:\n'
              '    No tests ran (use --exclude if this is intentional).'),
        ]),
      );
    });

    test('skips packages with no android directory', () async {
      createFakePackage('package', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for package'),
          contains('package/example does not support Android'),
        ]),
      );
      expect(output,
          isNot(contains('Testing example/integration_test/foo_test.dart...')));

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[]),
      );
    });

    test('builds if gradlew is missing', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Running flutter build apk...'),
          contains('Firebase project configured.'),
          contains('Testing example/integration_test/foo_test.dart...'),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            'flutter',
            'build apk'.split(' '),
            '/packages/plugin/example/android',
          ),
          ProcessCall(
              'gcloud',
              'auth activate-service-account --key-file=${Platform.environment['HOME']}/gcloud-service-key.json'
                  .split(' '),
              null),
          ProcessCall(
              'gcloud', 'config set project flutter-infra'.split(' '), null),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/0/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('fails if building to generate gradlew fails', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      processRunner.mockProcessesForExecutable['flutter'] = <Process>[
        MockProcess(exitCode: 1) // flutter build
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=flame,version=29',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to build example apk'),
          ]));
    });

    test('fails if assembleAndroidTest fails', () async {
      final Directory pluginDir =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      final String gradlewPath = pluginDir
          .childDirectory('example')
          .childDirectory('android')
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <Process>[
        MockProcess(exitCode: 1)
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=flame,version=29',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to assemble androidTest'),
          ]));
    });

    test('fails if assembleDebug fails', () async {
      final Directory pluginDir =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      final String gradlewPath = pluginDir
          .childDirectory('example')
          .childDirectory('android')
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <Process>[
        MockProcess(), // assembleAndroidTest
        MockProcess(exitCode: 1), // assembleDebug
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=flame,version=29',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Could not build example/integration_test/foo_test.dart'),
            contains('The following packages had errors:'),
            contains('  plugin:\n'
                '    example/integration_test/foo_test.dart failed to build'),
          ]));
    });

    test('experimental flag', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        'example/android/app/src/androidTest/MainActivityTest.java',
      ]);

      await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
        '--enable-experiment=exp1',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'gcloud',
              'auth activate-service-account --key-file=${Platform.environment['HOME']}/gcloud-service-key.json'
                  .split(' '),
              null),
          ProcessCall(
              'gcloud', 'config set project flutter-infra'.split(' '), null),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/0/ --device model=flame,version=29'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });
  });
}
