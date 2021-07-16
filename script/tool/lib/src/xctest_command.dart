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

const int _exitNoIosSimulators = 3;

/// The command to run native tests for plugins:
/// - iOS and macOS: XCTests (XCUnitTest and XCUITest) in plugins.
class NativeTestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  NativeTestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  })  : _xcode = Xcode(processRunner: processRunner, log: true),
        super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addOption(
      _iosDestinationFlag,
      help: 'Specify the destination when running iOS tests.\n'
          'This is passed to the `-destination` argument in the xcodebuild command.\n'
          'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT '
          'for details on how to specify the destination.',
    );
    argParser.addOption(
      _testTargetFlag,
      help:
          'Limits the tests to a specific target (e.g., RunnerTests or RunnerUITests)',
    );
    argParser.addFlag(kPlatformIos, help: 'Runs iOS tests');
    argParser.addFlag(kPlatformMacos, help: 'Runs macOS tests');
  }

  // The device destination flags for iOS tests.
  List<String> _iosDestinationFlags = <String>[];

  final Xcode _xcode;

  @override
  final String name = 'native-test';

  @override
  final String description = '''
Runs native unit tests and native integration tests.

Currently supported platforms:
- iOS: requires 'xcrun' to be in your path.
- macOS: requires 'xcrun' to be in your path.

The example app(s) must be built for all targeted platforms before running
this command.
''';

  Map<String, _PlatformDetails> _platforms = <String, _PlatformDetails>{};

  List<String> _requestedPlatforms = <String>[];

  @override
  Future<void> initializeRun() async {
    _platforms = <String, _PlatformDetails>{
      kPlatformIos: _PlatformDetails('iOS', _testIos),
      kPlatformMacos: _PlatformDetails('macOS', _testMacOs),
    };
    _requestedPlatforms = _platforms.keys
        .where((String platform) => getBoolArg(platform))
        .toList();
    _requestedPlatforms.sort();

    if (_requestedPlatforms.isEmpty) {
      printError('At least one platform flag must be provided.');
      throw ToolExit(exitInvalidArguments);
    }

    // iOS-specific run-level state.
    if (_requestedPlatforms.contains('ios')) {
      String destination = getStringArg(_iosDestinationFlag);
      if (destination.isEmpty) {
        final String? simulatorId =
            await _xcode.findBestAvailableIphoneSimulator();
        if (simulatorId == null) {
          printError('Cannot find any available iOS simulators.');
          throw ToolExit(_exitNoIosSimulators);
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
    final List<String> testPlatforms = <String>[];
    for (final String platform in _requestedPlatforms) {
      if (pluginSupportsPlatform(platform, package,
          requiredMode: PlatformSupport.inline)) {
        testPlatforms.add(platform);
      } else {
        print('No implementation for ${_platforms[platform]!.label}.');
      }
    }

    if (testPlatforms.isEmpty) {
      return PackageResult.skip('Not implemented for target platform(s).');
    }

    final List<String> failures = <String>[];
    bool ranTests = false;
    for (final String platform in testPlatforms) {
      final _PlatformDetails platformInfo = _platforms[platform]!;
      final RunState result = await platformInfo.testFunction(package);
      ranTests |= result != RunState.skipped;
      if (result == RunState.failed) {
        failures.add(platformInfo.label);
      }
    }

    if (!ranTests) {
      return PackageResult.skip('No tests found.');
    }
    // Only provide the failing platforms in the failure details if testing
    // multiple platforms, otherwise it's just noise.
    return failures.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(
            _requestedPlatforms.length > 1 ? failures : <String>[]);
  }

  Future<RunState> _testIos(Directory plugin) {
    return _runXcodeTests(plugin, 'iOS', extraFlags: _iosDestinationFlags);
  }

  Future<RunState> _testMacOs(Directory plugin) {
    return _runXcodeTests(plugin, 'macOS');
  }

  /// Runs all applicable tests for [plugin], printing status and returning
  /// the test result.
  ///
  /// The tests targets must be added to the Xcode project of the example app,
  /// usually at "example/{ios,macos}/Runner.xcworkspace".
  Future<RunState> _runXcodeTests(
    Directory plugin,
    String platform, {
    List<String> extraFlags = const <String>[],
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
          ...extraFlags,
          'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
        ],
      );

      // The exit code from 'xcodebuild test' when there are no tests.
      const int _xcodebuildNoTestExitCode = 66;
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

// The type for a function that takes a plugin directory and runs its native
// tests for a specific platform.
typedef _TestFunction = Future<RunState> Function(Directory);

/// A collection of information related to a specific platform.
class _PlatformDetails {
  const _PlatformDetails(
    this.label,
    this.testFunction,
  );

  /// The name to use in output.
  final String label;

  /// The function to call to run tests.
  final _TestFunction testFunction;
}
