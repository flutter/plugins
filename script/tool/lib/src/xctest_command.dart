// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

const String _kiOSDestination = 'ios-destination';
const String _kSkip = 'skip';
const String _kXclogparserOutput = 'xclogparser';
const String _kXcodeBuildCommand = 'xcodebuild';
const String _kXCRunCommand = 'xcrun';
const String _kFoundNoSimulatorsMessage =
    'Cannot find any available simulators, tests failed';
const int _noTestSchemeExit = 66;

/// The command to run iOS XCTests in plugins, this should work for both XCUnitTest and XCUITest targets.
/// The tests target have to be added to the xcode project of the example app. Usually at "example/ios/Runner.xcworkspace".
/// The static analyzer is also run.
class XCTestCommand extends PluginCommand {
  /// Creates an instance of the test command.
  XCTestCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addOption(
      _kiOSDestination,
      help: 'Specify the destination when running the test, used for -destination flag for xcodebuild command.\n'
          'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT for details on how to specify the destination.',
    );
    argParser.addOption(_kXclogparserOutput,
        help: 'Specify where XCLogParser, if installed, should output parsed "xcodebuild" build results.\n'
            'See https://cirrus-ci.org/examples/#xclogparser for details.');
    argParser.addMultiOption(_kSkip,
        help: 'Plugins to skip while running this command. \n');
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
      final String simulatorId = await _findAvailableIphoneSimulator();
      if (simulatorId == null) {
        print(_kFoundNoSimulatorsMessage);
        throw ToolExit(1);
      }
      destination = 'id=$simulatorId';
    }

    final List<String> skipped = getStringListArg(_kSkip);

    final List<String> failingPackages = <String>[];
    await for (final Directory plugin in getPlugins()) {
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
      for (final Directory example in getExamplesForPlugin(plugin)) {
        // Running tests and static analyzer.
        print('Running tests and analyzer for $packageName ...');
        int exitCode = await _runTests(true, destination, example, packageName);
        // 66 = there is no test target (this fails fast). Try again with just the analyzer.
        if (exitCode == _noTestSchemeExit) {
          print('Tests not found for $packageName, running analyzer only...');
          exitCode = await _runTests(false, destination, example, packageName);
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

  Future<int> _runTests(bool runTests, String destination, Directory example, String packageName) async {
    // Remove non-word characters from the directory name.
    final String packageDirectoryName = packageName.replaceAll(RegExp(r'[^\w]+'), '');
    final String derivedData =
        fileSystem.systemTempDirectory.createTempSync('dd$packageDirectoryName-').path;
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
      if (derivedData != null) ...<String>['-derivedDataPath', derivedData],
      'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
    ];
    final String completeTestCommand =
        '$_kXCRunCommand ${xctestArgs.join(' ')}';
    print(completeTestCommand);
    final int testResult = await processRunner.runAndStream(
      _kXCRunCommand,
      xctestArgs,
      workingDir: example,
      exitOnError: false,
      // Make sure I/O is flushed before finishing the xcodebuild command.
      environment: <String, String>{'NSUnbufferedIO': 'YES'},
    );
    if (testResult == _noTestSchemeExit) {
      // Don't try to xclogparser parse bad output.
      return testResult;
    }

    final String xclogparserOutput = getStringArg(_kXclogparserOutput);
    if (xclogparserOutput == null || xclogparserOutput.isEmpty) {
      print('--$_kXclogparserOutput not passed, skipping xclogparser');
    } else if (processRunner.canRun('xclogparser')) {
      fileSystem.directory(xclogparserOutput).createSync(recursive: true);
      final String parsedOutput = p.join(xclogparserOutput, '$packageDirectoryName.json');
      final io.ProcessResult xclogparserResult = await processRunner.run(
        'xclogparser',
        <String>[
          'parse',
          '--workspace',
          'ios/Runner.xcworkspace',
          '--reporter',
          'flatJson',
          '--output',
          parsedOutput,
          '--derived_data',
          derivedData,
        ],
        workingDir: example,
        logOnError: true,
        exitOnError: false,
      );
      if (xclogparserResult.exitCode == 0) {
        print('xclogparser parsed output to $parsedOutput');
      }
    } else {
      print('xclogparser not installed, skipping. Run "brew install xclogparser"');
    }
    return testResult;
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
        jsonDecode(findSimulatorsResult.stdout as String)
            as Map<String, dynamic>;
    final List<Map<String, dynamic>> runtimes =
        (simulatorListJson['runtimes'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final Map<String, dynamic> devices =
        simulatorListJson['devices'] as Map<String, dynamic>;
    if (runtimes.isEmpty || devices.isEmpty) {
      return null;
    }
    String id;
    // Looking for runtimes, trying to find one with highest OS version.
    for (final Map<String, dynamic> runtimeMap in runtimes.reversed) {
      if (!(runtimeMap['name'] as String).contains('iOS')) {
        continue;
      }
      final String runtimeID = runtimeMap['identifier'] as String;
      final List<Map<String, dynamic>> devicesForRuntime =
          (devices[runtimeID] as List<dynamic>).cast<Map<String, dynamic>>();
      if (devicesForRuntime.isEmpty) {
        continue;
      }
      // Looking for runtimes, trying to find latest version of device.
      for (final Map<String, dynamic> device in devicesForRuntime.reversed) {
        if (device['availabilityError'] != null ||
            (device['isAvailable'] as bool == false)) {
          continue;
        }
        id = device['udid'] as String;
        print('device selected: $device');
        return id;
      }
    }
    return null;
  }
}
