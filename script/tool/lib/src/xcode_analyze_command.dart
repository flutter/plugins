// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';
import 'common/xcode.dart';

/// The command to run Xcode's static analyzer on plugins.
class XcodeAnalyzeCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  XcodeAnalyzeCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  })  : _xcode = Xcode(processRunner: processRunner, log: true),
        super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addFlag(platformIOS, help: 'Analyze iOS');
    argParser.addFlag(platformMacOS, help: 'Analyze macOS');
    argParser.addOption(_minIOSVersionArg,
        help: 'Sets the minimum iOS deployment version to use when compiling, '
            'overriding the default minimum version. This can be used to find '
            'deprecation warnings that will affect the plugin in the future.');
    argParser.addOption(_minMacOSVersionArg,
        help:
            'Sets the minimum macOS deployment version to use when compiling, '
            'overriding the default minimum version. This can be used to find '
            'deprecation warnings that will affect the plugin in the future.');
  }

  static const String _minIOSVersionArg = 'ios-min-version';
  static const String _minMacOSVersionArg = 'macos-min-version';

  final Xcode _xcode;

  @override
  final String name = 'xcode-analyze';

  @override
  final String description =
      'Runs Xcode analysis on the iOS and/or macOS example apps.';

  @override
  Future<void> initializeRun() async {
    if (!(getBoolArg(platformIOS) || getBoolArg(platformMacOS))) {
      printError('At least one platform flag must be provided.');
      throw ToolExit(exitInvalidArguments);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final bool testIOS = getBoolArg(platformIOS) &&
        pluginSupportsPlatform(platformIOS, package,
            requiredMode: PlatformSupport.inline);
    final bool testMacOS = getBoolArg(platformMacOS) &&
        pluginSupportsPlatform(platformMacOS, package,
            requiredMode: PlatformSupport.inline);

    final bool multiplePlatformsRequested =
        getBoolArg(platformIOS) && getBoolArg(platformMacOS);
    if (!(testIOS || testMacOS)) {
      return PackageResult.skip('Not implemented for target platform(s).');
    }

    final String minIOSVersion = getStringArg(_minIOSVersionArg);
    final String minMacOSVersion = getStringArg(_minMacOSVersionArg);

    final List<String> failures = <String>[];
    if (testIOS &&
        !await _analyzePlugin(package, 'iOS', extraFlags: <String>[
          '-destination',
          'generic/platform=iOS Simulator',
          if (minIOSVersion.isNotEmpty)
            'IPHONEOS_DEPLOYMENT_TARGET=$minIOSVersion',
        ])) {
      failures.add('iOS');
    }
    if (testMacOS &&
        !await _analyzePlugin(package, 'macOS', extraFlags: <String>[
          if (minMacOSVersion.isNotEmpty)
            'MACOSX_DEPLOYMENT_TARGET=$minMacOSVersion',
        ])) {
      failures.add('macOS');
    }

    // Only provide the failing platform in the failure details if testing
    // multiple platforms, otherwise it's just noise.
    return failures.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(
            multiplePlatformsRequested ? failures : <String>[]);
  }

  /// Analyzes [plugin] for [platform], returning true if it passed analysis.
  Future<bool> _analyzePlugin(
    RepositoryPackage plugin,
    String platform, {
    List<String> extraFlags = const <String>[],
  }) async {
    bool passing = true;
    for (final RepositoryPackage example in plugin.getExamples()) {
      // Running tests and static analyzer.
      final String examplePath = getRelativePosixPath(example.directory,
          from: plugin.directory.parent);
      print('Running $platform tests and analyzer for $examplePath...');
      final int exitCode = await _xcode.runXcodeBuild(
        example.directory,
        actions: <String>['analyze'],
        workspace: '${platform.toLowerCase()}/Runner.xcworkspace',
        scheme: 'Runner',
        configuration: 'Debug',
        extraFlags: <String>[
          ...extraFlags,
          'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
        ],
      );
      if (exitCode == 0) {
        printSuccess('$examplePath ($platform) passed analysis.');
      } else {
        printError('$examplePath ($platform) failed analysis.');
        passing = false;
      }
    }
    return passing;
  }
}
