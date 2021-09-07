// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/native_test_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

const String _androidIntegrationTestFilter =
    '-Pandroid.testInstrumentationRunnerArguments.'
    'notAnnotation=io.flutter.plugins.DartIntegrationTest';

final Map<String, dynamic> _kDeviceListMap = <String, dynamic>{
  'runtimes': <Map<String, dynamic>>[
    <String, dynamic>{
      'bundlePath':
          '/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 13.4.simruntime',
      'buildversion': '17L255',
      'runtimeRoot':
          '/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 13.4.simruntime/Contents/Resources/RuntimeRoot',
      'identifier': 'com.apple.CoreSimulator.SimRuntime.iOS-13-4',
      'version': '13.4',
      'isAvailable': true,
      'name': 'iOS 13.4'
    },
  ],
  'devices': <String, dynamic>{
    'com.apple.CoreSimulator.SimRuntime.iOS-13-4': <Map<String, dynamic>>[
      <String, dynamic>{
        'dataPath':
            '/Users/xxx/Library/Developer/CoreSimulator/Devices/1E76A0FD-38AC-4537-A989-EA639D7D012A/data',
        'logPath':
            '/Users/xxx/Library/Logs/CoreSimulator/1E76A0FD-38AC-4537-A989-EA639D7D012A',
        'udid': '1E76A0FD-38AC-4537-A989-EA639D7D012A',
        'isAvailable': true,
        'deviceTypeIdentifier':
            'com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus',
        'state': 'Shutdown',
        'name': 'iPhone 8 Plus'
      }
    ]
  }
};

// TODO(stuartmorgan): Rework these tests to use a mock Xcode instead of
// doing all the process mocking and validation.
void main() {
  const String _kDestination = '--ios-destination';

  group('test native_test_command on Posix', () {
    late FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform(isMacOS: true);
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final NativeTestCommand command = NativeTestCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>(
          'native_test_command', 'Test for native_test_command');
      runner.addCommand(command);
    });

    test('fails if no platforms are provided', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['native-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('At least one platform flag must be provided.'),
        ]),
      );
    });

    test('fails if all test types are disabled', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'native-test',
        '--macos',
        '--no-unit',
        '--no-integration',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('At least one test type must be enabled.'),
        ]),
      );
    });

    test('reports skips with no tests', () async {
      final Directory pluginDirectory1 = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory =
          pluginDirectory1.childDirectory('example');

      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        // Exit code 66 from testing indicates no tests.
        MockProcess(exitCode: 66),
      ];
      final List<String> output =
          await runCapturingPrint(runner, <String>['native-test', '--macos']);

      expect(output, contains(contains('No tests found.')));

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'xcrun',
                const <String>[
                  'xcodebuild',
                  'test',
                  '-workspace',
                  'macos/Runner.xcworkspace',
                  '-scheme',
                  'Runner',
                  '-configuration',
                  'Debug',
                  'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    group('iOS', () {
      test('skip if iOS is not supported', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final List<String> output = await runCapturingPrint(runner,
            <String>['native-test', '--ios', _kDestination, 'foo_destination']);
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for iOS.'),
              contains('SKIPPING: Nothing to test for target platform(s).'),
            ]));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if iOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformIos: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output = await runCapturingPrint(runner,
            <String>['native-test', '--ios', _kDestination, 'foo_destination']);
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for iOS.'),
              contains('SKIPPING: Nothing to test for target platform(s).'),
            ]));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('running with correct destination', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformDetails>{
          kPlatformIos: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--ios',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin'),
              contains('Successfully ran iOS xctest for plugin/example')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'foo_destination',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('Not specifying --ios-destination assigns an available simulator',
          () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformDetails>{
          kPlatformIos: const PlatformDetails(PlatformSupport.inline)
        });
        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(stdout: jsonEncode(_kDeviceListMap)), // simctl
        ];

        await runCapturingPrint(runner, <String>['native-test', '--ios']);

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              const ProcessCall(
                  'xcrun',
                  <String>[
                    'simctl',
                    'list',
                    'devices',
                    'runtimes',
                    'available',
                    '--json',
                  ],
                  null),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'id=1E76A0FD-38AC-4537-A989-EA639D7D012A',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });
    });

    group('macOS', () {
      test('skip if macOS is not supported', () async {
        createFakePlugin('plugin', packagesDir);

        final List<String> output =
            await runCapturingPrint(runner, <String>['native-test', '--macos']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for macOS.'),
              contains('SKIPPING: Nothing to test for target platform(s).'),
            ]));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if macOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.federated),
            });

        final List<String> output =
            await runCapturingPrint(runner, <String>['native-test', '--macos']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for macOS.'),
              contains('SKIPPING: Nothing to test for target platform(s).'),
            ]));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for macOS plugin', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--macos',
        ]);

        expect(
            output,
            contains(
                contains('Successfully ran macOS xctest for plugin/example')));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });
    });

    group('Android', () {
      test('runs Java unit tests in Android implementation folder', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'android/src/test/example_test.java',
          ],
        );

        await runCapturingPrint(runner, <String>['native-test', '--android']);

        final Directory androidFolder =
            plugin.childDirectory('example').childDirectory('android');

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>['testDebugUnitTest'],
              androidFolder.path,
            ),
          ]),
        );
      });

      test('runs Java unit tests in example folder', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/test/example_test.java',
          ],
        );

        await runCapturingPrint(runner, <String>['native-test', '--android']);

        final Directory androidFolder =
            plugin.childDirectory('example').childDirectory('android');

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>['testDebugUnitTest'],
              androidFolder.path,
            ),
          ]),
        );
      });

      test('runs Java integration tests', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/androidTest/IntegrationTest.java',
          ],
        );

        await runCapturingPrint(runner, <String>['native-test', '--android']);

        final Directory androidFolder =
            plugin.childDirectory('example').childDirectory('android');

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>[
                'app:connectedAndroidTest',
                _androidIntegrationTestFilter,
              ],
              androidFolder.path,
            ),
          ]),
        );
      });

      test(
          'ignores Java integration test files associated with integration_test',
          () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/androidTest/java/io/flutter/plugins/DartIntegrationTest.java',
            'example/android/app/src/androidTest/java/io/flutter/plugins/plugin/FlutterActivityTest.java',
            'example/android/app/src/androidTest/java/io/flutter/plugins/plugin/MainActivityTest.java',
          ],
        );

        await runCapturingPrint(runner, <String>['native-test', '--android']);

        // Nothing should run since those files are all
        // integration_test-specific.
        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[]),
        );
      });

      test('runs all tests when present', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'android/src/test/example_test.java',
            'example/android/gradlew',
            'example/android/app/src/androidTest/IntegrationTest.java',
          ],
        );

        await runCapturingPrint(runner, <String>['native-test', '--android']);

        final Directory androidFolder =
            plugin.childDirectory('example').childDirectory('android');

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>['testDebugUnitTest'],
              androidFolder.path,
            ),
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>[
                'app:connectedAndroidTest',
                _androidIntegrationTestFilter,
              ],
              androidFolder.path,
            ),
          ]),
        );
      });

      test('honors --no-unit', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'android/src/test/example_test.java',
            'example/android/gradlew',
            'example/android/app/src/androidTest/IntegrationTest.java',
          ],
        );

        await runCapturingPrint(
            runner, <String>['native-test', '--android', '--no-unit']);

        final Directory androidFolder =
            plugin.childDirectory('example').childDirectory('android');

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>[
                'app:connectedAndroidTest',
                _androidIntegrationTestFilter,
              ],
              androidFolder.path,
            ),
          ]),
        );
      });

      test('honors --no-integration', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'android/src/test/example_test.java',
            'example/android/gradlew',
            'example/android/app/src/androidTest/IntegrationTest.java',
          ],
        );

        await runCapturingPrint(
            runner, <String>['native-test', '--android', '--no-integration']);

        final Directory androidFolder =
            plugin.childDirectory('example').childDirectory('android');

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidFolder.childFile('gradlew').path,
              const <String>['testDebugUnitTest'],
              androidFolder.path,
            ),
          ]),
        );
      });

      test('fails when the app needs to be built', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/app/src/test/example_test.java',
          ],
        );

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('ERROR: Run "flutter build apk" on plugin/example'),
            contains('plugin:\n'
                '    Examples must be built before testing.')
          ]),
        );
      });

      test('logs missing test types', () async {
        // No unit tests.
        createFakePlugin(
          'plugin1',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/androidTest/IntegrationTest.java',
          ],
        );
        // No integration tests.
        createFakePlugin(
          'plugin2',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'android/src/test/example_test.java',
            'example/android/gradlew',
          ],
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No Android unit tests found for plugin1/example'),
              contains('Running integration tests...'),
              contains(
                  'No Android integration tests found for plugin2/example'),
              contains('Running unit tests...'),
            ]));
      });

      test('fails when a test fails', () async {
        final Directory pluginDir = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/test/example_test.java',
          ],
        );

        final String gradlewPath = pluginDir
            .childDirectory('example')
            .childDirectory('android')
            .childFile('gradlew')
            .path;
        processRunner.mockProcessesForExecutable[gradlewPath] = <io.Process>[
          MockProcess(exitCode: 1)
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('plugin/example unit tests failed.'),
            contains('The following packages had errors:'),
            contains('plugin')
          ]),
        );
      });

      test('skips if Android is not supported', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No implementation for Android.'),
            contains('SKIPPING: Nothing to test for target platform(s).'),
          ]),
        );
      });

      test('skips when running no tests', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No Android unit tests found for plugin/example'),
            contains('No Android integration tests found for plugin/example'),
            contains('SKIPPING: No tests found.'),
          ]),
        );
      });
    });

    group('Linux', () {
      test('runs unit tests', () async {
        const String testBinaryRelativePath =
            'build/linux/foo/release/bar/plugin_test';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
        });

        final File testBinary = childFileWithSubcomponents(pluginDirectory,
            <String>['example', ...testBinaryRelativePath.split('/')]);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--linux',
          '--no-integration',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running plugin_test...'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });

      test('only runs release unit tests', () async {
        const String debugTestBinaryRelativePath =
            'build/linux/foo/debug/bar/plugin_test';
        const String releaseTestBinaryRelativePath =
            'build/linux/foo/release/bar/plugin_test';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$debugTestBinaryRelativePath',
          'example/$releaseTestBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
        });

        final File releaseTestBinary = childFileWithSubcomponents(
            pluginDirectory,
            <String>['example', ...releaseTestBinaryRelativePath.split('/')]);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--linux',
          '--no-integration',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running plugin_test...'),
            contains('No issues found!'),
          ]),
        );

        // Only the release version should be run.
        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(releaseTestBinary.path, const <String>[], null),
            ]));
      });

      test('fails if there are no unit tests', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
            });

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--linux',
          '--no-integration',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No test binaries found.'),
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('fails if a unit test fails', () async {
        const String testBinaryRelativePath =
            'build/linux/foo/release/bar/plugin_test';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
        });

        final File testBinary = childFileWithSubcomponents(pluginDirectory,
            <String>['example', ...testBinaryRelativePath.split('/')]);

        processRunner.mockProcessesForExecutable[testBinary.path] =
            <io.Process>[MockProcess(exitCode: 1)];

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--linux',
          '--no-integration',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running plugin_test...'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });
    });

    // Tests behaviors of implementation that is shared between iOS and macOS.
    group('iOS/macOS', () {
      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(exitCode: 1)
        ];

        Error? commandError;
        final List<String> output =
            await runCapturingPrint(runner, <String>['native-test', '--macos'],
                errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('  plugin'),
          ]),
        );
      });

      test('honors unit-only', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        const Map<String, dynamic> projects = <String, dynamic>{
          'project': <String, dynamic>{
            'targets': <String>['RunnerTests', 'RunnerUITests']
          }
        };
        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(stdout: jsonEncode(projects)), // xcodebuild -list
        ];

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--macos',
          '--no-integration',
        ]);

        expect(
            output,
            contains(
                contains('Successfully ran macOS xctest for plugin/example')));

        // --no-integration should translate to '-only-testing:RunnerTests'.
        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  <String>[
                    'xcodebuild',
                    '-list',
                    '-json',
                    '-project',
                    pluginExampleDirectory
                        .childDirectory('macos')
                        .childDirectory('Runner.xcodeproj')
                        .path,
                  ],
                  null),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-only-testing:RunnerTests',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('honors integration-only', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        const Map<String, dynamic> projects = <String, dynamic>{
          'project': <String, dynamic>{
            'targets': <String>['RunnerTests', 'RunnerUITests']
          }
        };
        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(stdout: jsonEncode(projects)), // xcodebuild -list
        ];

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--macos',
          '--no-unit',
        ]);

        expect(
            output,
            contains(
                contains('Successfully ran macOS xctest for plugin/example')));

        // --no-unit should translate to '-only-testing:RunnerUITests'.
        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  <String>[
                    'xcodebuild',
                    '-list',
                    '-json',
                    '-project',
                    pluginExampleDirectory
                        .childDirectory('macos')
                        .childDirectory('Runner.xcodeproj')
                        .path,
                  ],
                  null),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-only-testing:RunnerUITests',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('skips when the requested target is not present', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        // Simulate a project with unit tests but no integration tests...
        const Map<String, dynamic> projects = <String, dynamic>{
          'project': <String, dynamic>{
            'targets': <String>['RunnerTests']
          }
        };
        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(stdout: jsonEncode(projects)), // xcodebuild -list
        ];

        // ... then try to run only integration tests.
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--macos',
          '--no-unit',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains(
                  'No "RunnerUITests" target in plugin/example; skipping.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  <String>[
                    'xcodebuild',
                    '-list',
                    '-json',
                    '-project',
                    pluginExampleDirectory
                        .childDirectory('macos')
                        .childDirectory('Runner.xcodeproj')
                        .path,
                  ],
                  null),
            ]));
      });

      test('fails if unable to check for requested target', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(exitCode: 1), // xcodebuild -list
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--macos',
          '--no-integration',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to check targets for plugin/example.'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  <String>[
                    'xcodebuild',
                    '-list',
                    '-json',
                    '-project',
                    pluginExampleDirectory
                        .childDirectory('macos')
                        .childDirectory('Runner.xcodeproj')
                        .path,
                  ],
                  null),
            ]));
      });
    });

    group('multiplatform', () {
      test('runs all platfroms when supported', () async {
        final Directory pluginDirectory = createFakePlugin(
          'plugin',
          packagesDir,
          extraFiles: <String>[
            'example/android/gradlew',
            'android/src/test/example_test.java',
          ],
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
            kPlatformIos: const PlatformDetails(PlatformSupport.inline),
            kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
          },
        );

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');
        final Directory androidFolder =
            pluginExampleDirectory.childDirectory('android');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--android',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAll(<Matcher>[
              contains('Running Android tests for plugin/example'),
              contains('Successfully ran iOS xctest for plugin/example'),
              contains('Successfully ran macOS xctest for plugin/example'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(androidFolder.childFile('gradlew').path,
                  const <String>['testDebugUnitTest'], androidFolder.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'foo_destination',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('runs only macOS for a macOS plugin', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for iOS.'),
              contains('Successfully ran macOS xctest for plugin/example'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('runs only iOS for a iOS plugin', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformDetails>{
          kPlatformIos: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for macOS.'),
              contains('Successfully ran iOS xctest for plugin/example')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'test',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'foo_destination',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('skips when nothing is supported', () async {
        createFakePlugin('plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--android',
          '--ios',
          '--macos',
          '--windows',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No implementation for Android.'),
              contains('No implementation for iOS.'),
              contains('No implementation for macOS.'),
              contains('SKIPPING: Nothing to test for target platform(s).'),
            ]));

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skips Dart-only plugins', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformMacos: const PlatformDetails(PlatformSupport.inline,
                hasDartCode: true, hasNativeCode: false),
            kPlatformWindows: const PlatformDetails(PlatformSupport.inline,
                hasDartCode: true, hasNativeCode: false),
          },
        );

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--macos',
          '--windows',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('No native code for macOS.'),
              contains('No native code for Windows.'),
              contains('SKIPPING: Nothing to test for target platform(s).'),
            ]));

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('failing one platform does not stop the tests', () async {
        final Directory pluginDir = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
            kPlatformIos: const PlatformDetails(PlatformSupport.inline),
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/test/example_test.java',
          ],
        );

        // Simulate failing Android, but not iOS.
        final String gradlewPath = pluginDir
            .childDirectory('example')
            .childDirectory('android')
            .childFile('gradlew')
            .path;
        processRunner.mockProcessesForExecutable[gradlewPath] = <io.Process>[
          MockProcess(exitCode: 1)
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--android',
          '--ios',
          '--ios-destination',
          'foo_destination',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running tests for Android...'),
            contains('plugin/example unit tests failed.'),
            contains('Running tests for iOS...'),
            contains('Successfully ran iOS xctest for plugin/example'),
            contains('The following packages had errors:'),
            contains('plugin:\n'
                '    Android')
          ]),
        );
      });

      test('failing multiple platforms reports multiple failures', () async {
        final Directory pluginDir = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
            kPlatformIos: const PlatformDetails(PlatformSupport.inline),
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/test/example_test.java',
          ],
        );

        // Simulate failing Android.
        final String gradlewPath = pluginDir
            .childDirectory('example')
            .childDirectory('android')
            .childFile('gradlew')
            .path;
        processRunner.mockProcessesForExecutable[gradlewPath] = <io.Process>[
          MockProcess(exitCode: 1)
        ];
        // Simulate failing Android.
        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(exitCode: 1)
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--android',
          '--ios',
          '--ios-destination',
          'foo_destination',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running tests for Android...'),
            contains('Running tests for iOS...'),
            contains('The following packages had errors:'),
            contains('plugin:\n'
                '    Android\n'
                '    iOS')
          ]),
        );
      });
    });
  });

  group('test native_test_command on Windows', () {
    late FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
      mockPlatform = MockPlatform(isWindows: true);
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final NativeTestCommand command = NativeTestCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>(
          'native_test_command', 'Test for native_test_command');
      runner.addCommand(command);
    });

    group('Windows', () {
      test('runs unit tests', () async {
        const String testBinaryRelativePath =
            'build/windows/foo/Release/bar/plugin_test.exe';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
        });

        final File testBinary = childFileWithSubcomponents(pluginDirectory,
            <String>['example', ...testBinaryRelativePath.split('/')]);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--windows',
          '--no-integration',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running plugin_test.exe...'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });

      test('only runs release unit tests', () async {
        const String debugTestBinaryRelativePath =
            'build/windows/foo/Debug/bar/plugin_test.exe';
        const String releaseTestBinaryRelativePath =
            'build/windows/foo/Release/bar/plugin_test.exe';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$debugTestBinaryRelativePath',
          'example/$releaseTestBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
        });

        final File releaseTestBinary = childFileWithSubcomponents(
            pluginDirectory,
            <String>['example', ...releaseTestBinaryRelativePath.split('/')]);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--windows',
          '--no-integration',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running plugin_test.exe...'),
            contains('No issues found!'),
          ]),
        );

        // Only the release version should be run.
        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(releaseTestBinary.path, const <String>[], null),
            ]));
      });

      test('fails if there are no unit tests', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
            });

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--windows',
          '--no-integration',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No test binaries found.'),
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('fails if a unit test fails', () async {
        const String testBinaryRelativePath =
            'build/windows/foo/Release/bar/plugin_test.exe';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
        });

        final File testBinary = childFileWithSubcomponents(pluginDirectory,
            <String>['example', ...testBinaryRelativePath.split('/')]);

        processRunner.mockProcessesForExecutable[testBinary.path] =
            <io.Process>[MockProcess(exitCode: 1)];

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'native-test',
          '--windows',
          '--no-integration',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running plugin_test.exe...'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });
    });
  });
}
