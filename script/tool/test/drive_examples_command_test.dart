// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/drive_examples_command.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

const String _fakeIosDevice = '67d5c3d1-8bdf-46ad-8f6b-b00e2a972dda';
const String _fakeAndroidDevice = 'emulator-1234';

void main() {
  group('test drive_example_command', () {
    late FileSystem fileSystem;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    setUp(() {
      fileSystem = MemoryFileSystem();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final DriveExamplesCommand command =
          DriveExamplesCommand(packagesDir, processRunner: processRunner);

      runner = CommandRunner<void>(
          'drive_examples_command', 'Test for drive_example_command');
      runner.addCommand(command);
    });

    void setMockFlutterDevicesOutput({
      bool hasIosDevice = true,
      bool hasAndroidDevice = true,
    }) {
      final List<String> devices = <String>[
        if (hasIosDevice) '{"id": "$_fakeIosDevice", "targetPlatform": "ios"}',
        if (hasAndroidDevice)
          '{"id": "$_fakeAndroidDevice", "targetPlatform": "android-x86"}',
      ];
      final String output = '''[${devices.join(',')}]''';

      final MockProcess mockDevicesProcess = MockProcess();
      mockDevicesProcess.exitCodeCompleter.complete(0);
      mockDevicesProcess.stdoutController.close(); // ignore: unawaited_futures
      processRunner.processToReturn = mockDevicesProcess;
      processRunner.resultStdout = output;
    }

    test('fails if no platforms are provided', () async {
      setMockFlutterDevicesOutput();
      expect(
        () => runCapturingPrint(runner, <String>['drive-examples']),
        throwsA(isA<ToolExit>()),
      );
    });

    test('fails for iOS if no iOS devices are present', () async {
      setMockFlutterDevicesOutput(hasIosDevice: false);
      expect(
        () => runCapturingPrint(runner, <String>['drive-examples']),
        throwsA(isA<ToolExit>()),
      );
    });

    test('fails if no platforms are provided', () async {
      setMockFlutterDevicesOutput(hasAndroidDevice: false);
      expect(
        () => runCapturingPrint(runner, <String>['drive-examples']),
        throwsA(isA<ToolExit>()),
      );
    });

    test('fails if multiple platforms are provided', () async {
      setMockFlutterDevicesOutput(hasAndroidDevice: false);
      expect(
        () => runCapturingPrint(
            runner, <String>['drive-examples', '--ios', '--macos']),
        throwsA(isA<ToolExit>()),
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
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformIos: PlatformSupport.inline,
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand, const <String>['devices', '--machine'], null),
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving under folder "test_driver" when test files are missing"',
        () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformIos: PlatformSupport.inline,
        },
      );

      await expectLater(
          () => runCapturingPrint(runner, <String>['drive-examples']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test('a plugin without any integration test files is reported as an error',
        () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/lib/main.dart',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformIos: PlatformSupport.inline,
        },
      );

      await expectLater(
          () => runCapturingPrint(runner, <String>['drive-examples']),
          throwsA(const TypeMatcher<ToolExit>()));
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
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformIos: PlatformSupport.inline,
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String driverTestPath =
          p.join('test_driver', 'integration_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand, const <String>['devices', '--machine'], null),
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--driver',
                  driverTestPath,
                  '--target',
                  p.join('integration_test', 'bar_test.dart'),
                ],
                pluginExampleDirectory.path),
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--driver',
                  driverTestPath,
                  '--target',
                  p.join('integration_test', 'foo_test.dart'),
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          'plugin does not support linux.',
          '\n\n',
          'All driver tests successful!',
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
        platformSupport: <String, PlatformSupport>{
          kPlatformLinux: PlatformSupport.inline,
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  'linux',
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          'plugin does not support macos.',
          '\n\n',
          'All driver tests successful!',
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
        platformSupport: <String, PlatformSupport>{
          kPlatformMacos: PlatformSupport.inline,
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  'macos',
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          'plugin does not support web.',
          '\n\n',
          'All driver tests successful!',
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
        platformSupport: <String, PlatformSupport>{
          kPlatformWeb: PlatformSupport.inline,
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          'plugin does not support windows.',
          '\n\n',
          'All driver tests successful!',
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
        platformSupport: <String, PlatformSupport>{
          kPlatformWindows: PlatformSupport.inline
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  'windows',
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving on an Android plugin', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/plugin_test.dart',
          'example/test_driver/plugin.dart',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
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
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand, const <String>['devices', '--machine'], null),
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  _fakeAndroidDevice,
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
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
        platformSupport: <String, PlatformSupport>{
          kPlatformMacos: PlatformSupport.inline,
        },
      );

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android']);

      expect(
        output,
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          'plugin does not support android.',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      // Output should be empty other than the device query.
      expect(processRunner.recordedCalls, <ProcessCall>[
        ProcessCall(
            flutterCommand, const <String>['devices', '--machine'], null),
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
        platformSupport: <String, PlatformSupport>{
          kPlatformMacos: PlatformSupport.inline,
        },
      );

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        orderedEquals(<String>[
          '\n==========\nChecking plugin...',
          'plugin does not support ios.',
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      // Output should be empty other than the device query.
      expect(processRunner.recordedCalls, <ProcessCall>[
        ProcessCall(
            flutterCommand, const <String>['devices', '--machine'], null),
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
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
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
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline,
          kPlatformIos: PlatformSupport.inline,
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

      final String deviceTestPath = p.join('test_driver', 'plugin.dart');
      final String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand, const <String>['devices', '--machine'], null),
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '-d',
                  _fakeIosDevice,
                  '--enable-experiment=exp1',
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
                ],
                pluginExampleDirectory.path),
          ]));
    });
  });
}
