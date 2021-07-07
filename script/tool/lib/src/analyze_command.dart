// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';

const int _exitBadCustomAnalysisFile = 2;
const int _exitPackagesGetFailed = 3;

/// A command to run Dart analysis on packages.
class AnalyzeCommand extends PackageLoopingCommand {
  /// Creates a analysis command instance.
  AnalyzeCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addMultiOption(_customAnalysisFlag,
        help:
            'Directories (comma separated) that are allowed to have their own analysis options.',
        defaultsTo: <String>[]);
    argParser.addOption(_analysisSdk,
        valueHelp: 'dart-sdk',
        help: 'An optional path to a Dart SDK; this is used to override the '
            'SDK used to provide analysis.');
  }

  static const String _customAnalysisFlag = 'custom-analysis';

  static const String _analysisSdk = 'analysis-sdk';

  late String _dartBinaryPath;

  @override
  final String name = 'analyze';

  @override
  final String description = 'Analyzes all packages using dart analyze.\n\n'
      'This command requires "dart" and "flutter" to be in your path.';

  @override
  final bool hasLongOutput = false;

  /// Checks that there are no unexpected analysis_options.yaml files.
  void _validateAnalysisOptions() {
    final List<FileSystemEntity> files = packagesDir.listSync(recursive: true);
    for (final FileSystemEntity file in files) {
      if (file.basename != 'analysis_options.yaml' &&
          file.basename != '.analysis_options') {
        continue;
      }

      final bool allowed = (getStringListArg(_customAnalysisFlag)).any(
          (String directory) =>
              directory != null &&
              directory.isNotEmpty &&
              p.isWithin(p.join(packagesDir.path, directory), file.path));
      if (allowed) {
        continue;
      }

      printError(
          'Found an extra analysis_options.yaml at ${file.absolute.path}.');
      printError(
          'If this was deliberate, pass the package to the analyze command '
          'with the --$_customAnalysisFlag flag and try again.');
      throw ToolExit(_exitBadCustomAnalysisFile);
    }
  }

  /// Ensures that the dependent packages have been fetched for all packages
  /// (including their sub-packages) that will be analyzed.
  Future<bool> _runPackagesGetOnTargetPackages() async {
    final List<Directory> packageDirectories = await getPackages().toList();
    final Set<String> packagePaths =
        packageDirectories.map((Directory dir) => dir.path).toSet();
    packageDirectories.removeWhere((Directory directory) {
      // Remove the 'example' subdirectories; 'flutter packages get'
      // automatically runs 'pub get' there as part of handling the parent
      // directory.
      return directory.basename == 'example' &&
          packagePaths.contains(directory.parent.path);
    });
    for (final Directory package in packageDirectories) {
      final int exitCode = await processRunner.runAndStream(
          'flutter', <String>['packages', 'get'],
          workingDir: package);
      if (exitCode != 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> initializeRun() async {
    print('Verifying analysis settings...');
    _validateAnalysisOptions();

    print('Fetching dependencies...');
    if (!await _runPackagesGetOnTargetPackages()) {
      printError('Unable to get dependencies.');
      throw ToolExit(_exitPackagesGetFailed);
    }

    // Use the Dart SDK override if one was passed in.
    final String? dartSdk = argResults![_analysisSdk] as String?;
    _dartBinaryPath = dartSdk == null ? 'dart' : p.join(dartSdk, 'bin', 'dart');
  }

  @override
  Future<PackageResult> runForPackage(Directory package) async {
    final int exitCode = await processRunner.runAndStream(
        _dartBinaryPath, <String>['analyze', '--fatal-infos'],
        workingDir: package);
    if (exitCode != 0) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }
}
