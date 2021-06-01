// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;

import 'analyze_command.dart';
import 'build_examples_command.dart';
import 'common.dart';
import 'create_all_plugins_app_command.dart';
import 'drive_examples_command.dart';
import 'firebase_test_lab_command.dart';
import 'format_command.dart';
import 'java_test_command.dart';
import 'license_check_command.dart';
import 'lint_podspecs_command.dart';
import 'list_command.dart';
import 'publish_check_command.dart';
import 'publish_plugin_command.dart';
import 'pubspec_check_command.dart';
import 'test_command.dart';
import 'version_check_command.dart';
import 'xctest_command.dart';

void main(List<String> args) {
  const FileSystem fileSystem = LocalFileSystem();

  Directory packagesDir = fileSystem
      .directory(p.join(fileSystem.currentDirectory.path, 'packages'));

  if (!packagesDir.existsSync()) {
    if (p.basename(fileSystem.currentDirectory.path) == 'packages') {
      packagesDir = fileSystem.currentDirectory;
    } else {
      print('Error: Cannot find a "packages" sub-directory');
      io.exit(1);
    }
  }

  final CommandRunner<void> commandRunner = CommandRunner<void>(
      'pub global run flutter_plugin_tools',
      'Productivity utils for hosting multiple plugins within one repository.')
    ..addCommand(AnalyzeCommand(packagesDir, fileSystem))
    ..addCommand(BuildExamplesCommand(packagesDir, fileSystem))
    ..addCommand(CreateAllPluginsAppCommand(packagesDir, fileSystem))
    ..addCommand(DriveExamplesCommand(packagesDir, fileSystem))
    ..addCommand(FirebaseTestLabCommand(packagesDir, fileSystem))
    ..addCommand(FormatCommand(packagesDir, fileSystem))
    ..addCommand(JavaTestCommand(packagesDir, fileSystem))
    ..addCommand(LicenseCheckCommand(packagesDir, fileSystem))
    ..addCommand(LintPodspecsCommand(packagesDir, fileSystem))
    ..addCommand(ListCommand(packagesDir, fileSystem))
    ..addCommand(PublishCheckCommand(packagesDir, fileSystem))
    ..addCommand(PublishPluginCommand(packagesDir, fileSystem))
    ..addCommand(PubspecCheckCommand(packagesDir, fileSystem))
    ..addCommand(TestCommand(packagesDir, fileSystem))
    ..addCommand(VersionCheckCommand(packagesDir, fileSystem))
    ..addCommand(XCTestCommand(packagesDir, fileSystem));

  commandRunner.run(args).catchError((Object e) {
    final ToolExit toolExit = e as ToolExit;
    int exitCode = toolExit.exitCode;
    // This should never happen; this check is here to guarantee that a ToolExit
    // never accidentally has code 0 thus causing CI to pass.
    if (exitCode == 0) {
      assert(false);
      exitCode = 255;
    }
    io.exit(exitCode);
  }, test: (Object e) => e is ToolExit);
}
