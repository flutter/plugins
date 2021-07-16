// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';
import 'common/xcode.dart';

const String _iosDestinationFlag = 'ios-destination';
const String _testTargetFlag = 'test-target';

// The exit code from 'xcodebuild test' when there are no tests.
const int _xcodebuildNoTestExitCode = 66;

const int _exitNoSimulators = 3;

/// The command to run XCTests (XCUnitTest and XCUITest) in plugins.
/// The tests target have to be added to the Xcode project of the example app,
/// usually at "example/{ios,macos}/Runner.xcworkspace".
class XCTestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  XCTestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  })  : _xcode = Xcode(processRunner: processRunner, log: true),
        super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addOption(
      _iosDestinationFlag,
      help:
          'Specify the destination when running the test, used for -destination flag for xcodebuild command.\n'
          'this is passed to the `-destination` argument in xcodebuild command.\n'
          'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT for details on how to specify the destination.',
    );
    argParser.addOption(
      _testTargetFlag,
      help:
          'Limits the tests to a specific target (e.g., RunnerTests or RunnerUITests)',
    );
    argParser.addFlag(kPlatformIos, help: 'Runs the iOS tests');
    argParser.addFlag(kPlatformMacos, help: 'Runs the macOS tests');
  }

  // The device destination flags for iOS tests.
  List<String> _iosDestinationFlags = <String>[];

  final Xcode _xcode;

  @override
  final String name = 'xctest';

  @override
  final String description =
      'Runs the xctests in the iOS and/or macOS example apps.\n\n'
      'This command requires "flutter" and "xcrun" to be in your path.';

  @override
  Future<void> initializeRun() async {
    final bool shouldTestIos = getBoolArg(kPlatformIos);
    final bool shouldTestMacos = getBoolArg(kPlatformMacos);

    if (!(shouldTestIos || shouldTestMacos)) {
      printError('At least one platform flag must be provided.');
      throw ToolExit(exitInvalidArguments);
    }

    if (shouldTestIos) {
      String destination = getStringArg(_iosDestinationFlag);
      if (destination.isEmpty) {
        final String? simulatorId =
            await _xcode.findBestAvailableIphoneSimulator();
        if (simulatorId == null) {
          printError('Cannot find any available simulators, tests failed');
          throw ToolExit(_exitNoSimulators);
        }
        destination = 'id=$simulatorId';
      }
      _iosDestinationFlags = <String>[
        '-destination',
        destination,
      ];
    }
  }

  @override
  Future<PackageResult> runForPackage(Directory package) async {
    final bool testIos = getBoolArg(kPlatformIos) &&
        pluginSupportsPlatform(kPlatformIos, package,
            requiredMode: PlatformSupport.inline);
    final bool testMacos = getBoolArg(kPlatformMacos) &&
        pluginSupportsPlatform(kPlatformMacos, package,
            requiredMode: PlatformSupport.inline);

    final bool multiplePlatformsRequested =
        getBoolArg(kPlatformIos) && getBoolArg(kPlatformMacos);
    if (!(testIos || testMacos)) {
      String description;
      if (multiplePlatformsRequested) {
        description = 'Neither iOS nor macOS is';
      } else if (getBoolArg(kPlatformIos)) {
        description = 'iOS is not';
      } else {
        description = 'macOS is not';
      }
      return PackageResult.skip(
          '$description implemented by this plugin package.');
    }

    if (multiplePlatformsRequested && (!testIos || !testMacos)) {
      print('Only running for ${testIos ? 'iOS' : 'macOS'}\n');
    }

    final List<String> failures = <String>[];
    bool ranTests = false;
    if (testIos) {
      final RunState result = await _testPlugin(package, 'iOS',
          extraXcrunFlags: _iosDestinationFlags);
      ranTests |= result != RunState.skipped;
      if (result == RunState.failed) {
        failures.add('iOS');
      }
    }
    if (testMacos) {
      final RunState result = await _testPlugin(package, 'macOS');
      ranTests |= result != RunState.skipped;
      if (result == RunState.failed) {
        failures.add('macOS');
      }
    }

    if (!ranTests) {
      return PackageResult.skip('No tests found.');
    }
    // Only provide the failing platform in the failure details if testing
    // multiple platforms, otherwise it's just noise.
    return failures.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(
            multiplePlatformsRequested ? failures : <String>[]);
  }

  /// Runs all applicable tests for [plugin], printing status and returning
  /// the test result.
  Future<RunState> _testPlugin(
    Directory plugin,
    String platform, {
    List<String> extraXcrunFlags = const <String>[],
  }) async {
    final String testTarget = getStringArg(_testTargetFlag);

    // Assume skipped until at least one test has run.
    RunState overallResult = RunState.skipped;
    for (final Directory example in getExamplesForPlugin(plugin)) {
      final String examplePath =
          getRelativePosixPath(example, from: plugin.parent);

      if (testTarget.isNotEmpty) {
        final Directory project = example
            .childDirectory(platform.toLowerCase())
            .childDirectory('Runner.xcodeproj');
        final bool? hasTarget =
            await _xcode.projectHasTarget(project, testTarget);
        if (hasTarget == null) {
          printError('Unable to check targets for $examplePath.');
          overallResult = RunState.failed;
          continue;
        } else if (!hasTarget) {
          print('No "$testTarget" target in $examplePath; skipping.');
          continue;
        }
      }

      print('Running $platform tests for $examplePath...');
      final int exitCode = await _xcode.runXcodeBuild(
        example,
        actions: <String>['test'],
        workspace: '${platform.toLowerCase()}/Runner.xcworkspace',
        scheme: 'Runner',
        configuration: 'Debug',
        extraFlags: <String>[
          if (testTarget.isNotEmpty) '-only-testing:$testTarget',
          ...extraXcrunFlags,
          'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
        ],
      );

      switch (exitCode) {
        case _xcodebuildNoTestExitCode:
          print('No tests found for $examplePath');
          continue;
        case 0:
          printSuccess('Successfully ran $platform xctest for $examplePath');
          // If this is the first test, assume success until something fails.
          if (overallResult == RunState.skipped) {
            overallResult = RunState.succeeded;
          }
          break;
        default:
          // Any failure means a failure overall.
          overallResult = RunState.failed;
          break;
      }
    }
    return overallResult;
  }
}
