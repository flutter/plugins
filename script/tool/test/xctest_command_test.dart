// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/xctest_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

final Map<String, dynamic> _kDeviceListMap = <String, dynamic>{
  'runtimes': <Map<String, dynamic>>[
    <String, dynamic>{
      'bundlePath':
          '/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 13.0.simruntime',
      'buildversion': '17A577',
      'runtimeRoot':
          '/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 13.0.simruntime/Contents/Resources/RuntimeRoot',
      'identifier': 'com.apple.CoreSimulator.SimRuntime.iOS-13-0',
      'version': '13.0',
      'isAvailable': true,
      'name': 'iOS 13.0'
    },
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
    <String, dynamic>{
      'bundlePath':
          '/Applications/Xcode_11_7.app/Contents/Developer/Platforms/WatchOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/watchOS.simruntime',
      'buildversion': '17T531',
      'runtimeRoot':
          '/Applications/Xcode_11_7.app/Contents/Developer/Platforms/WatchOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/watchOS.simruntime/Contents/Resources/RuntimeRoot',
      'identifier': 'com.apple.CoreSimulator.SimRuntime.watchOS-6-2',
      'version': '6.2.1',
      'isAvailable': true,
      'name': 'watchOS 6.2'
    }
  ],
  'devices': <String, dynamic>{
    'com.apple.CoreSimulator.SimRuntime.iOS-13-4': <Map<String, dynamic>>[
      <String, dynamic>{
        'dataPath':
            '/Users/xxx/Library/Developer/CoreSimulator/Devices/2706BBEB-1E01-403E-A8E9-70E8E5A24774/data',
        'logPath':
            '/Users/xxx/Library/Logs/CoreSimulator/2706BBEB-1E01-403E-A8E9-70E8E5A24774',
        'udid': '2706BBEB-1E01-403E-A8E9-70E8E5A24774',
        'isAvailable': true,
        'deviceTypeIdentifier':
            'com.apple.CoreSimulator.SimDeviceType.iPhone-8',
        'state': 'Shutdown',
        'name': 'iPhone 8'
      },
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

void main() {
  const String _kDestination = '--ios-destination';
  const String _kSkip = '--skip';

  group('test xctest_command', () {
    FileSystem fileSystem;
    Directory packagesDir;
    CommandRunner<void> runner;
    RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final XCTestCommand command =
          XCTestCommand(packagesDir, processRunner: processRunner);

      runner = CommandRunner<void>('xctest_command', 'Test for xctest_command');
      runner.addCommand(command);
    });

    test('skip if ios is not supported', () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isIosPlugin: false);

      createFakePubspec(pluginDirectory.childDirectory('example'),
          isFlutter: true);

      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockProcess;
      final List<String> output = await runCapturingPrint(
          runner, <String>['xctest', _kDestination, 'foo_destination']);
      expect(output, contains('iOS is not supported by this plugin.'));
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('running with correct destination, skip 1 plugin', () async {
      final Directory pluginDirectory1 =
          createFakePlugin('plugin1', packagesDir,
              withExtraFiles: <List<String>>[
                <String>['example', 'test'],
              ],
              isIosPlugin: true);
      final Directory pluginDirectory2 =
          createFakePlugin('plugin2', packagesDir,
              withExtraFiles: <List<String>>[
                <String>['example', 'test'],
              ],
              isIosPlugin: true);

      final Directory pluginExampleDirectory1 =
          pluginDirectory1.childDirectory('example');
      createFakePubspec(pluginExampleDirectory1, isFlutter: true);
      final Directory pluginExampleDirectory2 =
          pluginDirectory2.childDirectory('example');
      createFakePubspec(pluginExampleDirectory2, isFlutter: true);

      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockProcess;
      processRunner.resultStdout =
          '{"project":{"targets":["bar_scheme", "foo_scheme"]}}';
      final List<String> output = await runCapturingPrint(runner, <String>[
        'xctest',
        _kDestination,
        'foo_destination',
        _kSkip,
        'plugin1'
      ]);

      expect(output, contains('plugin1 was skipped with the --skip flag.'));
      expect(output, contains('Successfully ran xctest for plugin2'));

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'xcrun',
                const <String>[
                  'xcodebuild',
                  'test',
                  'analyze',
                  '-workspace',
                  'ios/Runner.xcworkspace',
                  '-configuration',
                  'Debug',
                  '-scheme',
                  'Runner',
                  '-destination',
                  'foo_destination',
                  'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                ],
                pluginExampleDirectory2.path),
          ]));
    });

    test('Not specifying --ios-destination assigns an available simulator',
        () async {
      final Directory pluginDirectory = createFakePlugin('plugin', packagesDir,
          withExtraFiles: <List<String>>[
            <String>['example', 'test'],
          ],
          isIosPlugin: true);

      final Directory pluginExampleDirectory =
          pluginDirectory.childDirectory('example');

      createFakePubspec(pluginExampleDirectory, isFlutter: true);

      final MockProcess mockProcess = MockProcess();
      mockProcess.exitCodeCompleter.complete(0);
      processRunner.processToReturn = mockProcess;
      final Map<String, dynamic> schemeCommandResult = <String, dynamic>{
        'project': <String, dynamic>{
          'targets': <String>['bar_scheme', 'foo_scheme']
        }
      };
      // For simplicity of the test, we combine all the mock results into a single mock result, each internal command
      // will get this result and they should still be able to parse them correctly.
      processRunner.resultStdout =
          jsonEncode(schemeCommandResult..addAll(_kDeviceListMap));
      await runner.run(<String>[
        'xctest',
      ]);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            const ProcessCall(
                'xcrun', <String>['simctl', 'list', '--json'], null),
            ProcessCall(
                'xcrun',
                const <String>[
                  'xcodebuild',
                  'test',
                  'analyze',
                  '-workspace',
                  'ios/Runner.xcworkspace',
                  '-configuration',
                  'Debug',
                  '-scheme',
                  'Runner',
                  '-destination',
                  'id=1E76A0FD-38AC-4537-A989-EA639D7D012A',
                  'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                ],
                pluginExampleDirectory.path),
          ]));
    });
  });
}
