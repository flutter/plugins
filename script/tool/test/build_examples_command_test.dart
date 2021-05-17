// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_tools/src/build_examples_command.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('test build_example_command', () {
    late FileSystem fileSystem;
    late Directory testRoot;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    setUp(() {
      // UWP builds call 'flutter create', so the test has to use the real
      // filesystem. Put everything possible in a unique temporary to minimize
      // effect on the host system.
      // TODO(stuartmorgan): Switch to a memory filesystem once the UWP template
      // is stable so calls to 'flutter create' are no longer needed.
      fileSystem = const LocalFileSystem();
      testRoot = fileSystem.systemTempDirectory.createTempSync();
      packagesDir = testRoot.childDirectory('packages');
      createPackagesDirectory(parentDir: packagesDir.parent);
      processRunner = RecordingProcessRunner();
      final BuildExamplesCommand command =
          BuildExamplesCommand(packagesDir, processRunner: processRunner);

      runner = CommandRunner<void>(
          'build_examples_command', 'Test for build_example_command');
      runner.addCommand(command);
    });

    tearDown(() {
      testRoot.deleteSync(recursive: true);
    });

    test('building for iOS when plugin is not set up for iOS results in no-op',
        () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: false);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--ipa', '--no-macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING IPA for $packageName',
          'iOS is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for ios', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--ipa',
        '--no-macos',
        '--enable-experiment=exp1'
      ]);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING IPA for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

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
    });

    test(
        'building for Linux when plugin is not set up for Linux results in no-op',
        () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: false);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--linux']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Linux for $packageName',
          'Linux is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      // Output should be empty since running build-examples --linux with no
      // Linux implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for Linux', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--linux']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Linux for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'linux'],
                pluginExampleDirectory.path),
          ]));
    });

    test('building for macos with no implementation results in no-op',
        () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ]);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING macOS for $packageName',
          'macOS is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for macos', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
            <String>['example', 'macos', 'macos.swift'],
          ],
          isMacOsPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING macOS for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'macos'],
                pluginExampleDirectory.path),
          ]));
    });

    test('building for web with no implementation results in no-op', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ]);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--web']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING web for $packageName',
          'Web is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for web', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
            <String>['example', 'web', 'index.html'],
          ],
          isWebPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--web']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING web for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'web'],
                pluginExampleDirectory.path),
          ]));
    });

    test(
        'building for Windows when plugin is not set up for Windows results in no-op',
        () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: false);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--windows']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Windows for $packageName',
          'Windows is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for windows', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--windows']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING Windows for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'windows'],
                pluginExampleDirectory.path),
          ]));
    });

    test(
        'building for UWP when plugin is not set up for Windows results in no-op',
        () async {
      createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: false);

      final Directory pluginExampleDirectory =
          packagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--winuwp']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING UWP for $packageName',
          'Windows is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for UWP', () async {
      createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: true);

      final Directory pluginExampleDirectory =
          packagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--winuwp']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING UWP for $packageName',
          'Creating temporary winuwp folder',
          '\n\n',
          'All builds successful!',
        ]),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'winuwp'],
                pluginExampleDirectory.path),
          ]));
    });

    test('building for UWP creates a folder if necessary', () async {
      createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isWindowsPlugin: true);

      final Directory pluginExampleDirectory =
          packagesDir.childDirectory('plugin').childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--no-ipa', '--winuwp']);

      expect(
        output,
        contains('Creating temporary winuwp folder'),
      );

      print(processRunner.recordedCalls);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                const <String>['create', '--platforms=winuwp', '.'],
                pluginExampleDirectory.path),
            ProcessCall(flutterCommand, const <String>['build', 'winuwp'],
                pluginExampleDirectory.path),
          ]));
    });

    test(
        'building for Android when plugin is not set up for Android results in no-op',
        () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isLinuxPlugin: false);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--apk', '--no-ipa']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING APK for $packageName',
          'Android is not supported by this plugin',
          '\n\n',
          'All builds successful!',
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for android', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isAndroidPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--apk',
        '--no-ipa',
        '--no-macos',
      ]);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        orderedEquals(<String>[
          '\nBUILDING APK for $packageName',
          '\n\n',
          'All builds successful!',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(flutterCommand, const <String>['build', 'apk'],
                pluginExampleDirectory.path),
          ]));
    });

    test('enable-experiment flag for Android', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isAndroidPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      await runCapturingPrint(runner, <String>[
        'build-examples',
        '--apk',
        '--no-ipa',
        '--no-macos',
        '--enable-experiment=exp1'
      ]);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                flutterCommand,
                const <String>['build', 'apk', '--enable-experiment=exp1'],
                pluginExampleDirectory.path),
          ]));
    });

    test('enable-experiment flag for ios', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      await runCapturingPrint(runner, <String>[
        'build-examples',
        '--ipa',
        '--no-macos',
        '--enable-experiment=exp1'
      ]);
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
    });
  });
}
