// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/drive_examples_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

const String _fakeIosDevice = '67d5c3d1-8bdf-46ad-8f6b-b00e2a972dda';
const String _fakeAndroidDevice = 'emulator-1234';

void main() {
  group('test drive_example_command', () {
    late FileSystem fileSystem;
    late Platform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final DriveExamplesCommand command = DriveExamplesCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>(
          'drive_examples_command', 'Test for drive_example_command');
      runner.addCommand(command);
    });

    void setMockFlutterDevicesOutput({
      bool hasIosDevice = true,
      bool hasAndroidDevice = true,
      bool includeBanner = false,
    }) {
      const String updateBanner = '''
╔════════════════════════════════════════════════════════════════════════════╗
║ A new version of Flutter is available!                                     ║
║                                                                            ║
║ To update to the latest version, run "flutter upgrade".                    ║
╚════════════════════════════════════════════════════════════════════════════╝
''';
      final List<String> devices = <String>[
        if (hasIosDevice) '{"id": "$_fakeIosDevice", "targetPlatform": "ios"}',
        if (hasAndroidDevice)
          '{"id": "$_fakeAndroidDevice", "targetPlatform": "android-x86"}',
      ];
      final String output =
          '''${includeBanner ? updateBanner : ''}[${devices.join(',')}]''';

      final MockProcess mockDevicesProcess =
          MockProcess(stdout: output, stdoutEncoding: utf8);
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <io.Process>[mockDevicesProcess];
    }

    test('fails if no platforms are provided', () async {
      setMockFlutterDevicesOutput();
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Exactly one of'),
        ]),
      );
    });

    test('fails if multiple platforms are provided', () async {
      setMockFlutterDevicesOutput();
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios', '--macos'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Exactly one of'),
        ]),
      );
    });

    test('fails for iOS if no iOS devices are present', () async {
      setMockFlutterDevicesOutput(hasIosDevice: false);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No iOS devices'),
        ]),
      );
    });

    test('handles flutter tool banners when checking devices', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/integration_test/foo_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformIos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput(includeBanner: true);
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails for iOS if getting devices fails', () async {
      // Simulate failure from `flutter devices`.
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <io.Process>[MockProcess(exitCode: 1)];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No iOS devices'),
        ]),
      );
    });

    test('fails for Android if no Android devices are present', () async {
      setMockFlutterDevicesOutput(hasAndroidDevice: false);
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No Android devices'),
        ]),
      );
    });

    test('driving under folder "test_driver"', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
          kPlatformIos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving under folder "test_driver" when test files are missing"',
        () async {
      setMockFlutterDevicesOutput();
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
          kPlatformIos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('No test files for example/test_driver/plugin_test.dart'),
        ]),
      );
    });

    test('a plugin without any integration test files is reported as an error',
        () async {
      setMockFlutterDevicesOutput();
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/lib/main.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
          kPlatformIos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('No tests ran'),
        ]),
      );
    });

    test(
        'driving under folder "test_driver" when targets are under "integration_test"',
        () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
          'example/integration_test/ignore_me.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
          kPlatformIos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/bar_test.dart',
                ],
                pluginExampleDirectory.path),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/foo_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not support Linux is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test_driver/plugin_test.dart',
        'example/test_driver/plugin.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--linux',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform linux...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --linux on a non-Linux
      // plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving on a Linux plugin', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformLinux: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--linux',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'linux',
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not suppport macOS is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test_driver/plugin_test.dart',
        'example/test_driver/plugin.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--macos',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform macos...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving on a macOS plugin', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
          'example/macos/macos.swift',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--macos',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'macos',
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not suppport web is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test_driver/plugin_test.dart',
        'example/test_driver/plugin.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--web',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --web on a non-web
      // plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving a web plugin', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--web',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not suppport Windows is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test_driver/plugin_test.dart',
        'example/test_driver/plugin.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--windows',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform windows...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --windows on a
      // non-Windows plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving on a Windows plugin', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--windows',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'windows',
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving UWP is a no-op', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformWindows: const PlatformDetails(PlatformSupport.inline,
              variants: <String>[platformVariantWinUwp]),
        },
      );

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--winuwp',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Driving UWP applications is not yet supported'),
          contains('Running for plugin'),
          contains('SKIPPING: Drive does not yet support UWP'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --windows on a
      // non-Windows plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving on an Android plugin', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--android',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  _fakeAndroidDevice,
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not support Android is no-op', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform android...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty other than the device query.
      expect(processRunner.recordedCalls, <ProcessCall>[
        ProcessCall(getFlutterCommand(mockPlatform),
            const <String>['devices', '--machine'], null),
      ]);
    });

    test('driving when plugin does not support iOS is no-op', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform ios...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty other than the device query.
      expect(processRunner.recordedCalls, <ProcessCall>[
        ProcessCall(getFlutterCommand(mockPlatform),
            const <String>['devices', '--machine'], null),
      ]);
    });

    test('platform interface plugins are silently skipped', () async {
      createFakePlugin('aplugin_platform_interface', packagesDir,
          examples: <String>[]);

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--macos']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for aplugin_platform_interface'),
          contains(
              'SKIPPING: Platform interfaces are not expected to have integration tests.'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since it's skipped.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('enable-experiment flag', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformAndroid: const PlatformDetails(PlatformSupport.inline),
          kPlatformIos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      setMockFlutterDevicesOutput();
      await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--ios',
        '--enable-experiment=exp1',
      ]);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--enable-experiment=exp1',
                  '--driver',
                  'test_driver/plugin_test.dart',
                  '--target',
                  'test_driver/plugin.dart'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('fails when no example is present', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        examples: <String>[],
        platformSupport: <String, PlatformDetails>{
          kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests were run (0 example(s) found).'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    No tests ran (use --exclude if this is intentional)'),
        ]),
      );
    });

    test('fails when no driver is present', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests found for plugin/example'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    No tests ran (use --exclude if this is intentional)'),
        ]),
      );
    });

    test('fails when no integration tests are present', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Found example/test_driver/integration_test.dart, but no '
              'integration_test/*_test.dart files.'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    No test files for example/test_driver/integration_test.dart\n'
              '    No tests ran (use --exclude if this is intentional)'),
        ]),
      );
    });

    test('reports test failures', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          kPlatformMacos: const PlatformDetails(PlatformSupport.inline),
        },
      );

      // Simulate failure from `flutter drive`.
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <io.Process>[
        // No mock for 'devices', since it's running for macOS.
        MockProcess(exitCode: 1), // 'drive' #1
        MockProcess(exitCode: 1), // 'drive' #2
      ];

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--macos'],
              errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    example/integration_test/bar_test.dart\n'
              '    example/integration_test/foo_test.dart'),
        ]),
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'macos',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/bar_test.dart',
                ],
                pluginExampleDirectory.path),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'macos',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/foo_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });
  });
}
