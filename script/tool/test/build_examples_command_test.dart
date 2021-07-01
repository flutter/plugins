// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/build_examples_command.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('build-example', () {
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
      final BuildExamplesCommand command =
          BuildExamplesCommand(packagesDir, processRunner: processRunner);

      runner = CommandRunner<void>(
          'build_examples_command', 'Test for build_example_command');
      runner.addCommand(command);
    });

    test('fails if no plaform flags are passed', () async {
      expect(
        () => runCapturingPrint(runner, <String>['build-examples']),
        throwsA(isA<ToolExit>()),
      );
    });

    test('building for iOS when plugin is not set up for iOS results in no-op',
        () async {
      createFakePlugin('plugin', packagesDir,
          extraFiles: <String>['example/test']);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('iOS is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for ios', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformIos: PlatformSupport.inline
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(runner,
          <String>['build-examples', '--ios', '--enable-experiment=exp1']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING $packageName for iOS',
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
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test',
      ]);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--linux']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Linux is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --linux with no
      // Linux implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for Linux', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformLinux: PlatformSupport.inline,
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--linux']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING $packageName for Linux',
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
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test',
      ]);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--macos']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('macOS is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for macos', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
          'example/macos/macos.swift',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformMacos: PlatformSupport.inline,
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--macos']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING $packageName for macOS',
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
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test',
      ]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--web']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('web is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for web', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformWeb: PlatformSupport.inline,
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--web']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING $packageName for web',
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
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test',
      ]);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--windows']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Windows is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --windows with no
      // Windows implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for windows', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformWindows: PlatformSupport.inline
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--windows']);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING $packageName for Windows',
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
        'building for Android when plugin is not set up for Android results in no-op',
        () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/test',
      ]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--apk']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Android is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for android', () async {
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--apk',
      ]);
      final String packageName =
          p.relative(pluginExampleDirectory.path, from: packagesDir.path);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING $packageName for Android (apk)',
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
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      await runCapturingPrint(runner,
          <String>['build-examples', '--apk', '--enable-experiment=exp1']);

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
      final Directory pluginDirectory = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test',
        ],
        platformSupport: <String, PlatformSupport>{
          kPlatformIos: PlatformSupport.inline
        },
      );

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      await runCapturingPrint(runner,
          <String>['build-examples', '--ios', '--enable-experiment=exp1']);
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
