// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

/// A command to run Dart analysis on packages.
class AnalyzeCommand extends PluginCommand {
  /// Creates a analysis command instance.
  AnalyzeCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addMultiOption(_customAnalysisFlag,
        help:
            'Directories (comma seperated) that are allowed to have their own analysis options.',
        defaultsTo: <String>[]);
  }

  static const String _customAnalysisFlag = 'custom-analysis';

  @override
  final String name = 'analyze';

  @override
  final String description = 'Analyzes all packages using package:tuneup.\n\n'
      'This command requires "pub" and "flutter" to be in your path.';

  @override
  Future<void> run() async {
    print('Verifying analysis settings...');
    final List<FileSystemEntity> files = packagesDir.listSync(recursive: true);
    for (final FileSystemEntity file in files) {
      if (file.basename != 'analysis_options.yaml' &&
          file.basename != '.analysis_options') {
        continue;
      }

      final bool allowed = (argResults[_customAnalysisFlag] as List<String>)
          .any((String directory) =>
              directory != null &&
              directory.isNotEmpty &&
              p.isWithin(p.join(packagesDir.path, directory), file.path));
      if (allowed) {
        continue;
      }

      print('Found an extra analysis_options.yaml in ${file.absolute.path}.');
      print(
          'If this was deliberate, pass the package to the analyze command with the --$_customAnalysisFlag flag and try again.');
      throw ToolExit(1);
    }

    print('Activating tuneup package...');
    await processRunner.runAndStream(
        'pub', <String>['global', 'activate', 'tuneup'],
        workingDir: packagesDir, exitOnError: true);

    await for (final Directory package in getPackages()) {
      if (isFlutterPackage(package, fileSystem)) {
        await processRunner.runAndStream('flutter', <String>['packages', 'get'],
            workingDir: package, exitOnError: true);
      } else {
        await processRunner.runAndStream('pub', <String>['get'],
            workingDir: package, exitOnError: true);
      }
    }

    final List<String> failingPackages = <String>[];
    await for (final Directory package in getPlugins()) {
      final int exitCode = await processRunner.runAndStream(
          'pub', <String>['global', 'run', 'tuneup', 'check'],
          workingDir: package);
      if (exitCode != 0) {
        failingPackages.add(p.basename(package.path));
      }
    }

    print('\n\n');
    if (failingPackages.isNotEmpty) {
      print('The following packages have analyzer errors (see above):');
      for (final String package in failingPackages) {
        print(' * $package');
      }
      throw ToolExit(1);
    }

    print('No analyzer errors found!');
  }
}
