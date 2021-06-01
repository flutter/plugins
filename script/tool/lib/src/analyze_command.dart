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
            'Directories (comma separated) that are allowed to have their own analysis options.',
        defaultsTo: <String>[]);
    argParser.addOption(_analysisSdk,
        valueHelp: 'dart-sdk',
        help: 'An optional path to a Dart SDK; this is used to override the '
            'SDK used to provide analysis.');
  }

  static const String _customAnalysisFlag = 'custom-analysis';

  static const String _analysisSdk = 'analysis-sdk';

  @override
  final String name = 'analyze';

  @override
  final String description = 'Analyzes all packages using dart analyze.\n\n'
      'This command requires "dart" and "flutter" to be in your path.';

  @override
  Future<void> run() async {
    print('Verifying analysis settings...');

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

      print('Found an extra analysis_options.yaml in ${file.absolute.path}.');
      print(
          'If this was deliberate, pass the package to the analyze command with the --$_customAnalysisFlag flag and try again.');
      throw ToolExit(1);
    }

    final Stopwatch pubTime = Stopwatch()..start();

    final List<Directory> packageDirectories = await getPackages().toList();
    final Set<String> packagePaths =
        packageDirectories.map((Directory dir) => dir.path).toSet();
    packageDirectories.removeWhere((Directory directory) {
      // We remove the 'example' subdirectories - 'flutter pub get' automatically
      // runs 'pub get' there as part of handling the parent directory.
      return directory.basename == 'example' &&
          packagePaths.contains(directory.parent.path);
    });
    for (final Directory package in packageDirectories) {
      await processRunner.runAndStream('flutter', <String>['packages', 'get'],
          workingDir: package, exitOnError: true);
    }

    pubTime.stop();

    final Stopwatch analysisTime = Stopwatch()..start();

    // Use the Dart SDK override if one was passed in.
    final String? dartSdk = argResults![_analysisSdk] as String?;
    final String dartBinary =
        dartSdk == null ? 'dart' : p.join(dartSdk, 'bin', 'dart');

    final List<String> failingDirectories = <String>[];
    final List<Directory> pluginDirectories = await getPlugins().toList();
    final List<Directory> pluginGroupDirectories =
        _calculatePluginGroups(pluginDirectories);
    for (final Directory pluginGroup in pluginGroupDirectories) {
      final int exitCode = await processRunner.runAndStream(
          dartBinary, <String>['analyze', '--fatal-infos'],
          workingDir: pluginGroup);
      if (exitCode != 0) {
        failingDirectories.add(p.basename(pluginGroup.path));
      }
    }

    analysisTime.stop();

    print('');
    print('[pub time    ] ${pubTime.elapsedMilliseconds / 1000.0}s');
    print('[analyze time] ${analysisTime.elapsedMilliseconds / 1000.0}s');

    print('\n');

    if (failingDirectories.isNotEmpty) {
      print('The following directories have analyzer errors (see above):');
      for (final String dir in failingDirectories) {
        print(' * $dir');
      }
      throw ToolExit(1);
    } else {
      print('No analyzer errors found!');
    }
  }

  /// todo: doc
  List<Directory> _calculatePluginGroups(List<Directory> pluginDirectories) {
    final Map<String, List<Directory>> groups = <String, List<Directory>>{};

    for (final Directory dir in pluginDirectories) {
      final String key = dir.parent.path;
      groups.putIfAbsent(key, () => <Directory>[]);
      groups[key]!.add(dir);
    }

    final List<Directory> pluginGroups = <Directory>[];

    for (final String groupPath in groups.keys) {
      final List<Directory> children = groups[groupPath]!;

      if (children.length < 2) {
        pluginGroups.addAll(children);
      } else {
        // todo: determine whether this is a valid group
        children.sort((Directory a, Directory b) {
          return a.basename.length - b.basename.length;
        });

        final String prefix = children.first.basename;
        if (children.any((Directory dir) => !dir.basename.startsWith(prefix))) {
          pluginGroups.addAll(children);
        } else {
          pluginGroups.add(children.first.parent);
        }
      }
    }

    pluginGroups.sort((Directory a, Directory b) => a.path.compareTo(b.path));

    return pluginGroups;
  }
}
