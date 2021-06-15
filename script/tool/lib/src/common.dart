// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// The signature for a print handler for commands that allow overriding the
/// print destination.
typedef Print = void Function(Object? object);

/// Key for windows platform.
const String kPlatformFlagWindows = 'windows';

/// Key for macos platform.
const String kPlatformFlagMacos = 'macos';

/// Key for linux platform.
const String kPlatformFlagLinux = 'linux';

/// Key for IPA (iOS) platform.
const String kPlatformFlagIos = 'ios';

/// Key for APK (Android) platform.
const String kPlatformFlagAndroid = 'android';

/// Key for Web platform.
const String kPlatformFlagWeb = 'web';

/// Key for enable experiment.
const String kEnableExperiment = 'enable-experiment';

/// Returns whether the given directory contains a Flutter package.
bool isFlutterPackage(FileSystemEntity entity) {
  if (entity is! Directory) {
    return false;
  }

  try {
    final File pubspecFile = entity.childFile('pubspec.yaml');
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final YamlMap? dependencies = pubspecYaml['dependencies'] as YamlMap?;
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

/// Possible plugin support options for a platform.
enum PlatformSupport {
  /// The platform has an implementation in the package.
  inline,

  /// The platform has an endorsed federated implementation in another package.
  federated,
}

/// Returns whether the given directory contains a Flutter [platform] plugin.
///
/// It checks this by looking for the following pattern in the pubspec:
///
///     flutter:
///       plugin:
///         platforms:
///           [platform]:
///
/// If [requiredMode] is provided, the plugin must have the given type of
/// implementation in order to return true.
bool pluginSupportsPlatform(String platform, FileSystemEntity entity,
    {PlatformSupport? requiredMode}) {
  assert(platform == kPlatformFlagIos ||
      platform == kPlatformFlagAndroid ||
      platform == kPlatformFlagWeb ||
      platform == kPlatformFlagMacos ||
      platform == kPlatformFlagWindows ||
      platform == kPlatformFlagLinux);
  if (entity is! Directory) {
    return false;
  }

  try {
    final File pubspecFile = entity.childFile('pubspec.yaml');
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final YamlMap? flutterSection = pubspecYaml['flutter'] as YamlMap?;
    if (flutterSection == null) {
      return false;
    }
    final YamlMap? pluginSection = flutterSection['plugin'] as YamlMap?;
    if (pluginSection == null) {
      return false;
    }
    final YamlMap? platforms = pluginSection['platforms'] as YamlMap?;
    if (platforms == null) {
      // Legacy plugin specs are assumed to support iOS and Android. They are
      // never federated.
      if (requiredMode == PlatformSupport.federated) {
        return false;
      }
      if (!pluginSection.containsKey('platforms')) {
        return platform == kPlatformFlagIos || platform == kPlatformFlagAndroid;
      }
      return false;
    }
    final YamlMap? platformEntry = platforms[platform] as YamlMap?;
    if (platformEntry == null) {
      return false;
    }
    // If the platform entry is present, then it supports the platform. Check
    // for required mode if specified.
    final bool federated = platformEntry.containsKey('default_package');
    return requiredMode == null ||
        federated == (requiredMode == PlatformSupport.federated);
  } on FileSystemException {
    return false;
  } on YamlException {
    return false;
  }
}

/// Returns whether the given directory contains a Flutter Android plugin.
bool isAndroidPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagAndroid, entity);
}

/// Returns whether the given directory contains a Flutter iOS plugin.
bool isIosPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagIos, entity);
}

/// Returns whether the given directory contains a Flutter web plugin.
bool isWebPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagWeb, entity);
}

/// Returns whether the given directory contains a Flutter Windows plugin.
bool isWindowsPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagWindows, entity);
}

/// Returns whether the given directory contains a Flutter macOS plugin.
bool isMacOsPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagMacos, entity);
}

/// Returns whether the given directory contains a Flutter linux plugin.
bool isLinuxPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagLinux, entity);
}

/// Prints `errorMessage` in red.
void printError(String errorMessage) {
  final Colorize redError = Colorize(errorMessage)..red();
  print(redError);
}

/// Error thrown when a command needs to exit with a non-zero exit code.
class ToolExit extends Error {
  /// Creates a tool exit with the given [exitCode].
  ToolExit(this.exitCode);

  /// The code that the process should exit with.
  final int exitCode;
}

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

/// A class used to run processes.
///
/// We use this instead of directly running the process so it can be overridden
/// in tests.
class ProcessRunner {
  /// Creates a new process runner.
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
    Directory? workingDir,
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
  /// Defaults to `false`.
  ///
  /// If [logOnError] is set to `true`, it will print a formatted message about the error.
  /// Defaults to `false`
  ///
  /// Returns the [io.ProcessResult] of the [executable].
  Future<io.ProcessResult> run(String executable, List<String> args,
      {Directory? workingDir,
      bool exitOnError = false,
      bool logOnError = false,
      Encoding stdoutEncoding = io.systemEncoding,
      Encoding stderrEncoding = io.systemEncoding}) async {
    final io.ProcessResult result = await io.Process.run(executable, args,
        workingDirectory: workingDir?.path,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding);
    if (result.exitCode != 0) {
      if (logOnError) {
        final String error =
            _getErrorString(executable, args, workingDir: workingDir);
        print('$error Stderr:\n${result.stdout}');
      }
      if (exitOnError) {
        throw ToolExit(result.exitCode);
      }
    }
    return result;
  }

  /// Starts the [executable] with [args].
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// Returns the started [io.Process].
  Future<io.Process> start(String executable, List<String> args,
      {Directory? workingDirectory}) async {
    final io.Process process = await io.Process.start(executable, args,
        workingDirectory: workingDirectory?.path);
    return process;
  }

  String _getErrorString(String executable, List<String> args,
      {Directory? workingDir}) {
    final String workdir = workingDir == null ? '' : ' in ${workingDir.path}';
    return 'ERROR: Unable to execute "$executable ${args.join(' ')}"$workdir.';
  }
}

/// Finding version of [package] that is published on pub.
class PubVersionFinder {
  /// Constructor.
  ///
  /// Note: you should manually close the [httpClient] when done using the finder.
  PubVersionFinder({this.pubHost = defaultPubHost, required this.httpClient});

  /// The default pub host to use.
  static const String defaultPubHost = 'https://pub.dev';

  /// The pub host url, defaults to `https://pub.dev`.
  final String pubHost;

  /// The http client.
  ///
  /// You should manually close this client when done using this finder.
  final http.Client httpClient;

  /// Get the package version on pub.
  Future<PubVersionFinderResponse> getPackageVersion(
      {required String package}) async {
    assert(package.isNotEmpty);
    final Uri pubHostUri = Uri.parse(pubHost);
    final Uri url = pubHostUri.replace(path: '/packages/$package.json');
    final http.Response response = await httpClient.get(url);

    if (response.statusCode == 404) {
      return PubVersionFinderResponse(
          versions: <Version>[],
          result: PubVersionFinderResult.noPackageFound,
          httpResponse: response);
    } else if (response.statusCode != 200) {
      return PubVersionFinderResponse(
          versions: <Version>[],
          result: PubVersionFinderResult.fail,
          httpResponse: response);
    }
    final List<Version> versions =
        (json.decode(response.body)['versions'] as List<dynamic>)
            .map<Version>((final dynamic versionString) =>
                Version.parse(versionString as String))
            .toList();

    return PubVersionFinderResponse(
        versions: versions,
        result: PubVersionFinderResult.success,
        httpResponse: response);
  }
}

/// Represents a response for [PubVersionFinder].
class PubVersionFinderResponse {
  /// Constructor.
  PubVersionFinderResponse(
      {required this.versions,
      required this.result,
      required this.httpResponse}) {
    if (versions.isNotEmpty) {
      versions.sort((Version a, Version b) {
        // TODO(cyanglaz): Think about how to handle pre-release version with [Version.prioritize].
        // https://github.com/flutter/flutter/issues/82222
        return b.compareTo(a);
      });
    }
  }

  /// The versions found in [PubVersionFinder].
  ///
  /// This is sorted by largest to smallest, so the first element in the list is the largest version.
  /// Might be `null` if the [result] is not [PubVersionFinderResult.success].
  final List<Version> versions;

  /// The result of the version finder.
  final PubVersionFinderResult result;

  /// The response object of the http request.
  final http.Response httpResponse;
}

/// An enum representing the result of [PubVersionFinder].
enum PubVersionFinderResult {
  /// The version finder successfully found a version.
  success,

  /// The version finder failed to find a valid version.
  ///
  /// This might due to http connection errors or user errors.
  fail,

  /// The version finder failed to locate the package.
  ///
  /// This indicates the package is new.
  noPackageFound,
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
  final String? baseSha;

  static bool _isPubspec(String file) {
    return file.trim().endsWith('pubspec.yaml');
  }

  /// Get a list of all the pubspec.yaml file that is changed.
  Future<List<String>> getChangedPubSpecs() async {
    return (await getChangedFiles()).where(_isPubspec).toList();
  }

  /// Get a list of all the changed files.
  Future<List<String>> getChangedFiles() async {
    final String baseSha = await _getBaseSha();
    final io.ProcessResult changedFilesCommand = await baseGitDir
        .runCommand(<String>['diff', '--name-only', baseSha, 'HEAD']);
    print('Determine diff with base sha: $baseSha');
    final String changedFilesStdout = changedFilesCommand.stdout.toString();
    if (changedFilesStdout.isEmpty) {
      return <String>[];
    }
    final List<String> changedFiles = changedFilesStdout.split('\n')
      ..removeWhere((String element) => element.isEmpty);
    return changedFiles.toList();
  }

  /// Get the package version specified in the pubspec file in `pubspecPath` and
  /// at the revision of `gitRef` (defaulting to the base if not provided).
  Future<Version?> getPackageVersion(String pubspecPath,
      {String? gitRef}) async {
    final String ref = gitRef ?? (await _getBaseSha());

    io.ProcessResult gitShow;
    try {
      gitShow =
          await baseGitDir.runCommand(<String>['show', '$ref:$pubspecPath']);
    } on io.ProcessException {
      return null;
    }
    final String fileContent = gitShow.stdout as String;
    final String? versionString = loadYaml(fileContent)['version'] as String?;
    return versionString == null ? null : Version.parse(versionString);
  }

  Future<String> _getBaseSha() async {
    if (baseSha != null && baseSha!.isNotEmpty) {
      return baseSha!;
    }

    io.ProcessResult baseShaFromMergeBase = await baseGitDir.runCommand(
        <String>['merge-base', '--fork-point', 'FETCH_HEAD', 'HEAD'],
        throwOnError: false);
    if (baseShaFromMergeBase.stderr != null ||
        baseShaFromMergeBase.stdout == null) {
      baseShaFromMergeBase = await baseGitDir
          .runCommand(<String>['merge-base', 'FETCH_HEAD', 'HEAD']);
    }
    return (baseShaFromMergeBase.stdout as String).trim();
  }
}
