// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;

import 'core.dart';
import 'git_version_finder.dart';
import 'process_runner.dart';

/// Interface definition for all commands in this tool.
abstract class PluginCommand extends Command<void> {
  /// Creates a command to operate on [packagesDir] with the given environment.
  PluginCommand(
    this.packagesDir, {
    this.processRunner = const ProcessRunner(),
    this.gitDir,
  }) {
    argParser.addMultiOption(
      _pluginsArg,
      splitCommas: true,
      help:
          'Specifies which plugins the command should run on (before sharding).',
      valueHelp: 'plugin1,plugin2,...',
    );
    argParser.addOption(
      _shardIndexArg,
      help: 'Specifies the zero-based index of the shard to '
          'which the command applies.',
      valueHelp: 'i',
      defaultsTo: '0',
    );
    argParser.addOption(
      _shardCountArg,
      help: 'Specifies the number of shards into which plugins are divided.',
      valueHelp: 'n',
      defaultsTo: '1',
    );
    argParser.addMultiOption(
      _excludeArg,
      abbr: 'e',
      help: 'Exclude packages from this command.',
      defaultsTo: <String>[],
    );
    argParser.addFlag(_runOnChangedPackagesArg,
        help: 'Run the command on changed packages/plugins.\n'
            'If the $_pluginsArg is specified, this flag is ignored.\n'
            'If no packages have changed, or if there have been changes that may\n'
            'affect all packages, the command runs on all packages.\n'
            'The packages excluded with $_excludeArg is also excluded even if changed.\n'
            'See $_kBaseSha if a custom base is needed to determine the diff.');
    argParser.addOption(_kBaseSha,
        help: 'The base sha used to determine git diff. \n'
            'This is useful when $_runOnChangedPackagesArg is specified.\n'
            'If not specified, merge-base is used as base sha.');
  }

  static const String _pluginsArg = 'plugins';
  static const String _shardIndexArg = 'shardIndex';
  static const String _shardCountArg = 'shardCount';
  static const String _excludeArg = 'exclude';
  static const String _runOnChangedPackagesArg = 'run-on-changed-packages';
  static const String _kBaseSha = 'base-sha';

  /// The directory containing the plugin packages.
  final Directory packagesDir;

  /// The process runner.
  ///
  /// This can be overridden for testing.
  final ProcessRunner processRunner;

  /// The git directory to use. By default it uses the parent directory.
  ///
  /// This can be mocked for testing.
  final GitDir? gitDir;

  int? _shardIndex;
  int? _shardCount;

  /// The shard of the overall command execution that this instance should run.
  int get shardIndex {
    if (_shardIndex == null) {
      _checkSharding();
    }
    return _shardIndex!;
  }

  /// The number of shards this command is divided into.
  int get shardCount {
    if (_shardCount == null) {
      _checkSharding();
    }
    return _shardCount!;
  }

  /// Convenience accessor for boolean arguments.
  bool getBoolArg(String key) {
    return (argResults![key] as bool?) ?? false;
  }

  /// Convenience accessor for String arguments.
  String getStringArg(String key) {
    return (argResults![key] as String?) ?? '';
  }

  /// Convenience accessor for List<String> arguments.
  List<String> getStringListArg(String key) {
    return (argResults![key] as List<String>?) ?? <String>[];
  }

  void _checkSharding() {
    final int? shardIndex = int.tryParse(getStringArg(_shardIndexArg));
    final int? shardCount = int.tryParse(getStringArg(_shardCountArg));
    if (shardIndex == null) {
      usageException('$_shardIndexArg must be an integer');
    }
    if (shardCount == null) {
      usageException('$_shardCountArg must be an integer');
    }
    if (shardCount < 1) {
      usageException('$_shardCountArg must be positive');
    }
    if (shardIndex < 0 || shardCount <= shardIndex) {
      usageException(
          '$_shardIndexArg must be in the half-open range [0..$shardCount[');
    }
    _shardIndex = shardIndex;
    _shardCount = shardCount;
  }

  /// Returns the root Dart package folders of the plugins involved in this
  /// command execution.
  Stream<Directory> getPlugins() async* {
    // To avoid assuming consistency of `Directory.list` across command
    // invocations, we collect and sort the plugin folders before sharding.
    // This is considered an implementation detail which is why the API still
    // uses streams.
    final List<Directory> allPlugins = await _getAllPlugins().toList();
    allPlugins.sort((Directory d1, Directory d2) => d1.path.compareTo(d2.path));
    // Sharding 10 elements into 3 shards should yield shard sizes 4, 4, 2.
    // Sharding  9 elements into 3 shards should yield shard sizes 3, 3, 3.
    // Sharding  2 elements into 3 shards should yield shard sizes 1, 1, 0.
    final int shardSize = allPlugins.length ~/ shardCount +
        (allPlugins.length % shardCount == 0 ? 0 : 1);
    final int start = min(shardIndex * shardSize, allPlugins.length);
    final int end = min(start + shardSize, allPlugins.length);

    for (final Directory plugin in allPlugins.sublist(start, end)) {
      yield plugin;
    }
  }

  /// Returns the root Dart package folders of the plugins involved in this
  /// command execution, assuming there is only one shard.
  ///
  /// Plugin packages can exist in the following places relative to the packages
  /// directory:
  ///
  /// 1. As a Dart package in a directory which is a direct child of the
  ///    packages directory. This is a plugin where all of the implementations
  ///    exist in a single Dart package.
  /// 2. Several plugin packages may live in a directory which is a direct
  ///    child of the packages directory. This directory groups several Dart
  ///    packages which implement a single plugin. This directory contains a
  ///    "client library" package, which declares the API for the plugin, as
  ///    well as one or more platform-specific implementations.
  /// 3./4. Either of the above, but in a third_party/packages/ directory that
  ///    is a sibling of the packages directory. This is used for a small number
  ///    of packages in the flutter/packages repository.
  Stream<Directory> _getAllPlugins() async* {
    Set<String> plugins = Set<String>.from(getStringListArg(_pluginsArg));
    final Set<String> excludedPlugins =
        Set<String>.from(getStringListArg(_excludeArg));
    final bool runOnChangedPackages = getBoolArg(_runOnChangedPackagesArg);
    if (plugins.isEmpty &&
        runOnChangedPackages &&
        !(await _changesRequireFullTest())) {
      plugins = await _getChangedPackages();
    }

    final Directory thirdPartyPackagesDirectory = packagesDir.parent
        .childDirectory('third_party')
        .childDirectory('packages');

    for (final Directory dir in <Directory>[
      packagesDir,
      if (thirdPartyPackagesDirectory.existsSync()) thirdPartyPackagesDirectory,
    ]) {
      await for (final FileSystemEntity entity
          in dir.list(followLinks: false)) {
        // A top-level Dart package is a plugin package.
        if (_isDartPackage(entity)) {
          if (!excludedPlugins.contains(entity.basename) &&
              (plugins.isEmpty || plugins.contains(p.basename(entity.path)))) {
            yield entity as Directory;
          }
        } else if (entity is Directory) {
          // Look for Dart packages under this top-level directory.
          await for (final FileSystemEntity subdir
              in entity.list(followLinks: false)) {
            if (_isDartPackage(subdir)) {
              // If --plugin=my_plugin is passed, then match all federated
              // plugins under 'my_plugin'. Also match if the exact plugin is
              // passed.
              final String relativePath =
                  p.relative(subdir.path, from: dir.path);
              final String packageName = p.basename(subdir.path);
              final String basenamePath = p.basename(entity.path);
              if (!excludedPlugins.contains(basenamePath) &&
                  !excludedPlugins.contains(packageName) &&
                  !excludedPlugins.contains(relativePath) &&
                  (plugins.isEmpty ||
                      plugins.contains(relativePath) ||
                      plugins.contains(basenamePath))) {
                yield subdir as Directory;
              }
            }
          }
        }
      }
    }
  }

  /// Returns the example Dart package folders of the plugins involved in this
  /// command execution.
  Stream<Directory> getExamples() =>
      getPlugins().expand<Directory>(getExamplesForPlugin);

  /// Returns all Dart package folders (typically, plugin + example) of the
  /// plugins involved in this command execution.
  Stream<Directory> getPackages() async* {
    await for (final Directory plugin in getPlugins()) {
      yield plugin;
      yield* plugin
          .list(recursive: true, followLinks: false)
          .where(_isDartPackage)
          .cast<Directory>();
    }
  }

  /// Returns the files contained, recursively, within the plugins
  /// involved in this command execution.
  Stream<File> getFiles() {
    return getPlugins().asyncExpand<File>((Directory folder) => folder
        .list(recursive: true, followLinks: false)
        .where((FileSystemEntity entity) => entity is File)
        .cast<File>());
  }

  /// Returns whether the specified entity is a directory containing a
  /// `pubspec.yaml` file.
  bool _isDartPackage(FileSystemEntity entity) {
    return entity is Directory && entity.childFile('pubspec.yaml').existsSync();
  }

  /// Returns the example Dart packages contained in the specified plugin, or
  /// an empty List, if the plugin has no examples.
  Iterable<Directory> getExamplesForPlugin(Directory plugin) {
    final Directory exampleFolder = plugin.childDirectory('example');
    if (!exampleFolder.existsSync()) {
      return <Directory>[];
    }
    if (isFlutterPackage(exampleFolder)) {
      return <Directory>[exampleFolder];
    }
    // Only look at the subdirectories of the example directory if the example
    // directory itself is not a Dart package, and only look one level below the
    // example directory for other dart packages.
    return exampleFolder
        .listSync()
        .where((FileSystemEntity entity) => isFlutterPackage(entity))
        .cast<Directory>();
  }

  /// Retrieve an instance of [GitVersionFinder] based on `_kBaseSha` and [gitDir].
  ///
  /// Throws tool exit if [gitDir] nor root directory is a git directory.
  Future<GitVersionFinder> retrieveVersionFinder() async {
    final String rootDir = packagesDir.parent.absolute.path;
    final String baseSha = getStringArg(_kBaseSha);

    GitDir? baseGitDir = gitDir;
    if (baseGitDir == null) {
      if (!await GitDir.isGitDir(rootDir)) {
        printError(
          '$rootDir is not a valid Git repository.',
        );
        throw ToolExit(2);
      }
      baseGitDir = await GitDir.fromExisting(rootDir);
    }

    final GitVersionFinder gitVersionFinder =
        GitVersionFinder(baseGitDir, baseSha);
    return gitVersionFinder;
  }

  // Returns packages that have been changed relative to the git base.
  Future<Set<String>> _getChangedPackages() async {
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();

    final List<String> allChangedFiles =
        await gitVersionFinder.getChangedFiles();
    final Set<String> packages = <String>{};
    for (final String path in allChangedFiles) {
      final List<String> pathComponents = path.split('/');
      final int packagesIndex =
          pathComponents.indexWhere((String element) => element == 'packages');
      if (packagesIndex != -1) {
        packages.add(pathComponents[packagesIndex + 1]);
      }
    }
    if (packages.isEmpty) {
      print('No changed packages.');
    } else {
      final String changedPackages = packages.join(',');
      print('Changed packages: $changedPackages');
    }
    return packages;
  }

  // Returns true if one or more files changed that have the potential to affect
  // any plugin (e.g., CI script changes).
  Future<bool> _changesRequireFullTest() async {
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();

    const List<String> specialFiles = <String>[
      '.ci.yaml', // LUCI config.
      '.cirrus.yml', // Cirrus config.
      '.clang-format', // ObjC and C/C++ formatting options.
      'analysis_options.yaml', // Dart analysis settings.
    ];
    const List<String> specialDirectories = <String>[
      '.ci/', // Support files for CI.
      'script/', // This tool, and its wrapper scripts.
    ];
    // Directory entries must end with / to avoid over-matching, since the
    // check below is done via string prefixing.
    assert(specialDirectories.every((String dir) => dir.endsWith('/')));

    final List<String> allChangedFiles =
        await gitVersionFinder.getChangedFiles();
    return allChangedFiles.any((String path) =>
        specialFiles.contains(path) ||
        specialDirectories.any((String dir) => path.startsWith(dir)));
  }
}
