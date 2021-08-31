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
    argParser.addFlag(kPlatformIos, help: 'Analyze iOS');
    argParser.addFlag(kPlatformMacos, help: 'Analyze macOS');
  }

  final Xcode _xcode;

  @override
  final String name = 'xcode-analyze';

  @override
  final String description =
      'Runs Xcode analysis on the iOS and/or macOS example apps.';

  @override
  Future<void> initializeRun() async {
    if (!(getBoolArg(kPlatformIos) || getBoolArg(kPlatformMacos))) {
      printError('At least one platform flag must be provided.');
      throw ToolExit(exitInvalidArguments);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final bool testIos = getBoolArg(kPlatformIos) &&
        pluginSupportsPlatform(kPlatformIos, package,
            requiredMode: PlatformSupport.inline);
    final bool testMacos = getBoolArg(kPlatformMacos) &&
        pluginSupportsPlatform(kPlatformMacos, package,
            requiredMode: PlatformSupport.inline);

    final bool multiplePlatformsRequested =
        getBoolArg(kPlatformIos) && getBoolArg(kPlatformMacos);
    if (!(testIos || testMacos)) {
      return PackageResult.skip('Not implemented for target platform(s).');
    }

    final List<String> failures = <String>[];
    if (testIos &&
        !await _analyzePlugin(package, 'iOS', extraFlags: <String>[
          '-destination',
          'generic/platform=iOS Simulator'
        ])) {
      failures.add('iOS');
    }
    if (testMacos && !await _analyzePlugin(package, 'macOS')) {
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
