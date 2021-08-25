// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_tools/src/common/xcode.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../util.dart';

void main() {
  late RecordingProcessRunner processRunner;
  late Xcode xcode;

  setUp(() {
    processRunner = RecordingProcessRunner();
    xcode = Xcode(processRunner: processRunner);
  });

  group('findBestAvailableIphoneSimulator', () {
    test('finds the newest device', () async {
      const String expectedDeviceId = '1E76A0FD-38AC-4537-A989-EA639D7D012A';
      // Note: This uses `dynamic` deliberately, and should not be updated to
      // Object, in order to ensure that the code correctly handles this return
      // type from JSON decoding.
      final Map<String, dynamic> devices = <String, dynamic>{
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
              'udid': expectedDeviceId,
              'isAvailable': true,
              'deviceTypeIdentifier':
                  'com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus',
              'state': 'Shutdown',
              'name': 'iPhone 8 Plus'
            }
          ]
        }
      };

      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(stdout: jsonEncode(devices)),
      ];

      expect(await xcode.findBestAvailableIphoneSimulator(), expectedDeviceId);
    });

    test('ignores non-iOS runtimes', () async {
      // Note: This uses `dynamic` deliberately, and should not be updated to
      // Object, in order to ensure that the code correctly handles this return
      // type from JSON decoding.
      final Map<String, dynamic> devices = <String, dynamic>{
        'runtimes': <Map<String, dynamic>>[
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
          'com.apple.CoreSimulator.SimRuntime.watchOS-6-2':
              <Map<String, dynamic>>[
            <String, dynamic>{
              'dataPath':
                  '/Users/xxx/Library/Developer/CoreSimulator/Devices/1E76A0FD-38AC-4537-A989-EA639D7D012A/data',
              'logPath':
                  '/Users/xxx/Library/Logs/CoreSimulator/1E76A0FD-38AC-4537-A989-EA639D7D012A',
              'udid': '1E76A0FD-38AC-4537-A989-EA639D7D012A',
              'isAvailable': true,
              'deviceTypeIdentifier':
                  'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-38mm',
              'state': 'Shutdown',
              'name': 'Apple Watch'
            }
          ]
        }
      };

      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(stdout: jsonEncode(devices)),
      ];

      expect(await xcode.findBestAvailableIphoneSimulator(), null);
    });

    test('returns null if simctl fails', () async {
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      expect(await xcode.findBestAvailableIphoneSimulator(), null);
    });
  });

  group('runXcodeBuild', () {
    test('handles minimal arguments', () async {
      final Directory directory = const LocalFileSystem().currentDirectory;

      final int exitCode = await xcode.runXcodeBuild(
        directory,
        workspace: 'A.xcworkspace',
        scheme: 'AScheme',
      );

      expect(exitCode, 0);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'xcrun',
                const <String>[
                  'xcodebuild',
                  'build',
                  '-workspace',
                  'A.xcworkspace',
                  '-scheme',
                  'AScheme',
                ],
                directory.path),
          ]));
    });

    test('handles all arguments', () async {
      final Directory directory = const LocalFileSystem().currentDirectory;

      final int exitCode = await xcode.runXcodeBuild(directory,
          actions: <String>['action1', 'action2'],
          workspace: 'A.xcworkspace',
          scheme: 'AScheme',
          configuration: 'Debug',
          extraFlags: <String>['-a', '-b', 'c=d']);

      expect(exitCode, 0);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'xcrun',
                const <String>[
                  'xcodebuild',
                  'action1',
                  'action2',
                  '-workspace',
                  'A.xcworkspace',
                  '-scheme',
                  'AScheme',
                  '-configuration',
                  'Debug',
                  '-a',
                  '-b',
                  'c=d',
                ],
                directory.path),
          ]));
    });

    test('returns error codes', () async {
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];
      final Directory directory = const LocalFileSystem().currentDirectory;

      final int exitCode = await xcode.runXcodeBuild(
        directory,
        workspace: 'A.xcworkspace',
        scheme: 'AScheme',
      );

      expect(exitCode, 1);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'xcrun',
                const <String>[
                  'xcodebuild',
                  'build',
                  '-workspace',
                  'A.xcworkspace',
                  '-scheme',
                  'AScheme',
                ],
                directory.path),
          ]));
    });
  });

  group('projectHasTarget', () {
    test('returns true when present', () async {
      const String stdout = '''
{
  "project" : {
    "configurations" : [
      "Debug",
      "Release"
    ],
    "name" : "Runner",
    "schemes" : [
      "Runner"
    ],
    "targets" : [
      "Runner",
      "RunnerTests",
      "RunnerUITests"
    ]
  }
}''';
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(stdout: stdout),
      ];

      final Directory project =
          const LocalFileSystem().directory('/foo.xcodeproj');
      expect(await xcode.projectHasTarget(project, 'RunnerTests'), true);
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
                  project.path,
                ],
                null),
          ]));
    });

    test('returns false when not present', () async {
      const String stdout = '''
{
  "project" : {
    "configurations" : [
      "Debug",
      "Release"
    ],
    "name" : "Runner",
    "schemes" : [
      "Runner"
    ],
    "targets" : [
      "Runner",
      "RunnerUITests"
    ]
  }
}''';
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(stdout: stdout),
      ];

      final Directory project =
          const LocalFileSystem().directory('/foo.xcodeproj');
      expect(await xcode.projectHasTarget(project, 'RunnerTests'), false);
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
                  project.path,
                ],
                null),
          ]));
    });

    test('returns null for unexpected output', () async {
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(stdout: '{}'),
      ];

      final Directory project =
          const LocalFileSystem().directory('/foo.xcodeproj');
      expect(await xcode.projectHasTarget(project, 'RunnerTests'), null);
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
                  project.path,
                ],
                null),
          ]));
    });

    test('returns null for invalid output', () async {
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(stdout: ':)'),
      ];

      final Directory project =
          const LocalFileSystem().directory('/foo.xcodeproj');
      expect(await xcode.projectHasTarget(project, 'RunnerTests'), null);
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
                  project.path,
                ],
                null),
          ]));
    });

    test('returns null for failure', () async {
      processRunner.mockProcessesForExecutable['xcrun'] = <io.Process>[
        MockProcess(exitCode: 1), // xcodebuild -list
      ];

      final Directory project =
          const LocalFileSystem().directory('/foo.xcodeproj');
      expect(await xcode.projectHasTarget(project, 'RunnerTests'), null);
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
                  project.path,
                ],
                null),
          ]));
    });
  });
}
