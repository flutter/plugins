// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/build_examples_command.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('test build_example_command', () {
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    setUp(() {
      initializeFakePackages();
      processRunner = RecordingProcessRunner();
      final BuildExamplesCommand command = BuildExamplesCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner);

      runner = CommandRunner<void>(
          'build_examples_command', 'Test for build_example_command');
      runner.addCommand(command);
      cleanupPackages();
    });

    test('building for iOS when plugin is not set up for iOS results in no-op',
        () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: false);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--ipa', '--no-macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING IPA for $packageName',
          'iOS is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      cleanupPackages();
    });

    test('building for ios', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--ipa',
        '--no-macos',
        '--enable-experiment=exp1'
      ]);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING IPA for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                const <String>[
                  'build',
                  'ios',
                  '--no-codesign',
                  '--enable-experiment=exp1'
                ],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test(
        'building for Linux when plugin is not set up for Linux results in no-op',
        () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: false);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--linux']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Linux for $packageName',
          'Linux is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --linux with no
      // Linux implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      cleanupPackages();
    });

    test('building for Linux', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--linux']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Linux for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'linux'],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test('building for macos with no implementation results in no-op',
        () async {
      createFakePlugin('plugin', withExtraFiles: <List<String>>[
        <String>['example', 'test'],
      ]);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING macOS for $packageName',
          'macOS is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      cleanupPackages();
    });

    test('building for macos', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
            <String>['example', 'macos', 'macos.swift'],
          ],
          isMacOsPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING macOS for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'macos'],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test('building for web with no implementation results in no-op', () async {
      createFakePlugin('plugin', withExtraFiles: <List<String>>[
        <String>['example', 'test'],
      ]);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--web']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING web for $packageName',
          'Web is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      cleanupPackages();
    });

    test('building for web', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
            <String>['example', 'web', 'index.html'],
          ],
          isWebPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--web']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING web for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'web'],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test(
        'building for Windows when plugin is not set up for Windows results in no-op',
        () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: false);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--windows']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Windows for $packageName',
          'Windows is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      cleanupPackages();
    });

    test('building for windows', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--windows']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Windows for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'windows'],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test(
        'building for Android when plugin is not set up for Android results in no-op',
        () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: false);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--apk', '--no-ipa']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING APK for $packageName',
          'Android is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      cleanupPackages();
    });

    test('building for android', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isAndroidPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--apk',
        '--no-ipa',
        '--no-macos',
      ]);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: mockPackagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING APK for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'apk'],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test('enable-experiment flag for Android', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isAndroidPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      await runCapturingPrint(runner, <String>[
        'build-examples',
        '--apk',
        '--no-ipa',
        '--no-macos',
        '--enable-experiment=exp1'
      ]);

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                const <String>['build', 'apk', '--enable-experiment=exp1'],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });

    test('enable-experiment flag for ios', () async {
      createFakePlugin('plugin',
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          mockPackagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      await runCapturingPrint(runner, <String>[
        'build-examples',
        '--ipa',
        '--no-macos',
        '--enable-experiment=exp1'
      ]);
      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                const <String>[
                  'build',
                  'ios',
                  '--no-codesign',
                  '--enable-experiment=exp1'
                ],
                pluginExampleDirectory.path),
          ]));
      cleanupPackages();
    });
  });
}
