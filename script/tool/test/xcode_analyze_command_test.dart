// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/xcode_analyze_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

// TODO(stuartmorgan): Rework these tests to use a mock Xcode instead of
// doing all the process mocking and validation.
void main() {
  group('test xcode_analyze_command', () {
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
      final XcodeAnalyzeCommand command = XcodeAnalyzeCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>(
          'xcode_analyze_command', 'Test for xcode_analyze_command');
      runner.addCommand(command);
    });

    test('Fails if no platforms are provided', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['xcode-analyze'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('At least one platform flag must be provided'),
        ]),
      );
    });

    group('iOS', () {
      test('skip if iOS is not supported', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final List<String> output =
            await runCapturingPrint(runner, <String>['xcode-analyze', '--ios']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if iOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output =
            await runCapturingPrint(runner, <String>['xcode-analyze', '--ios']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for iOS plugin', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformDetails>{
          platformIOS: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin'),
              contains('plugin/example (iOS) passed analysis.')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(exitCode: 1)
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>[
            'xcode-analyze',
            '--ios',
          ],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('The following packages had errors:'),
              contains('  plugin'),
            ]));
      });
    });

    group('macOS', () {
      test('skip if macOS is not supported', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['xcode-analyze', '--macos']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if macOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.federated),
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['xcode-analyze', '--macos']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
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

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--macos',
        ]);

        expect(output,
            contains(contains('plugin/example (macOS) passed analysis.')));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'analyze',
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

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess(exitCode: 1)
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['xcode-analyze', '--macos'],
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
    });

    group('combined', () {
      test('runs both iOS and macOS when supported', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline),
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAll(<Matcher>[
              contains('plugin/example (iOS) passed analysis.'),
              contains('plugin/example (macOS) passed analysis.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'analyze',
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
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('plugin/example (macOS) passed analysis.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'analyze',
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
          platformIOS: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(
                <Matcher>[contains('plugin/example (iOS) passed analysis.')]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('skips when neither are supported', () async {
        createFakePlugin('plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('SKIPPING: Not implemented for target platform(s).'),
            ]));

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });
    });
  });
}
