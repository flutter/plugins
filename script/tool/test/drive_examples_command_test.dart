// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/drive_examples_command.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('test drive_example_command', () {
    CommandRunner<Null> runner;
    RecordingProcessRunner processRunner;
    final String flutterCommand =
        LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';
    setUp(() {
      initializeFakePackages();
      processRunner = RecordingProcessRunner();
      final DriveExamplesCommand command = DriveExamplesCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner);

      runner = CommandRunner<Null>(
          'drive_examples_command', 'Test for drive_example_command');
      runner.addCommand(command);
    });

    tearDown(() {
      cleanupPackages();
    });

    test('driving under folder "test"', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test', 'plugin.dart'],
          ],
          isIosPlugin: true,
          isAndroidPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      String deviceTestPath = p.join('test', 'plugin.dart');
      String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
                  '--driver',
                  driverTestPath,
                  '--target',
                  deviceTestPath
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving under folder "test_driver"', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
          ],
          isAndroidPlugin: true,
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      String deviceTestPath = p.join('test_driver', 'plugin.dart');
      String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
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
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
          ],
          isAndroidPlugin: true,
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      await expectLater(
          () => runCapturingPrint(runner, <String>['drive-examples']),
          throwsA(const TypeMatcher<ToolExit>()));
    });

    test(
        'driving under folder "test_driver" when targets are under "integration_test"',
        () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'integration_test.dart'],
            <String>['example', 'integration_test', 'bar_test.dart'],
            <String>['example', 'integration_test', 'foo_test.dart'],
            <String>['example', 'integration_test', 'ignore_me.dart'],
          ],
          isAndroidPlugin: true,
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      String driverTestPath = p.join('test_driver', 'integration_test.dart');
      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
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
                  '--driver',
                  driverTestPath,
                  '--target',
                  p.join('integration_test', 'foo_test.dart'),
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not support Linux is a no-op', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
          ],
          isMacOsPlugin: false);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--linux',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running drive-examples --linux on a non-Linux
      // plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving on a Linux plugin', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
          ],
          isLinuxPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--linux',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      String deviceTestPath = p.join('test_driver', 'plugin.dart');
      String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      print(processRunner.recordedCalls);
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
      createFakePlugin('plugin', withExtraFiles: <List<String>>[
        <String>['example', 'test_driver', 'plugin_test.dart'],
        <String>['example', 'test_driver', 'plugin.dart'],
      ]);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--macos',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running drive-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });
    test('driving on a macOS plugin', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
            <String>['example', 'macos', 'macos.swift'],
          ],
          isMacOsPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--macos',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      String deviceTestPath = p.join('test_driver', 'plugin.dart');
      String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      print(processRunner.recordedCalls);
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

    test('driving when plugin does not suppport windows is a no-op', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
          ],
          isMacOsPlugin: false);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--windows',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running drive-examples --windows on a non-windows
      // plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('driving on a Windows plugin', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
          ],
          isWindowsPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--windows',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      String deviceTestPath = p.join('test_driver', 'plugin.dart');
      String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      print(processRunner.recordedCalls);
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

    test('driving when plugin does not support mobile is no-op', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test_driver', 'plugin.dart'],
          ],
          isMacOsPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
      ]);

      expect(
        output,
        orderedEquals(<String>[
          '\n\n',
          'All driver tests successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running drive-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('enable-experiment flag', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test_driver', 'plugin_test.dart'],
            <String>['example', 'test', 'plugin.dart'],
          ],
          isIosPlugin: true,
          isAndroidPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--enable-experiment=exp1',
      ]);

      String deviceTestPath = p.join('test', 'plugin.dart');
      String driverTestPath = p.join('test_driver', 'plugin_test.dart');
      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                <String>[
                  'drive',
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
