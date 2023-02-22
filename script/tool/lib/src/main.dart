// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';

import 'analyze_command.dart';
import 'common/core.dart';

void main(List<String> args) {
  print('''
*** WARNING ***
This copy of the tooling is now only here as a shim for scripts in other
repositories that have not yet been updated, and can only run 'analyze'. For
full tooling in this repository, see the updated instructions:
https://github.com/flutter/packages/blob/main/script/tool/README.md
to switch to running the published version.

''');

  const FileSystem fileSystem = LocalFileSystem();

  Directory packagesDir =
      fileSystem.currentDirectory.childDirectory('packages');

  if (!packagesDir.existsSync()) {
    if (fileSystem.currentDirectory.basename == 'packages') {
      packagesDir = fileSystem.currentDirectory;
    } else {
      print('Error: Cannot find a "packages" sub-directory');
      io.exit(1);
    }
  }

  final CommandRunner<void> commandRunner = CommandRunner<void>(
      'dart pub global run flutter_plugin_tools',
      'Productivity utils for hosting multiple plugins within one repository.')
    ..addCommand(AnalyzeCommand(packagesDir));

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
