// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

const int _exitNoPlatformFlags = 2;
const int _exitNoAvailableDevice = 3;

/// A command to run the example applications for packages via Flutter driver.
class DriveExamplesCommand extends PluginCommand {
  /// Creates an instance of the drive command.
  DriveExamplesCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addFlag(kPlatformAndroid,
        help: 'Runs the Android implementation of the examples');
    argParser.addFlag(kPlatformIos,
        help: 'Runs the iOS implementation of the examples');
    argParser.addFlag(kPlatformLinux,
        help: 'Runs the Linux implementation of the examples');
    argParser.addFlag(kPlatformMacos,
        help: 'Runs the macOS implementation of the examples');
    argParser.addFlag(kPlatformWeb,
        help: 'Runs the web implementation of the examples');
    argParser.addFlag(kPlatformWindows,
        help: 'Runs the Windows implementation of the examples');
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help:
          'Runs the driver tests in Dart VM with the given experiments enabled.',
    );
  }

  @override
  final String name = 'drive-examples';

  @override
  final String description = 'Runs driver tests for plugin example apps.\n\n'
      'For each *_test.dart in test_driver/ it drives an application with a '
      'corresponding name in the test/ or test_driver/ directories.\n\n'
      'For example, test_driver/app_test.dart would match test/app.dart.\n\n'
      'This command requires "flutter" to be in your path.\n\n'
      'If a file with a corresponding name cannot be found, this driver file'
      'will be used to drive the tests that match '
      'integration_test/*_test.dart.';

  @override
  Future<void> run() async {
    final List<String> platformSwitches = <String>[
      kPlatformAndroid,
      kPlatformIos,
      kPlatformLinux,
      kPlatformMacos,
      kPlatformWeb,
      kPlatformWindows,
    ];
    final int platformCount = platformSwitches
        .where((String platform) => getBoolArg(platform))
        .length;
    // The flutter tool currently doesn't accept multiple device arguments:
    // https://github.com/flutter/flutter/issues/35733
    // If that is implemented, this check can be relaxed.
    if (platformCount != 1) {
      printError(
          'Exactly one of ${platformSwitches.map((String platform) => '--$platform').join(', ')} '
          'must be specified.');
      throw ToolExit(_exitNoPlatformFlags);
    }

    String? androidDevice;
    if (getBoolArg(kPlatformAndroid)) {
      final List<String> devices = await _getDevicesForPlatform('android');
      if (devices.isEmpty) {
        printError('No Android devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      androidDevice = devices.first;
    }

    String? iosDevice;
    if (getBoolArg(kPlatformIos)) {
      final List<String> devices = await _getDevicesForPlatform('ios');
      if (devices.isEmpty) {
        printError('No iOS devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      iosDevice = devices.first;
    }

    final Map<String, List<String>> targetDeviceFlags = <String, List<String>>{
      if (getBoolArg(kPlatformAndroid))
        kPlatformAndroid: <String>['-d', androidDevice!],
      if (getBoolArg(kPlatformIos)) kPlatformIos: <String>['-d', iosDevice!],
      if (getBoolArg(kPlatformLinux)) kPlatformLinux: <String>['-d', 'linux'],
      if (getBoolArg(kPlatformMacos)) kPlatformMacos: <String>['-d', 'macos'],
      if (getBoolArg(kPlatformWeb))
        kPlatformWeb: <String>[
          '-d',
          'web-server',
          '--web-port=7357',
          '--browser-name=chrome'
        ],
      if (getBoolArg(kPlatformWindows))
        kPlatformWindows: <String>['-d', 'windows'],
    };

    final List<String> failingTests = <String>[];
    final List<String> pluginsWithoutTests = <String>[];
    await for (final Directory plugin in getPlugins()) {
      final String pluginName = plugin.basename;
      if (pluginName.endsWith('_platform_interface') &&
          !plugin.childDirectory('example').existsSync()) {
        // Platform interface packages generally aren't intended to have
        // examples, and don't need integration tests, so silently skip them
        // unless for some reason there is an example directory.
        continue;
      }
      print('\n==========\nChecking $pluginName...');

      final List<String> deviceFlags = <String>[];
      for (final MapEntry<String, List<String>> entry
          in targetDeviceFlags.entries) {
        if (pluginSupportsPlatform(entry.key, plugin)) {
          deviceFlags.addAll(entry.value);
        } else {
          // TODO(stuartmorgan): Consider making this an error, not a skip.
          print('$pluginName does not support ${entry.key}.');
        }
      }
      // If there is no supported target platform, skip the plugin.
      if (deviceFlags.isEmpty) {
        continue;
      }

      int examplesFound = 0;
      bool testsRan = false;
      final String flutterCommand =
          const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';
      for (final Directory example in getExamplesForPlugin(plugin)) {
        ++examplesFound;
        final String packageName =
            p.relative(example.path, from: packagesDir.path);
        final Directory driverTests = example.childDirectory('test_driver');
        if (!driverTests.existsSync()) {
          print('No driver tests found for $packageName');
          continue;
        }
        // Look for driver tests ending in _test.dart in test_driver/
        await for (final FileSystemEntity test in driverTests.list()) {
          final String driverTestName =
              p.relative(test.path, from: driverTests.path);
          if (!driverTestName.endsWith('_test.dart')) {
            continue;
          }
          // Try to find a matching app to drive without the _test.dart
          final String deviceTestName = driverTestName.replaceAll(
            RegExp(r'_test.dart$'),
            '.dart',
          );
          String deviceTestPath = p.join('test', deviceTestName);
          if (!example.fileSystem
              .file(p.join(example.path, deviceTestPath))
              .existsSync()) {
            // If the app isn't in test/ folder, look in test_driver/ instead.
            deviceTestPath = p.join('test_driver', deviceTestName);
          }

          final List<String> targetPaths = <String>[];
          if (example.fileSystem
              .file(p.join(example.path, deviceTestPath))
              .existsSync()) {
            targetPaths.add(deviceTestPath);
          } else {
            final Directory integrationTests =
                example.childDirectory('integration_test');

            if (await integrationTests.exists()) {
              await for (final FileSystemEntity integrationTest
                  in integrationTests.list()) {
                if (!integrationTest.basename.endsWith('_test.dart')) {
                  continue;
                }
                targetPaths
                    .add(p.relative(integrationTest.path, from: example.path));
              }
            }

            if (targetPaths.isEmpty) {
              print('''
Unable to infer a target application for $driverTestName to drive.
Tried searching for the following:
1. test/$deviceTestName
2. test_driver/$deviceTestName
3. test_driver/*_test.dart
''');
              failingTests.add(p.relative(test.path, from: example.path));
              continue;
            }
          }

          final List<String> driveArgs = <String>['drive', ...deviceFlags];

          final String enableExperiment = getStringArg(kEnableExperiment);
          if (enableExperiment.isNotEmpty) {
            driveArgs.add('--enable-experiment=$enableExperiment');
          }

          for (final String targetPath in targetPaths) {
            testsRan = true;
            final int exitCode = await processRunner.runAndStream(
                flutterCommand,
                <String>[
                  ...driveArgs,
                  '--driver',
                  p.join('test_driver', driverTestName),
                  '--target',
                  targetPath,
                ],
                workingDir: example,
                exitOnError: true);
            if (exitCode != 0) {
              failingTests.add(p.join(packageName, deviceTestPath));
            }
          }
        }
      }
      if (!testsRan) {
        pluginsWithoutTests.add(pluginName);
        print(
            'No driver tests run for $pluginName ($examplesFound examples found)');
      }
    }
    print('\n\n');

    if (failingTests.isNotEmpty) {
      print('The following driver tests are failing (see above for details):');
      for (final String test in failingTests) {
        print(' * $test');
      }
      throw ToolExit(1);
    }

    if (pluginsWithoutTests.isNotEmpty) {
      print('The following plugins did not run any integration tests:');
      for (final String plugin in pluginsWithoutTests) {
        print(' * $plugin');
      }
      print('If this is intentional, they must be explicitly excluded.');
      throw ToolExit(1);
    }

    print('All driver tests successful!');
  }

  Future<List<String>> _getDevicesForPlatform(String platform) async {
    final List<String> deviceIds = <String>[];
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    final ProcessResult result = await processRunner.run(
        flutterCommand, <String>['devices', '--machine'],
        stdoutEncoding: utf8, exitOnError: true);
    if (result.exitCode != 0) {
      return deviceIds;
    }

    final List<Map<String, dynamic>> devices =
        (jsonDecode(result.stdout as String) as List<dynamic>)
            .cast<Map<String, dynamic>>();
    for (final Map<String, dynamic> deviceInfo in devices) {
      final String targetPlatform =
          (deviceInfo['targetPlatform'] as String?) ?? '';
      if (targetPlatform.startsWith(platform)) {
        final String? deviceId = deviceInfo['id'] as String?;
        if (deviceId != null) {
          deviceIds.add(deviceId);
        }
      }
    }
    return deviceIds;
  }
}
