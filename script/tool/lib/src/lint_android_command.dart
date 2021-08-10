// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:platform/platform.dart';

import 'common/gradle.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';

/// Lint the CocoaPod podspecs and run unit tests.
///
/// See https://guides.cocoapods.org/terminal/commands.html#pod_lib_lint.
class LintAndroidCommand extends PackageLoopingCommand {
  /// Creates an instance of the linter command.
  LintAndroidCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform);

  @override
  final String name = 'lint-android';

  @override
  final String description = 'Runs "gradlew lint" on Android plugins.\n\n'
      'Requires the example to have been build at least once before running.';

  @override
  Future<PackageResult> runForPackage(Directory package) async {
    if (!isAndroidPlugin(package)) {
      return PackageResult.skip('Plugin does not support Android.');
    }

    final Directory exampleDirectory = package.childDirectory('example');
    final GradleProject project = GradleProject(exampleDirectory,
        processRunner: processRunner, platform: platform);

    if (!project.isConfigured()) {
      return PackageResult.fail(<String>['Build example before linting']);
    }

    // Only lint one build mode to avoid extra work.
    //
    // TODO(stuartmorgan): Consider adding an XML parser to read and summarize
    // all results. Currently, only the first three errors will be shown, and
    // the rest are only in an XML file that won't be accessible for CI runs.
    final int exitCode = await project.runCommand('lintDebug');

    return exitCode == 0 ? PackageResult.success() : PackageResult.fail();
  }
}
