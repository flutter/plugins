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
import 'package:flutter_plugin_tools/src/xctest_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

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

  group('test xctest_command', () {
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
      final XCTestCommand command = XCTestCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>('xctest_command', 'Test for xctest_command');
      runner.addCommand(command);
    });

    test('Fails if no platforms are provided', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['xctest'], errorHandler: (Error e) {
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

    test('allows target filtering', () async {
      final Directory pluginDirectory1 = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformSupport>{
            kPlatformMacos: PlatformSupport.inline,
          });

      final Directory pluginExampleDirectory =
          pluginDirectory1.childDirectory('example');

      processRunner.processToReturn = MockProcess.succeeding();
      processRunner.resultStdout = '{"project":{"targets":["RunnerTests"]}}';

      final List<String> output = await runCapturingPrint(runner, <String>[
        'xctest',
        '--macos',
        '--test-target=RunnerTests',
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

    test('skips when the requested target is not present', () async {
      final Directory pluginDirectory1 = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformSupport>{
            kPlatformMacos: PlatformSupport.inline,
          });

      final Directory pluginExampleDirectory =
          pluginDirectory1.childDirectory('example');

      processRunner.processToReturn = MockProcess.succeeding();
      processRunner.resultStdout = '{"project":{"targets":["Runner"]}}';
      final List<String> output = await runCapturingPrint(runner, <String>[
        'xctest',
        '--macos',
        '--test-target=RunnerTests',
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No "RunnerTests" target in plugin/example; skipping.'),
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
      final Directory pluginDirectory1 = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformSupport>{
            kPlatformMacos: PlatformSupport.inline,
          });

      final Directory pluginExampleDirectory =
          pluginDirectory1.childDirectory('example');

      processRunner.processToReturn = MockProcess.failing();

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'xctest',
        '--macos',
        '--test-target=RunnerTests',
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

    test('reports skips with no tests', () async {
      final Directory pluginDirectory1 = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformSupport>{
            kPlatformMacos: PlatformSupport.inline,
          });

      final Directory pluginExampleDirectory =
          pluginDirectory1.childDirectory('example');

      // Exit code 66 from testing indicates no tests.
      final MockProcess noTestsProcessResult = MockProcess();
      noTestsProcessResult.exitCodeCompleter.complete(66);
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        noTestsProcessResult,
      ];
      final List<String> output =
          await runCapturingPrint(runner, <String>['xctest', '--macos']);

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
            platformSupport: <String, PlatformSupport>{
              kPlatformMacos: PlatformSupport.inline,
            });

        final List<String> output = await runCapturingPrint(runner,
            <String>['xctest', '--ios', _kDestination, 'foo_destination']);
        expect(
            output,
            contains(
                contains('iOS is not implemented by this plugin package.')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if iOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformSupport>{
              kPlatformIos: PlatformSupport.federated
            });

        final List<String> output = await runCapturingPrint(runner,
            <String>['xctest', '--ios', _kDestination, 'foo_destination']);
        expect(
            output,
            contains(
                contains('iOS is not implemented by this plugin package.')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('running with correct destination', () async {
        final Directory pluginDirectory = createFakePlugin(
            'plugin', packagesDir, platformSupport: <String, PlatformSupport>{
          kPlatformIos: PlatformSupport.inline
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xctest',
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
            'plugin', packagesDir, platformSupport: <String, PlatformSupport>{
          kPlatformIos: PlatformSupport.inline
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        processRunner.processToReturn = MockProcess.succeeding();
        processRunner.resultStdout = jsonEncode(_kDeviceListMap);
        await runCapturingPrint(runner, <String>['xctest', '--ios']);

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

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformSupport>{
              kPlatformIos: PlatformSupport.inline
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess.failing()
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>[
            'xctest',
            '--ios',
            _kDestination,
            'foo_destination',
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
        createFakePlugin('plugin', packagesDir);

        final List<String> output =
            await runCapturingPrint(runner, <String>['xctest', '--macos']);
        expect(
            output,
            contains(
                contains('macOS is not implemented by this plugin package.')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if macOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformSupport>{
              kPlatformMacos: PlatformSupport.federated,
            });

        final List<String> output =
            await runCapturingPrint(runner, <String>['xctest', '--macos']);
        expect(
            output,
            contains(
                contains('macOS is not implemented by this plugin package.')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for macOS plugin', () async {
        final Directory pluginDirectory1 = createFakePlugin(
            'plugin', packagesDir,
            platformSupport: <String, PlatformSupport>{
              kPlatformMacos: PlatformSupport.inline,
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xctest',
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

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformSupport>{
              kPlatformMacos: PlatformSupport.inline,
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
          MockProcess.failing()
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['xctest', '--macos'], errorHandler: (Error e) {
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
            platformSupport: <String, PlatformSupport>{
              kPlatformIos: PlatformSupport.inline,
              kPlatformMacos: PlatformSupport.inline,
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xctest',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAll(<Matcher>[
              contains('Successfully ran iOS xctest for plugin/example'),
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
            platformSupport: <String, PlatformSupport>{
              kPlatformMacos: PlatformSupport.inline,
            });

        final Directory pluginExampleDirectory =
            pluginDirectory1.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xctest',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Only running for macOS'),
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
            'plugin', packagesDir, platformSupport: <String, PlatformSupport>{
          kPlatformIos: PlatformSupport.inline
        });

        final Directory pluginExampleDirectory =
            pluginDirectory.childDirectory('example');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xctest',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Only running for iOS'),
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

      test('skips when neither are supported', () async {
        createFakePlugin('plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xctest',
          '--ios',
          '--macos',
          _kDestination,
          'foo_destination',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains(
                  'SKIPPING: Neither iOS nor macOS is implemented by this plugin package.'),
            ]));

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });
    });
  });
}
