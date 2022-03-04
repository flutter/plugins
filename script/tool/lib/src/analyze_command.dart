// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:platform/platform.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// A command to run Dart analysis on packages.
class AnalyzeCommand extends PackageLoopingCommand {
  /// Creates a analysis command instance.
  AnalyzeCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addMultiOption(_customAnalysisFlag,
        help:
            'Directories (comma separated) that are allowed to have their own '
            'analysis options.\n\n'
            'Alternately, a list of one or more YAML files that contain a list '
            'of allowed directories.',
        defaultsTo: <String>[]);
    argParser.addOption(_analysisSdk,
        valueHelp: 'dart-sdk',
        help: 'An optional path to a Dart SDK; this is used to override the '
            'SDK used to provide analysis.');
  }

  static const String _customAnalysisFlag = 'custom-analysis';

  static const String _analysisSdk = 'analysis-sdk';

  late String _dartBinaryPath;

  Set<String> _allowedCustomAnalysisDirectories = const <String>{};

  @override
  final String name = 'analyze';

  @override
  final String description = 'Analyzes all packages using dart analyze.\n\n'
      'This command requires "dart" and "flutter" to be in your path.';

  @override
  final bool hasLongOutput = false;

  /// Checks that there are no unexpected analysis_options.yaml files.
  bool _hasUnexpecetdAnalysisOptions(RepositoryPackage package) {
    final List<FileSystemEntity> files =
        package.directory.listSync(recursive: true);
    for (final FileSystemEntity file in files) {
      if (file.basename != 'analysis_options.yaml' &&
          file.basename != '.analysis_options') {
        continue;
      }

      final bool allowed = _allowedCustomAnalysisDirectories.any(
          (String directory) =>
              directory.isNotEmpty &&
              path.isWithin(
                  packagesDir.childDirectory(directory).path, file.path));
      if (allowed) {
        continue;
      }

      printError(
          'Found an extra analysis_options.yaml at ${file.absolute.path}.');
      printError(
          'If this was deliberate, pass the package to the analyze command '
          'with the --$_customAnalysisFlag flag and try again.');
      return true;
    }
    return false;
  }

  @override
  Future<void> initializeRun() async {
    _allowedCustomAnalysisDirectories =
        getStringListArg(_customAnalysisFlag).expand<String>((String item) {
      if (item.endsWith('.yaml')) {
        final File file = packagesDir.fileSystem.file(item);
        return (loadYaml(file.readAsStringSync()) as YamlList)
            .toList()
            .cast<String>();
      }
      return <String>[item];
    }).toSet();

    // Use the Dart SDK override if one was passed in.
    final String? dartSdk = argResults![_analysisSdk] as String?;
    _dartBinaryPath =
        dartSdk == null ? 'dart' : path.join(dartSdk, 'bin', 'dart');
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    // For non-example packages, fetch dependencies. 'flutter packages get'
    // automatically runs 'pub get' in examples as part of handling the parent
    // directory, which is guaranteed to come first in the package enumeration.
    if (package.directory.basename != 'example' ||
        !RepositoryPackage(package.directory.parent).pubspecFile.existsSync()) {
      final int exitCode = await processRunner.runAndStream(
          flutterCommand, <String>['packages', 'get'],
          workingDir: package.directory);
      if (exitCode != 0) {
        return PackageResult.fail(<String>['Unable to get dependencies']);
      }
    }

    if (_hasUnexpecetdAnalysisOptions(package)) {
      return PackageResult.fail(<String>['Unexpected local analysis options']);
    }
    final int exitCode = await processRunner.runAndStream(
        _dartBinaryPath, <String>['analyze', '--fatal-infos'],
        workingDir: package.directory);
    if (exitCode != 0) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }
}
