// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/firebase_test_lab_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$FirebaseTestLabCommand', () {
    final List<String> printedMessages = <String>[];
    CommandRunner<void> runner;
    RecordingProcessRunner processRunner;

    setUp(() {
      initializeFakePackages();
      processRunner = RecordingProcessRunner();
      final FirebaseTestLabCommand command = FirebaseTestLabCommand(
          mockPackagesDir,
          processRunner: processRunner,
          print: (Object message) => printedMessages.add(message.toString()));

      runner = CommandRunner<void>(
          'firebase_test_lab_command', 'Test for $FirebaseTestLabCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      printedMessages.clear();
    });

    test('retries gcloud set', () async {
      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(1);
      processRunner.processToReturn = mockProcess;
      createFakePlugin('plugin', withExtraFiles: <List<String>>[
        <String>['lib/test/should_not_run_e2e.dart'],
        <String>['example', 'test_driver', 'plugin_e2e.dart'],
        <String>['example', 'test_driver', 'plugin_e2e_test.dart'],
        <String>['example', 'android', 'gradlew'],
        <String>['example', 'should_not_run_e2e.dart'],
        <String>[
          'example',
          'android',
          'app',
          'src',
          'androidTest',
          'MainActivityTest.java'
        ],
      ]);
      await expectLater(
          () => runCapturingPrint(runner, <String>['firebase-test-lab']),
          throwsA(const TypeMatcher<ToolExit>()));
      expect(
          printedMessages,
          contains(
              '\nWarning: gcloud config set returned a non-zero exit code. Continuing anyway.'));
    });

    test('runs e2e tests', () async {
      createFakePlugin('plugin', withExtraFiles: <List<String>>[
        <String>['test', 'plugin_test.dart'],
        <String>['test', 'plugin_e2e.dart'],
        <String>['should_not_run_e2e.dart'],
        <String>['lib/test/should_not_run_e2e.dart'],
        <String>['example', 'test', 'plugin_e2e.dart'],
        <String>['example', 'test_driver', 'plugin_e2e.dart'],
        <String>['example', 'test_driver', 'plugin_e2e_test.dart'],
        <String>['example', 'integration_test', 'foo_test.dart'],
        <String>['example', 'integration_test', 'should_not_run.dart'],
        <String>['example', 'android', 'gradlew'],
        <String>['example', 'should_not_run_e2e.dart'],
        <String>[
          'example',
          'android',
          'app',
          'src',
          'androidTest',
          'MainActivityTest.java'
        ],
      ]);

      await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
      ]);

      expect(
        printedMessages,
        orderedEquals(<String>[
          '\nRUNNING FIREBASE TEST LAB TESTS for plugin',
          '\nFirebase project configured.',
          '\n\n',
          'All Firebase Test Lab tests successful!',
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
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/test/plugin_e2e.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/0/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/test_driver/plugin_e2e.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/1/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/test/plugin_e2e.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/2/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/3/ --device model=flame,version=29 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('experimental flag', () async {
      createFakePlugin('plugin', withExtraFiles: <List<String>>[
        <String>['test', 'plugin_test.dart'],
        <String>['test', 'plugin_e2e.dart'],
        <String>['should_not_run_e2e.dart'],
        <String>['lib/test/should_not_run_e2e.dart'],
        <String>['example', 'test', 'plugin_e2e.dart'],
        <String>['example', 'test_driver', 'plugin_e2e.dart'],
        <String>['example', 'test_driver', 'plugin_e2e_test.dart'],
        <String>['example', 'integration_test', 'foo_test.dart'],
        <String>['example', 'integration_test', 'should_not_run.dart'],
        <String>['example', 'android', 'gradlew'],
        <String>['example', 'should_not_run_e2e.dart'],
        <String>[
          'example',
          'android',
          'app',
          'src',
          'androidTest',
          'MainActivityTest.java'
        ],
      ]);

      await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=flame,version=29',
        '--test-run-id',
        'testRunId',
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
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/test/plugin_e2e.dart -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/0/ --device model=flame,version=29'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/test_driver/plugin_e2e.dart -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/1/ --device model=flame,version=29'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/test/plugin_e2e.dart -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/2/ --device model=flame,version=29'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 5m --results-bucket=gs://flutter_firebase_testlab --results-dir=plugins_android_test/plugin/null/testRunId/3/ --device model=flame,version=29'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );

      cleanupPackages();
    });
  });
}
