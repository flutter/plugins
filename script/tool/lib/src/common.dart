// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

typedef void Print(Object object);

/// Key for windows platform.
const String kWindows = 'windows';

/// Key for macos platform.
const String kMacos = 'macos';

/// Key for linux platform.
const String kLinux = 'linux';

/// Key for IPA (iOS) platform.
const String kIos = 'ios';

/// Key for APK (Android) platform.
const String kAndroid = 'android';

/// Key for Web platform.
const String kWeb = 'web';

/// Key for IPA.
const String kIpa = 'ipa';

/// Key for APK.
const String kApk = 'apk';

/// Key for enable experiment.
const String kEnableExperiment = 'enable-experiment';

/// Returns whether the given directory contains a Flutter package.
bool isFlutterPackage(FileSystemEntity entity, FileSystem fileSystem) {
  if (entity == null || entity is! Directory) {
    return false;
  }

  try {
    final File pubspecFile =
        fileSystem.file(p.join(entity.path, 'pubspec.yaml'));
    final YamlMap pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
    final YamlMap dependencies = pubspecYaml['dependencies'];
    if (dependencies == null) {
      return false;
    }
    return dependencies.containsKey('flutter');
  } on FileSystemException {
    return false;
  } on YamlException {
    return false;
  }
}

/// Returns whether the given directory contains a Flutter [platform] plugin.
///
/// It checks this by looking for the following pattern in the pubspec:
///
///     flutter:
///       plugin:
///         platforms:
///           [platform]:
bool pluginSupportsPlatform(
    String platform, FileSystemEntity entity, FileSystem fileSystem) {
  assert(platform == kIos ||
      platform == kAndroid ||
      platform == kWeb ||
      platform == kMacos ||
      platform == kWindows ||
      platform == kLinux);
  if (entity == null || entity is! Directory) {
    return false;
  }

  try {
    final File pubspecFile =
        fileSystem.file(p.join(entity.path, 'pubspec.yaml'));
    final YamlMap pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
    final YamlMap flutterSection = pubspecYaml['flutter'];
    if (flutterSection == null) {
      return false;
    }
    final YamlMap pluginSection = flutterSection['plugin'];
    if (pluginSection == null) {
      return false;
    }
    final YamlMap platforms = pluginSection['platforms'];
    if (platforms == null) {
      // Legacy plugin specs are assumed to support iOS and Android.
      if (!pluginSection.containsKey('platforms')) {
        return platform == kIos || platform == kAndroid;
      }
      return false;
    }
    return platforms.containsKey(platform);
  } on FileSystemException {
    return false;
  } on YamlException {
    return false;
  }
}

/// Returns whether the given directory contains a Flutter Android plugin.
bool isAndroidPlugin(FileSystemEntity entity, FileSystem fileSystem) {
  return pluginSupportsPlatform(kAndroid, entity, fileSystem);
}

/// Returns whether the given directory contains a Flutter iOS plugin.
bool isIosPlugin(FileSystemEntity entity, FileSystem fileSystem) {
  return pluginSupportsPlatform(kIos, entity, fileSystem);
}

/// Returns whether the given directory contains a Flutter web plugin.
bool isWebPlugin(FileSystemEntity entity, FileSystem fileSystem) {
  return pluginSupportsPlatform(kWeb, entity, fileSystem);
}

/// Returns whether the given directory contains a Flutter Windows plugin.
bool isWindowsPlugin(FileSystemEntity entity, FileSystem fileSystem) {
  return pluginSupportsPlatform(kWindows, entity, fileSystem);
}

/// Returns whether the given directory contains a Flutter macOS plugin.
bool isMacOsPlugin(FileSystemEntity entity, FileSystem fileSystem) {
  return pluginSupportsPlatform(kMacos, entity, fileSystem);
}

/// Returns whether the given directory contains a Flutter linux plugin.
bool isLinuxPlugin(FileSystemEntity entity, FileSystem fileSystem) {
  return pluginSupportsPlatform(kLinux, entity, fileSystem);
}

/// Throws a [ToolExit] with `exitCode` and log the `errorMessage` in red.
void PrintErrorAndExit({@required String errorMessage, int exitCode = 1}) {
  final Colorize redError = Colorize(errorMessage)..red();
  print(redError);
  throw ToolExit(exitCode);
}

/// Error thrown when a command needs to exit with a non-zero exit code.
class ToolExit extends Error {
  ToolExit(this.exitCode);

  final int exitCode;
}

abstract class PluginCommand extends Command<Null> {
  PluginCommand(
    this.packagesDir,
    this.fileSystem, {
    this.processRunner = const ProcessRunner(),
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
  }

  static const String _pluginsArg = 'plugins';
  static const String _shardIndexArg = 'shardIndex';
  static const String _shardCountArg = 'shardCount';
  static const String _excludeArg = 'exclude';

  /// The directory containing the plugin packages.
  final Directory packagesDir;

  /// The file system.
  ///
  /// This can be overridden for testing.
  final FileSystem fileSystem;

  /// The process runner.
  ///
  /// This can be overridden for testing.
  final ProcessRunner processRunner;

  int _shardIndex;
  int _shardCount;

  int get shardIndex {
    if (_shardIndex == null) {
      checkSharding();
    }
    return _shardIndex;
  }

  int get shardCount {
    if (_shardCount == null) {
      checkSharding();
    }
    return _shardCount;
  }

  void checkSharding() {
    final int shardIndex = int.tryParse(argResults[_shardIndexArg]);
    final int shardCount = int.tryParse(argResults[_shardCountArg]);
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

    for (Directory plugin in allPlugins.sublist(start, end)) {
      yield plugin;
    }
  }

  /// Returns the root Dart package folders of the plugins involved in this
  /// command execution, assuming there is only one shard.
  ///
  /// Plugin packages can exist in one of two places relative to the packages
  /// directory.
  ///
  /// 1. As a Dart package in a directory which is a direct child of the
  ///    packages directory. This is a plugin where all of the implementations
  ///    exist in a single Dart package.
  /// 2. Several plugin packages may live in a directory which is a direct
  ///    child of the packages directory. This directory groups several Dart
  ///    packages which implement a single plugin. This directory contains a
  ///    "client library" package, which declares the API for the plugin, as
  ///    well as one or more platform-specific implementations.
  Stream<Directory> _getAllPlugins() async* {
    final Set<String> plugins = Set<String>.from(argResults[_pluginsArg]);
    final Set<String> excludedPlugins =
        Set<String>.from(argResults[_excludeArg]);

    await for (FileSystemEntity entity
        in packagesDir.list(followLinks: false)) {
      // A top-level Dart package is a plugin package.
      if (_isDartPackage(entity)) {
        if (!excludedPlugins.contains(entity.basename) &&
            (plugins.isEmpty || plugins.contains(p.basename(entity.path)))) {
          yield entity;
        }
      } else if (entity is Directory) {
        // Look for Dart packages under this top-level directory.
        await for (FileSystemEntity subdir in entity.list(followLinks: false)) {
          if (_isDartPackage(subdir)) {
            // If --plugin=my_plugin is passed, then match all federated
            // plugins under 'my_plugin'. Also match if the exact plugin is
            // passed.
            final String relativePath =
                p.relative(subdir.path, from: packagesDir.path);
            final String packageName = p.basename(subdir.path);
            final String basenamePath = p.basename(entity.path);
            if (!excludedPlugins.contains(basenamePath) &&
                !excludedPlugins.contains(packageName) &&
                !excludedPlugins.contains(relativePath) &&
                (plugins.isEmpty ||
                    plugins.contains(relativePath) ||
                    plugins.contains(basenamePath))) {
              yield subdir;
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
    await for (Directory plugin in getPlugins()) {
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
    return entity is Directory &&
        fileSystem.file(p.join(entity.path, 'pubspec.yaml')).existsSync();
  }

  /// Returns the example Dart packages contained in the specified plugin, or
  /// an empty List, if the plugin has no examples.
  Iterable<Directory> getExamplesForPlugin(Directory plugin) {
    final Directory exampleFolder =
        fileSystem.directory(p.join(plugin.path, 'example'));
    if (!exampleFolder.existsSync()) {
      return <Directory>[];
    }
    if (isFlutterPackage(exampleFolder, fileSystem)) {
      return <Directory>[exampleFolder];
    }
    // Only look at the subdirectories of the example directory if the example
    // directory itself is not a Dart package, and only look one level below the
    // example directory for other dart packages.
    return exampleFolder
        .listSync()
        .where(
            (FileSystemEntity entity) => isFlutterPackage(entity, fileSystem))
        .cast<Directory>();
  }
}

/// A class used to run processes.
///
/// We use this instead of directly running the process so it can be overridden
/// in tests.
class ProcessRunner {
  const ProcessRunner();

  /// Run the [executable] with [args] and stream output to stderr and stdout.
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// If [exitOnError] is set to `true`, then this will throw an error if
  /// the [executable] terminates with a non-zero exit code.
  ///
  /// Returns the exit code of the [executable].
  Future<int> runAndStream(
    String executable,
    List<String> args, {
    Directory workingDir,
    bool exitOnError = false,
  }) async {
    print(
        'Running command: "$executable ${args.join(' ')}" in ${workingDir?.path ?? io.Directory.current.path}');
    final io.Process process = await io.Process.start(executable, args,
        workingDirectory: workingDir?.path);
    await io.stdout.addStream(process.stdout);
    await io.stderr.addStream(process.stderr);
    if (exitOnError && await process.exitCode != 0) {
      final String error =
          _getErrorString(executable, args, workingDir: workingDir);
      print('$error See above for details.');
      throw ToolExit(await process.exitCode);
    }
    return process.exitCode;
  }

  /// Run the [executable] with [args].
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// If [exitOnError] is set to `true`, then this will throw an error if
  /// the [executable] terminates with a non-zero exit code.
  ///
  /// Returns the [io.ProcessResult] of the [executable].
  Future<io.ProcessResult> run(String executable, List<String> args,
      {Directory workingDir,
      bool exitOnError = false,
      stdoutEncoding = io.systemEncoding,
      stderrEncoding = io.systemEncoding}) async {
    return io.Process.run(executable, args,
        workingDirectory: workingDir?.path,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding);
  }

  /// Starts the [executable] with [args].
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// Returns the started [io.Process].
  Future<io.Process> start(String executable, List<String> args,
      {Directory workingDirectory}) async {
    final io.Process process = await io.Process.start(executable, args,
        workingDirectory: workingDirectory?.path);
    return process;
  }

  /// Run the [executable] with [args], throwing an error on non-zero exit code.
  ///
  /// Unlike [runAndStream], this does not stream the process output to stdout.
  /// It also unconditionally throws an error on a non-zero exit code.
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// Returns the [io.ProcessResult] of running the [executable].
  Future<io.ProcessResult> runAndExitOnError(
    String executable,
    List<String> args, {
    Directory workingDir,
  }) async {
    final io.ProcessResult result = await io.Process.run(executable, args,
        workingDirectory: workingDir?.path);
    if (result.exitCode != 0) {
      final String error =
          _getErrorString(executable, args, workingDir: workingDir);
      print('$error Stderr:\n${result.stdout}');
      throw ToolExit(result.exitCode);
    }
    return result;
  }

  String _getErrorString(String executable, List<String> args,
      {Directory workingDir}) {
    final String workdir = workingDir == null ? '' : ' in ${workingDir.path}';
    return 'ERROR: Unable to execute "$executable ${args.join(' ')}"$workdir.';
  }
}

/// Finding diffs based on `baseGitDir` and `baseSha`.
class GitVersionFinder {
  /// Constructor
  GitVersionFinder(this.baseGitDir, this.baseSha);

  /// The top level directory of the git repo.
  ///
  /// That is where the .git/ folder exists.
  final GitDir baseGitDir;

  /// The base sha used to get diff.
  final String baseSha;

  static bool _isPubspec(String file) {
    return file.trim().endsWith('pubspec.yaml');
  }

  /// Get a list of all the pubspec.yaml file that is changed.
  Future<List<String>> getChangedPubSpecs() async {
    return (await getChangedFiles()).where(_isPubspec).toList();
  }

  /// Get a list of all the changed files.
  Future<List<String>> getChangedFiles() async {
    final io.ProcessResult changedFilesCommand = await baseGitDir.runCommand(
        <String>['diff', '--name-only', '${await _getBaseSha()}', 'HEAD']);
    if (changedFilesCommand.stdout.toString() == null ||
        changedFilesCommand.stdout.toString().isEmpty) {
      return <String>[];
    }
    final List<String> changedFiles = changedFilesCommand.stdout
        .toString()
        .split('\n')
          ..removeWhere((element) => element.isEmpty);
    return changedFiles.toList();
  }

  /// Get the package version specified in the pubspec file in `pubspecPath` and at the revision of `gitRef`.
  Future<Version> getPackageVersion(String pubspecPath, String gitRef) async {
    final io.ProcessResult gitShow =
        await baseGitDir.runCommand(<String>['show', '$gitRef:$pubspecPath']);
    final String fileContent = gitShow.stdout;
    final String versionString = loadYaml(fileContent)['version'];
    return versionString == null ? null : Version.parse(versionString);
  }

  Future<String> _getBaseSha() async {
    if (baseSha != null && baseSha.isNotEmpty) {
      return baseSha;
    }

    io.ProcessResult baseShaFromMergeBase = await baseGitDir.runCommand(
        <String>['merge-base', '--fork-point', 'FETCH_HEAD', 'HEAD'],
        throwOnError: false);
    if (baseShaFromMergeBase == null ||
        baseShaFromMergeBase.stderr != null ||
        baseShaFromMergeBase.stdout == null) {
      baseShaFromMergeBase = await baseGitDir
          .runCommand(<String>['merge-base', 'FETCH_HEAD', 'HEAD']);
    }
    return (baseShaFromMergeBase.stdout as String).replaceAll('\n', '');
  }
}
