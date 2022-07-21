// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to verify Dependabot configuration coverage of packages.
class DependabotCheckCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  DependabotCheckCommand(Directory packagesDir, {GitDir? gitDir})
      : super(packagesDir, gitDir: gitDir) {
    argParser.addOption(_configPathFlag,
        help: 'Path to the Dependabot configuration file',
        defaultsTo: '.github/dependabot.yml');
  }

  static const String _configPathFlag = 'config';

  late Directory _repoRoot;

  // The set of directories covered by "gradle" entries in the config.
  Set<String> _gradleDirs = const <String>{};

  @override
  final String name = 'dependabot-check';

  @override
  final String description =
      'Checks that all packages have Dependabot coverage.';

  @override
  final PackageLoopingType packageLoopingType =
      PackageLoopingType.includeAllSubpackages;

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    final YamlMap config = loadYaml(_repoRoot
        .childFile(getStringArg(_configPathFlag))
        .readAsStringSync()) as YamlMap;
    final dynamic entries = config['updates'];
    if (entries is! YamlList) {
      return;
    }

    const String typeKey = 'package-ecosystem';
    const String dirKey = 'directory';
    _gradleDirs = entries
        .where((dynamic entry) => entry[typeKey] == 'gradle')
        .map((dynamic entry) => (entry as YamlMap)[dirKey] as String)
        .toSet();
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    bool skipped = true;
    final List<String> errors = <String>[];

    final RunState gradleState = _validateDependabotGradleCoverage(package);
    skipped = skipped && gradleState == RunState.skipped;
    if (gradleState == RunState.failed) {
      printError('${indentation}Missing Gradle coverage.');
      errors.add('Missing Gradle coverage');
    }

    // TODO(stuartmorgan): Add other ecosystem checks here as more are enabled.

    if (skipped) {
      return PackageResult.skip('No supported package ecosystems');
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  /// Returns the state for the Dependabot coverage of the Gradle ecosystem for
  /// [package]:
  /// - succeeded if it includes gradle and is covered.
  /// - failed if it includes gradle and is not covered.
  /// - skipped if it doesn't include gradle.
  RunState _validateDependabotGradleCoverage(RepositoryPackage package) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final Directory appDir = androidDir.childDirectory('app');
    if (appDir.existsSync()) {
      // It's an app, so only check for the app directory to be covered.
      final String dependabotPath =
          '/${getRelativePosixPath(appDir, from: _repoRoot)}';
      return _gradleDirs.contains(dependabotPath)
          ? RunState.succeeded
          : RunState.failed;
    } else if (androidDir.existsSync()) {
      // It's a library, so only check for the android directory to be covered.
      final String dependabotPath =
          '/${getRelativePosixPath(androidDir, from: _repoRoot)}';
      return _gradleDirs.contains(dependabotPath)
          ? RunState.succeeded
          : RunState.failed;
    }
    return RunState.skipped;
  }
}
