// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/cmake.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/native_test_command.dart';
import 'package:platform/platform.dart';
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

const String _fakeCmakeCommand = 'path/to/cmake';

void _createFakeCMakeCache(Directory pluginDir, Platform platform) {
  final CMakeProject project = CMakeProject(pluginDir.childDirectory('example'),
      platform: platform, buildMode: 'Release');
  final File cache = project.buildDirectory.childFile('CMakeCache.txt');
  cache.createSync(recursive: true);
  cache.writeAsStringSync('CMAKE_COMMAND:INTERNAL=$_fakeCmakeCommand');
}

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
      // iOS and macOS tests expect macOS, Linux tests expect Linux; nothing
      // needs to distinguish between Linux and macOS, so set both to true to
      // allow them to share a setup group.
      mockPlatform = MockPlatform(isMacOS: true, isLinux: true);
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final NativeTestCommand command = NativeTestCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>(
          'native_test_command', 'Test for native_test_command');
      runner.addCommand(command);
    });

    // Returns a MockProcess to provide for "xcrun xcodebuild -list" for a
    // project that contains [targets].
    MockProcess _getMockXcodebuildListProcess(List<String> targets) {
      final Map<String, dynamic> projects = <String, dynamic>{
        'project': <String, dynamic>{
          'targets': targets,
        }
      };
      return MockProcess(stdout: jsonEncode(projects));
    }

    // Returns the ProcessCall to expect for checking the targets present in
    // the [package]'s [platform]/Runner.xcodeproj.
    ProcessCall _getTargetCheckCall(Directory package, String platform) {
      return ProcessCall(
          'xcrun',
          <String>[
            'xcodebuild',
            '-list',
            '-json',
            '-project',
            package
                .childDirectory(platform)
                .childDirectory('Runner.xcodeproj')
                .path,
          ],
          null);
    }

    // Returns the ProcessCall to expect for running the tests in the
    // workspace [platform]/Runner.xcworkspace, with the given extra flags.
    ProcessCall _getRunTestCall(
      Directory package,
      String platform, {
      String? destination,
      List<String> extraFlags = const <String>[],
    }) {
      return ProcessCall(
          'xcrun',
          <String>[
            'xcodebuild',
            'test',
            '-workspace',
            '$platform/Runner.xcworkspace',
            '-scheme',
            'Runner',
            '-configuration',
            'Debug',
            if (destination != null) ...<String>['-destination', destination],
            ...extraFlags,
            'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
          ],
          package.path);
    }

    // Returns the ProcessCall to expect for build the Linux unit tests for the
    // given plugin.
    ProcessCall _getLinuxBuildCall(Directory pluginDir) {
      return ProcessCall(
          'cmake',
          <String>[
            '--build',
            pluginDir
                .childDirectory('example')
                .childDirectory('build')
                .childDirectory('linux')
                .childDirectory('x64')
                .childDirectory('release')
                .path,
            '--target',
            'unit_tests'
          ],
          null);
    }

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
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory =
          pluginDirectory1.childDirectory('example');

      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        _getMockXcodebuildListProcess(<String>['RunnerTests', 'RunnerUITests']),
        // Exit code 66 from testing indicates no tests.
        MockProcess(exitCode: 66),
      ];
      final List<String> output = await runCapturingPrint(
          runner, <String>['native-test', '--macos', '--no-unit']);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No tests found.'),
            contains('Skipped 1 package(s)'),
          ]));

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            _getTargetCheckCall(pluginExampleDirectory, 'macos'),
            _getRunTestCall(pluginExampleDirectory, 'macos',
                extraFlags: <String>['-only-testing:RunnerUITests']),
          ]));
    });

    group('iOS', () {
      test('skip if iOS is not supported', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
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
              platformIOS: const PlatformDetails(PlatformSupport.federated)
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
          platformIOS: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
        ];

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
              _getTargetCheckCall(pluginExampleDirectory, 'ios'),
              _getRunTestCall(pluginExampleDirectory, 'ios',
                  destination: 'foo_destination'),
            ]));
      });

      test('Not specifying --ios-destination assigns an available simulator',
          () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformDetails>{
          platformIOS: const PlatformDetails(PlatformSupport.inline)
        });
        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(stdout: jsonEncode(_kDeviceListMap)), // simctl
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
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
              _getTargetCheckCall(pluginExampleDirectory, 'ios'),
              _getRunTestCall(pluginExampleDirectory, 'ios',
                  destination: 'id=1E76A0FD-38AC-4537-A989-EA639D7D012A'),
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
              platformMacOS: const PlatformDetails(PlatformSupport.federated),
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
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
        ];

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
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
              _getRunTestCall(pluginExampleDirectory, 'macos'),
            ]));
      });
    });

    group('Android', () {
      test('runs Java unit tests in Android implementation folder', () async {
        final Directory plugin = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
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

      test(
          'ignores Java integration test files associated with integration_test',
          () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/androidTest/java/io/flutter/plugins/DartIntegrationTest.java',
            'example/android/app/src/androidTest/java/io/flutter/plugins/plugin/FlutterActivityTest.java',
            'example/android/app/src/androidTest/java/io/flutter/plugins/plugin/MainActivityTest.java',
          ],
        );

        await runCapturingPrint(
            runner, <String>['native-test', '--android', '--no-unit']);

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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'android/src/test/example_test.java',
            'example/android/gradlew',
          ],
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android'],
            errorHandler: (Error e) {
          // Having no unit tests is fatal, but that's not the point of this
          // test so just ignore the failure.
        });

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

      test('fails when a unit test fails', () async {
        final Directory pluginDir = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
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

      test('fails when an integration test fails', () async {
        final Directory pluginDir = createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/test/example_test.java',
            'example/android/app/src/androidTest/IntegrationTest.java',
          ],
        );

        final String gradlewPath = pluginDir
            .childDirectory('example')
            .childDirectory('android')
            .childFile('gradlew')
            .path;
        processRunner.mockProcessesForExecutable[gradlewPath] = <io.Process>[
          MockProcess(), // unit passes
          MockProcess(exitCode: 1), // integration fails
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
            contains('plugin/example integration tests failed.'),
            contains('The following packages had errors:'),
            contains('plugin')
          ]),
        );
      });

      test('fails if there are no unit tests', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/androidTest/IntegrationTest.java',
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
            contains('No Android unit tests found for plugin/example'),
            contains(
                'No unit tests ran. Plugins are required to have unit tests.'),
            contains('The following packages had errors:'),
            contains('plugin:\n'
                '    No unit tests ran (use --exclude if this is intentional).')
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

      test('skips when running no tests in integration-only mode', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          },
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['native-test', '--android', '--no-unit']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No Android integration tests found for plugin/example'),
            contains('SKIPPING: No tests found.'),
          ]),
        );
      });
    });

    group('Linux', () {
      test('builds and runs unit tests', () async {
        const String testBinaryRelativePath =
            'build/linux/x64/release/bar/plugin_test';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          platformLinux: const PlatformDetails(PlatformSupport.inline),
        });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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
              _getLinuxBuildCall(pluginDirectory),
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });

      test('only runs release unit tests', () async {
        const String debugTestBinaryRelativePath =
            'build/linux/x64/debug/bar/plugin_test';
        const String releaseTestBinaryRelativePath =
            'build/linux/x64/release/bar/plugin_test';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$debugTestBinaryRelativePath',
          'example/$releaseTestBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          platformLinux: const PlatformDetails(PlatformSupport.inline),
        });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              _getLinuxBuildCall(pluginDirectory),
              ProcessCall(releaseTestBinary.path, const <String>[], null),
            ]));
      });

      test('fails if CMake has not been configured', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformLinux: const PlatformDetails(PlatformSupport.inline),
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
            contains('plugin:\n'
                '    Examples must be built before testing.')
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('fails if there are no unit tests', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformLinux: const PlatformDetails(PlatformSupport.inline),
            });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              _getLinuxBuildCall(pluginDirectory),
            ]));
      });

      test('fails if a unit test fails', () async {
        const String testBinaryRelativePath =
            'build/linux/x64/release/bar/plugin_test';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          platformLinux: const PlatformDetails(PlatformSupport.inline),
        });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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
              _getLinuxBuildCall(pluginDirectory),
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });
    });

    // Tests behaviors of implementation that is shared between iOS and macOS.
    group('iOS/macOS', () {
      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
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
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
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
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
              _getRunTestCall(pluginExampleDirectory, 'macos',
                  extraFlags: <String>['-only-testing:RunnerTests']),
            ]));
      });

      test('honors integration-only', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
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
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
              _getRunTestCall(pluginExampleDirectory, 'macos',
                  extraFlags: <String>['-only-testing:RunnerUITests']),
            ]));
      });

      test('skips when the requested target is not present', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        // Simulate a project with unit tests but no integration tests...
        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(<String>['RunnerTests']),
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
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
            ]));
      });

      test('fails if there are no unit tests', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(<String>['RunnerUITests']),
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
              contains('No "RunnerTests" target in plugin/example; skipping.'),
              contains(
                  'No unit tests ran. Plugins are required to have unit tests.'),
              contains('The following packages had errors:'),
              contains('plugin:\n'
                  '    No unit tests ran (use --exclude if this is intentional).'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
            ]));
      });

      test('fails if unable to check for requested target', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
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
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
            platformIOS: const PlatformDetails(PlatformSupport.inline),
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          },
        );

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');
        final Directory androidFolder =
            pluginExampleDirectory.childDirectory('android');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']), // iOS list
          MockProcess(), // iOS run
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']), // macOS list
          MockProcess(), // macOS run
        ];

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
              _getTargetCheckCall(pluginExampleDirectory, 'ios'),
              _getRunTestCall(pluginExampleDirectory, 'ios',
                  destination: 'foo_destination'),
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
              _getRunTestCall(pluginExampleDirectory, 'macos'),
            ]));
      });

      test('runs only macOS for a macOS plugin', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
        ];

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
              _getTargetCheckCall(pluginExampleDirectory, 'macos'),
              _getRunTestCall(pluginExampleDirectory, 'macos'),
            ]));
      });

      test('runs only iOS for a iOS plugin', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformDetails>{
          platformIOS: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
        ];

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
              _getTargetCheckCall(pluginExampleDirectory, 'ios'),
              _getRunTestCall(pluginExampleDirectory, 'ios',
                  destination: 'foo_destination'),
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
            platformMacOS: const PlatformDetails(PlatformSupport.inline,
                hasDartCode: true, hasNativeCode: false),
            platformWindows: const PlatformDetails(PlatformSupport.inline,
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
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          },
          extraFiles: <String>[
            'example/android/gradlew',
            'example/android/app/src/test/example_test.java',
          ],
        );

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          _getMockXcodebuildListProcess(
              <String>['RunnerTests', 'RunnerUITests']),
        ];

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
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
            platformIOS: const PlatformDetails(PlatformSupport.inline),
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

    // Returns the ProcessCall to expect for build the Windows unit tests for
    // the given plugin.
    ProcessCall _getWindowsBuildCall(Directory pluginDir) {
      return ProcessCall(
          _fakeCmakeCommand,
          <String>[
            '--build',
            pluginDir
                .childDirectory('example')
                .childDirectory('build')
                .childDirectory('windows')
                .path,
            '--target',
            'unit_tests',
            '--config',
            'Debug'
          ],
          null);
    }

    group('Windows', () {
      test('runs unit tests', () async {
        const String testBinaryRelativePath =
            'build/windows/Debug/bar/plugin_test.exe';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          platformWindows: const PlatformDetails(PlatformSupport.inline),
        });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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
              _getWindowsBuildCall(pluginDirectory),
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });

      test('only runs debug unit tests', () async {
        const String debugTestBinaryRelativePath =
            'build/windows/Debug/bar/plugin_test.exe';
        const String releaseTestBinaryRelativePath =
            'build/windows/Release/bar/plugin_test.exe';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$debugTestBinaryRelativePath',
          'example/$releaseTestBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          platformWindows: const PlatformDetails(PlatformSupport.inline),
        });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

        final File debugTestBinary = childFileWithSubcomponents(pluginDirectory,
            <String>['example', ...debugTestBinaryRelativePath.split('/')]);

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
              _getWindowsBuildCall(pluginDirectory),
              ProcessCall(debugTestBinary.path, const <String>[], null),
            ]));
      });

      test('fails if CMake has not been configured', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformWindows: const PlatformDetails(PlatformSupport.inline),
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
            contains('plugin:\n'
                '    Examples must be built before testing.')
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('fails if there are no unit tests', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformWindows: const PlatformDetails(PlatformSupport.inline),
            });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              _getWindowsBuildCall(pluginDirectory),
            ]));
      });

      test('fails if a unit test fails', () async {
        const String testBinaryRelativePath =
            'build/windows/Debug/bar/plugin_test.exe';
        final Directory pluginDirectory =
            createFakePlugin('plugin', packagesDir, extraFiles: <String>[
          'example/$testBinaryRelativePath'
        ], platformSupport: <String, PlatformDetails>{
          platformWindows: const PlatformDetails(PlatformSupport.inline),
        });
        _createFakeCMakeCache(pluginDirectory, mockPlatform);

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
              _getWindowsBuildCall(pluginDirectory),
              ProcessCall(testBinary.path, const <String>[], null),
            ]));
      });
    });
  });
}
