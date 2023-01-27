// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/firebase_test_lab_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('FirebaseTestLabCommand', () {
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

    void writeJavaTestFile(RepositoryPackage plugin, String relativeFilePath,
        {String runnerClass = 'FlutterTestRunner'}) {
      childFileWithSubcomponents(
              plugin.directory, p.posix.split(relativeFilePath))
          .writeAsStringSync('''
@DartIntegrationTest
@RunWith($runnerClass.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<FlutterActivity> rule = new ActivityTestRule<>(FlutterActivity.class);
}
''');
    }

    test('fails if gcloud auth fails', () async {
      processRunner.mockProcessesForExecutable['gcloud'] = <Process>[
        MockProcess(exitCode: 1)
      ];

      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

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

      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

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
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin1, javaTestFileRelativePath);
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin2', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin2, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=redfin,version=30',
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
              'gcloud', 'config set project flutter-cirrus'.split(' '), null),
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
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin1/buildId/testRunId/example/0/ --device model=redfin,version=30 --device model=seoul,version=26'
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
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin2/buildId/testRunId/example/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin2/example'),
        ]),
      );
    });

    test('runs integration tests', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/integration_test/should_not_run.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=redfin,version=30',
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
              'gcloud', 'config set project flutter-cirrus'.split(' '), null),
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
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/example/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/example/1/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('runs for all examples', () async {
      const List<String> examples = <String>['example1', 'example2'];
      const String javaTestFileExampleRelativePath =
          'android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          examples: examples,
          extraFiles: <String>[
            for (final String example in examples) ...<String>[
              'example/$example/integration_test/a_test.dart',
              'example/$example/android/gradlew',
              'example/$example/$javaTestFileExampleRelativePath',
            ],
          ]);
      for (final String example in examples) {
        writeJavaTestFile(
            plugin, 'example/$example/$javaTestFileExampleRelativePath');
      }

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=redfin,version=30',
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
          contains('Testing example/example1/integration_test/a_test.dart...'),
          contains('Testing example/example2/integration_test/a_test.dart...'),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          ProcessCall(
              '/packages/plugin/example/example1/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/example1/integration_test/a_test.dart'
                  .split(' '),
              '/packages/plugin/example/example1/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/example1/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example/example1'),
          ProcessCall(
              '/packages/plugin/example/example2/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/example2/integration_test/a_test.dart'
                  .split(' '),
              '/packages/plugin/example/example2/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/example2/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example/example2'),
        ]),
      );
    });

    test('fails if a test fails twice', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      processRunner.mockProcessesForExecutable['gcloud'] = <Process>[
        MockProcess(), // auth
        MockProcess(), // config
        MockProcess(exitCode: 1), // integration test #1
        MockProcess(exitCode: 1), // integration test #1 retry
        MockProcess(), // integration test #2
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=redfin,version=30',
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

    test('passes with warning if a test fails once, then passes on retry',
        () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      processRunner.mockProcessesForExecutable['gcloud'] = <Process>[
        MockProcess(), // auth
        MockProcess(), // config
        MockProcess(exitCode: 1), // integration test #1
        MockProcess(), // integration test #1 retry
        MockProcess(), // integration test #2
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=redfin,version=30',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Testing example/integration_test/bar_test.dart...'),
          contains('bar_test.dart failed on attempt 1. Retrying...'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('Ran for 1 package(s) (1 with warnings)'),
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
          'model=redfin,version=30',
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
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=redfin,version=30',
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

    test('fails for packages with no integration_test runner', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/integration_test/should_not_run.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      // Use the wrong @RunWith annotation.
      writeJavaTestFile(plugin, javaTestFileRelativePath,
          runnerClass: 'AndroidJUnit4.class');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=redfin,version=30',
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
          contains('No integration_test runner found. '
              'See the integration_test package README for setup instructions.'),
          contains('plugin:\n'
              '    No integration_test runner.'),
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
        'model=redfin,version=30',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for package'),
          contains('No examples support Android'),
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
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=redfin,version=30',
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
              'gcloud', 'config set project flutter-cirrus'.split(' '), null),
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
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/example/0/ --device model=redfin,version=30'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('fails if building to generate gradlew fails', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      processRunner.mockProcessesForExecutable['flutter'] = <Process>[
        MockProcess(exitCode: 1) // flutter build
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--device',
          'model=redfin,version=30',
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
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
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
          'model=redfin,version=30',
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
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
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
          'model=redfin,version=30',
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
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--device',
        'model=redfin,version=30',
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
              'gcloud', 'config set project flutter-cirrus'.split(' '), null),
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
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://flutter_cirrus_testlab --results-dir=plugins_android_test/plugin/buildId/testRunId/example/0/ --device model=redfin,version=30'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });
  });
}
