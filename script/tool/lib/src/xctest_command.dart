// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

const String _kiOSDestination = 'ios-destination';
const String _kTarget = 'target';
const String _kSkip = 'skip';
const String _kXcodeBuildCommand = 'xcodebuild';
const String _kXCRunCommand = 'xcrun';
const String _kFoundNoSimulatorsMessage =
    'Cannot find any available simulators, tests failed';

/// The command to run iOS' XCTests in plugins, this should work for both XCUnitTest and XCUITest targets.
/// The tests target have to be added to the xcode project of the example app. Usually at "example/ios/Runner.xcodeproj".
/// The command takes a "-target" argument which has to match the target of the test target.
/// For information on how to add test target in an xcode project, see https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTesting.html
class XCTestCommand extends PluginCommand {
  XCTestCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addOption(
      _kiOSDestination,
      help:
          'Specify the destination when running the test, used for -destination flag for xcodebuild command.\n'
          'this is passed to the `-destination` argument in xcodebuild command.\n'
          'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT for details on how to specify the destination.',
    );
    argParser.addOption(_kTarget,
        help: 'The test target.\n'
            'This is the xcode project test target. This is passed to the `-scheme` argument in the xcodebuild command. \n'
            'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT for details on how to specify the scheme');
    argParser.addMultiOption(_kSkip,
        help: 'Plugins to skip while running this command. \n');
  }

  @override
  final String name = 'xctest';

  @override
  final String description = 'Runs the xctests in the iOS example apps.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  Future<Null> run() async {
    if (argResults[_kTarget] == null) {
      // TODO(cyanglaz): Automatically find all the available testing schemes if this argument is not specified.
      // https://github.com/flutter/flutter/issues/68419
      print('--$_kTarget must be specified');
      throw ToolExit(1);
    }

    String destination = argResults[_kiOSDestination];
    if (destination == null) {
      String simulatorId = await _findAvailableIphoneSimulator();
      if (simulatorId == null) {
        print(_kFoundNoSimulatorsMessage);
        throw ToolExit(1);
      }
      destination = 'id=$simulatorId';
    }

    checkSharding();

    final String target = argResults[_kTarget];
    final List<String> skipped = argResults[_kSkip];

    List<String> failingPackages = <String>[];
    await for (Directory plugin in getPlugins()) {
      // Start running for package.
      final String packageName =
          p.relative(plugin.path, from: packagesDir.path);
      print('Start running for $packageName ...');
      if (!isIosPlugin(plugin, fileSystem)) {
        print('iOS is not supported by this plugin.');
        print('\n\n');
        continue;
      }
      if (skipped.contains(packageName)) {
        print('$packageName was skipped with the --skip flag.');
        print('\n\n');
        continue;
      }
      for (Directory example in getExamplesForPlugin(plugin)) {
        // Look for the test scheme in the example app.
        print('Look for target named: $_kTarget ...');
        final List<String> findSchemeArgs = <String>[
          '-project',
          'ios/Runner.xcodeproj',
          '-list',
          '-json'
        ];
        final String completeFindSchemeCommand =
            '$_kXcodeBuildCommand ${findSchemeArgs.join(' ')}';
        print(completeFindSchemeCommand);
        final io.ProcessResult xcodeprojListResult = await processRunner
            .run(_kXcodeBuildCommand, findSchemeArgs, workingDir: example);
        if (xcodeprojListResult.exitCode != 0) {
          print('Error occurred while running "$completeFindSchemeCommand":\n'
              '${xcodeprojListResult.stderr}');
          failingPackages.add(packageName);
          print('\n\n');
          continue;
        }

        final String xcodeprojListOutput = xcodeprojListResult.stdout;
        Map<String, dynamic> xcodeprojListOutputJson =
            jsonDecode(xcodeprojListOutput);
        if (!xcodeprojListOutputJson['project']['targets'].contains(target)) {
          failingPackages.add(packageName);
          print('$target not configured for $packageName, test failed.');
          print(
              'Please check the scheme for the test target if it matches the name $target.\n'
              'If this plugin does not have an XCTest target, use the $_kSkip flag in the $name command to skip the plugin.');
          print('\n\n');
          continue;
        }
        // Found the scheme, running tests
        print('Running XCTests:$target for $packageName ...');
        final List<String> xctestArgs = <String>[
          'test',
          '-workspace',
          'ios/Runner.xcworkspace',
          '-scheme',
          target,
          '-destination',
          destination,
          'CODE_SIGN_IDENTITY=""',
          'CODE_SIGNING_REQUIRED=NO'
        ];
        final String completeTestCommand =
            '$_kXcodeBuildCommand ${xctestArgs.join(' ')}';
        print(completeTestCommand);
        final int exitCode = await processRunner
            .runAndStream(_kXcodeBuildCommand, xctestArgs, workingDir: example);
        if (exitCode == 0) {
          print('Successfully ran xctest for $packageName');
        } else {
          failingPackages.add(packageName);
        }
      }
    }

    // Command end, print reports.
    if (failingPackages.isEmpty) {
      print("All XCTests have passed!");
    } else {
      print(
          'The following packages are failing XCTests (see above for details):');
      for (String package in failingPackages) {
        print(' * $package');
      }
      throw ToolExit(1);
    }
  }

  Future<String> _findAvailableIphoneSimulator() async {
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
        jsonDecode(findSimulatorsResult.stdout);
    final List<dynamic> runtimes = simulatorListJson['runtimes'];
    final Map<String, dynamic> devices = simulatorListJson['devices'];
    if (runtimes.isEmpty || devices.isEmpty) {
      return null;
    }
    String id;
    // Looking for runtimes, trying to find one with highest OS version.
    for (Map<String, dynamic> runtimeMap in runtimes.reversed) {
      if (!runtimeMap['name'].contains('iOS')) {
        continue;
      }
      final String runtimeID = runtimeMap['identifier'];
      final List<dynamic> devicesForRuntime = devices[runtimeID];
      if (devicesForRuntime.isEmpty) {
        continue;
      }
      // Looking for runtimes, trying to find latest version of device.
      for (Map<String, dynamic> device in devicesForRuntime.reversed) {
        if (device['availabilityError'] != null ||
            (device['isAvailable'] as bool == false)) {
          continue;
        }
        id = device['udid'];
        print('device selected: $device');
        return id;
      }
    }
    return null;
  }
}
