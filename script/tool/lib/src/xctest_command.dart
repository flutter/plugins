// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

const String _kiOSDestination = 'ios-destination';
const String _kXcodeBuildCommand = 'xcodebuild';
const String _kXCRunCommand = 'xcrun';
const String _kFoundNoSimulatorsMessage =
    'Cannot find any available simulators, tests failed';

/// The command to run iOS XCTests in plugins, this should work for both XCUnitTest and XCUITest targets.
/// The tests target have to be added to the xcode project of the example app. Usually at "example/ios/Runner.xcworkspace".
/// The static analyzer is also run.
class XCTestCommand extends PluginCommand {
  /// Creates an instance of the test command.
  XCTestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addOption(
      _kiOSDestination,
      help:
          'Specify the destination when running the test, used for -destination flag for xcodebuild command.\n'
          'this is passed to the `-destination` argument in xcodebuild command.\n'
          'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT for details on how to specify the destination.',
    );
  }

  @override
  final String name = 'xctest';

  @override
  final String description = 'Runs the xctests in the iOS example apps.\n\n'
      'This command requires "flutter" and "xcrun" to be in your path.';

  @override
  Future<void> run() async {
    String destination = getStringArg(_kiOSDestination);
    if (destination.isEmpty) {
      final String? simulatorId = await _findAvailableIphoneSimulator();
      if (simulatorId == null) {
        print(_kFoundNoSimulatorsMessage);
        throw ToolExit(1);
      }
      destination = 'id=$simulatorId';
    }

    final List<String> failingPackages = <String>[];
    await for (final Directory plugin in getPlugins()) {
      // Start running for package.
      final String packageName =
          p.relative(plugin.path, from: packagesDir.path);
      print('Start running for $packageName ...');
      if (!isIosPlugin(plugin)) {
        print('iOS is not supported by this plugin.');
        print('\n\n');
        continue;
      }
      for (final Directory example in getExamplesForPlugin(plugin)) {
        // Running tests and static analyzer.
        print('Running tests and analyzer for $packageName ...');
        int exitCode = await _runTests(true, destination, example);
        // 66 = there is no test target (this fails fast). Try again with just the analyzer.
        if (exitCode == 66) {
          print('Tests not found for $packageName, running analyzer only...');
          exitCode = await _runTests(false, destination, example);
        }
        if (exitCode == 0) {
          print('Successfully ran xctest for $packageName');
        } else {
          failingPackages.add(packageName);
        }
      }
    }

    // Command end, print reports.
    if (failingPackages.isEmpty) {
      print('All XCTests have passed!');
    } else {
      print(
          'The following packages are failing XCTests (see above for details):');
      for (final String package in failingPackages) {
        print(' * $package');
      }
      throw ToolExit(1);
    }
  }

  Future<int> _runTests(bool runTests, String destination, Directory example) {
    final List<String> xctestArgs = <String>[
      _kXcodeBuildCommand,
      if (runTests) 'test',
      'analyze',
      '-workspace',
      'ios/Runner.xcworkspace',
      '-configuration',
      'Debug',
      '-scheme',
      'Runner',
      '-destination',
      destination,
      'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
    ];
    final String completeTestCommand =
        '$_kXCRunCommand ${xctestArgs.join(' ')}';
    print(completeTestCommand);
    return processRunner.runAndStream(_kXCRunCommand, xctestArgs,
        workingDir: example, exitOnError: false);
  }

  Future<String?> _findAvailableIphoneSimulator() async {
    // Find the first available destination if not specified.
    final List<String> findSimulatorsArguments = <String>[
      'simctl',
      'list',
      '--json'
    ];
    final String findSimulatorCompleteCommand =
        '$_kXCRunCommand ${findSimulatorsArguments.join(' ')}';
    print('Looking for available simulators...');
    print(findSimulatorCompleteCommand);
    final io.ProcessResult findSimulatorsResult =
        await processRunner.run(_kXCRunCommand, findSimulatorsArguments);
    if (findSimulatorsResult.exitCode != 0) {
      print('Error occurred while running "$findSimulatorCompleteCommand":\n'
          '${findSimulatorsResult.stderr}');
      throw ToolExit(1);
    }
    final Map<String, dynamic> simulatorListJson =
        jsonDecode(findSimulatorsResult.stdout as String)
            as Map<String, dynamic>;
    final List<Map<String, dynamic>> runtimes =
        (simulatorListJson['runtimes'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final Map<String, Object> devices =
        (simulatorListJson['devices'] as Map<String, dynamic>)
            .cast<String, Object>();
    if (runtimes.isEmpty || devices.isEmpty) {
      return null;
    }
    String? id;
    // Looking for runtimes, trying to find one with highest OS version.
    for (final Map<String, dynamic> rawRuntimeMap in runtimes.reversed) {
      final Map<String, Object> runtimeMap =
          rawRuntimeMap.cast<String, Object>();
      if ((runtimeMap['name'] as String?)?.contains('iOS') != true) {
        continue;
      }
      final String? runtimeID = runtimeMap['identifier'] as String?;
      if (runtimeID == null) {
        continue;
      }
      final List<Map<String, dynamic>>? devicesForRuntime =
          (devices[runtimeID] as List<dynamic>?)?.cast<Map<String, dynamic>>();
      if (devicesForRuntime == null || devicesForRuntime.isEmpty) {
        continue;
      }
      // Looking for runtimes, trying to find latest version of device.
      for (final Map<String, dynamic> rawDevice in devicesForRuntime.reversed) {
        final Map<String, Object> device = rawDevice.cast<String, Object>();
        if (device['availabilityError'] != null ||
            (device['isAvailable'] as bool?) == false) {
          continue;
        }
        id = device['udid'] as String?;
        if (id == null) {
          continue;
        }
        print('device selected: $device');
        return id;
      }
    }
    return null;
  }
}
