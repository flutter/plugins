// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/plugin_command.dart';
import 'common/process_runner.dart';
import 'common/pub_version_finder.dart';

@immutable
class _RemoteInfo {
  const _RemoteInfo({required this.name, required this.url});

  /// The git name for the remote.
  final String name;

  /// The remote's URL.
  final String url;
}

/// Wraps pub publish with a few niceties used by the flutter/plugin team.
///
/// 1. Checks for any modified files in git and refuses to publish if there's an
///    issue.
/// 2. Tags the release with the format <package-name>-v<package-version>.
/// 3. Pushes the release to a remote.
///
/// Both 2 and 3 are optional, see `plugin_tools help publish-plugin` for full
/// usage information.
///
/// [processRunner], [print], and [stdin] can be overriden for easier testing.
class PublishPluginCommand extends PluginCommand {
  /// Creates an instance of the publish command.
  PublishPluginCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
    io.Stdin? stdinput,
    GitDir? gitDir,
    http.Client? httpClient,
  })  : _pubVersionFinder =
            PubVersionFinder(httpClient: httpClient ?? http.Client()),
        _stdin = stdinput ?? io.stdin,
        super(packagesDir,
            platform: platform, processRunner: processRunner, gitDir: gitDir) {
    argParser.addMultiOption(_pubFlagsOption,
        help:
            'A list of options that will be forwarded on to pub. Separate multiple flags with commas.');
    argParser.addOption(
      _remoteOption,
      help: 'The name of the remote to push the tags to.',
      // Flutter convention is to use "upstream" for the single source of truth, and "origin" for personal forks.
      defaultsTo: 'upstream',
    );
    argParser.addFlag(
      _allChangedFlag,
      help:
          'Release all packages that contains pubspec changes at the current commit compares to the base-sha.\n'
          'The --packages option is ignored if this is on.',
      defaultsTo: false,
    );
    argParser.addFlag(
      _dryRunFlag,
      help:
          'Skips the real `pub publish` and `git tag` commands and assumes both commands are successful.\n'
          'This does not run `pub publish --dry-run`.\n'
          'If you want to run the command with `pub publish --dry-run`, use `pub-publish-flags=--dry-run`',
      defaultsTo: false,
      negatable: true,
    );
    argParser.addFlag(_skipConfirmationFlag,
        help: 'Run the command without asking for Y/N inputs.\n'
            'This command will add a `--force` flag to the `pub publish` command if it is not added with $_pubFlagsOption\n',
        defaultsTo: false,
        negatable: true);
  }

  static const String _pubFlagsOption = 'pub-publish-flags';
  static const String _remoteOption = 'remote';
  static const String _allChangedFlag = 'all-changed';
  static const String _dryRunFlag = 'dry-run';
  static const String _skipConfirmationFlag = 'skip-confirmation';

  static const String _pubCredentialName = 'PUB_CREDENTIALS';

  // Version tags should follow <package-name>-v<semantic-version>. For example,
  // `flutter_plugin_tools-v0.0.24`.
  static const String _tagFormat = '%PACKAGE%-v%VERSION%';

  @override
  final String name = 'publish-plugin';

  @override
  final String description =
      'Attempts to publish the given packages and tag the release(s) on GitHub.\n'
      'If running this on CI, an environment variable named $_pubCredentialName must be set to a String that represents the pub credential JSON.\n'
      'WARNING: Do not check in the content of pub credential JSON, it should only come from secure sources.';

  final io.Stdin _stdin;
  StreamSubscription<String>? _stdinSubscription;
  final PubVersionFinder _pubVersionFinder;

  @override
  Future<void> run() async {
    print('Checking local repo...');
    final GitDir repository = await gitDir;
    final String remoteName = getStringArg(_remoteOption);
    final String? remoteUrl = await _verifyRemote(remoteName);
    if (remoteUrl == null) {
      printError('Unable to find URL for remote $remoteName; cannot push tags');
      throw ToolExit(1);
    }
    final _RemoteInfo remote = _RemoteInfo(name: remoteName, url: remoteUrl);

    print('Local repo is ready!');
    if (getBoolArg(_dryRunFlag)) {
      print('===============  DRY RUN ===============');
    }

    final List<PackageEnumerationEntry> packages = await _getPackagesToProcess()
        .where((PackageEnumerationEntry entry) => !entry.excluded)
        .toList();
    bool successful = true;

    successful = await _publishPackages(
      packages,
      baseGitDir: repository,
      remoteForTagPush: remote,
    );

    await _finish(successful);
  }

  Stream<PackageEnumerationEntry> _getPackagesToProcess() async* {
    if (getBoolArg(_allChangedFlag)) {
      final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
      final List<String> changedPubspecs =
          await gitVersionFinder.getChangedPubSpecs();

      for (final String pubspecPath in changedPubspecs) {
        // Convert git's Posix-style paths to a path that matches the current
        // filesystem.
        final String localStylePubspecPath =
            path.joinAll(p.posix.split(pubspecPath));
        final File pubspecFile = packagesDir.fileSystem
            .directory((await gitDir).path)
            .childFile(localStylePubspecPath);
        yield PackageEnumerationEntry(RepositoryPackage(pubspecFile.parent),
            excluded: false);
      }
    } else {
      yield* getTargetPackages(filterExcluded: false);
    }
  }

  Future<bool> _publishPackages(
    List<PackageEnumerationEntry> packages, {
    required GitDir baseGitDir,
    required _RemoteInfo remoteForTagPush,
  }) async {
    if (packages.isEmpty) {
      print('No version updates in this commit.');
      return true;
    }

    final io.ProcessResult existingTagsResult =
        await baseGitDir.runCommand(<String>['tag', '--sort=-committerdate']);
    final List<String> existingTags = (existingTagsResult.stdout as String)
        .split('\n')
      ..removeWhere((String element) => element.isEmpty);

    final List<String> packagesReleased = <String>[];
    final List<String> packagesFailed = <String>[];

    for (final PackageEnumerationEntry entry in packages) {
      final RepositoryPackage package = entry.package;

      final _CheckNeedsReleaseResult result = await _checkNeedsRelease(
        package: package,
        existingTags: existingTags,
      );
      switch (result) {
        case _CheckNeedsReleaseResult.release:
          break;
        case _CheckNeedsReleaseResult.noRelease:
          continue;
        case _CheckNeedsReleaseResult.failure:
          packagesFailed.add(package.displayName);
          continue;
      }
      print('\n');
      if (await _publishAndTagPackage(package,
          remoteForTagPush: remoteForTagPush)) {
        packagesReleased.add(package.displayName);
      } else {
        packagesFailed.add(package.displayName);
      }
      print('\n');
    }
    if (packagesReleased.isNotEmpty) {
      print('Packages released: ${packagesReleased.join(', ')}');
    }
    if (packagesFailed.isNotEmpty) {
      printError(
          'Failed to release the following packages: ${packagesFailed.join(', ')}, see above for details.');
    }
    return packagesFailed.isEmpty;
  }

  // Publish the package to pub with `pub publish`, then git tag the release
  // and push the tag to [remoteForTagPush].
  // Returns `true` if publishing and tagging are successful.
  Future<bool> _publishAndTagPackage(
    RepositoryPackage package, {
    _RemoteInfo? remoteForTagPush,
  }) async {
    if (!await _publishPackage(package)) {
      return false;
    }
    if (!await _tagRelease(
      package,
      remoteForPush: remoteForTagPush,
    )) {
      return false;
    }
    print('Published ${package.directory.basename} successfully.');
    return true;
  }

  // Returns a [_CheckNeedsReleaseResult] that indicates the result.
  Future<_CheckNeedsReleaseResult> _checkNeedsRelease({
    required RepositoryPackage package,
    required List<String> existingTags,
  }) async {
    final File pubspecFile = package.pubspecFile;
    if (!pubspecFile.existsSync()) {
      print('''
The pubspec file at ${pubspecFile.path} does not exist. Publishing will not happen for ${pubspecFile.parent.basename}.
Safe to ignore if the package is deleted in this commit.
''');
      return _CheckNeedsReleaseResult.noRelease;
    }

    final Pubspec pubspec = Pubspec.parse(pubspecFile.readAsStringSync());

    if (pubspec.name == 'flutter_plugin_tools') {
      // Ignore flutter_plugin_tools package when running publishing through flutter_plugin_tools.
      // TODO(cyanglaz): Make the tool also auto publish flutter_plugin_tools package.
      // https://github.com/flutter/flutter/issues/85430
      return _CheckNeedsReleaseResult.noRelease;
    }

    if (pubspec.publishTo == 'none') {
      return _CheckNeedsReleaseResult.noRelease;
    }

    if (pubspec.version == null) {
      printError(
          'No version found. A package that intentionally has no version should be marked "publish_to: none"');
      return _CheckNeedsReleaseResult.failure;
    }

    // Check if the package named `packageName` with `version` has already
    // been published.
    final Version version = pubspec.version!;
    final PubVersionFinderResponse pubVersionFinderResponse =
        await _pubVersionFinder.getPackageVersion(packageName: pubspec.name);
    if (pubVersionFinderResponse.versions.contains(version)) {
      final String tagsForPackageWithSameVersion = existingTags.firstWhere(
          (String tag) =>
              tag.split('-v').first == pubspec.name &&
              tag.split('-v').last == version.toString(),
          orElse: () => '');
      print(
          'The version $version of ${pubspec.name} has already been published');
      if (tagsForPackageWithSameVersion.isEmpty) {
        printError(
            'However, the git release tag for this version (${pubspec.name}-v$version) is not found. Please manually fix the tag then run the command again.');
        return _CheckNeedsReleaseResult.failure;
      } else {
        print('skip.');
        return _CheckNeedsReleaseResult.noRelease;
      }
    }
    return _CheckNeedsReleaseResult.release;
  }

  // Publish the package.
  //
  // Returns `true` if successful, `false` otherwise.
  Future<bool> _publishPackage(RepositoryPackage package) async {
    final bool gitStatusOK = await _checkGitStatus(package);
    if (!gitStatusOK) {
      return false;
    }
    final bool publishOK = await _publish(package);
    if (!publishOK) {
      return false;
    }
    print('Package published!');
    return true;
  }

  // Tag the release with <package-name>-v<version>, and, if [remoteForTagPush]
  // is provided, push it to that remote.
  //
  // Return `true` if successful, `false` otherwise.
  Future<bool> _tagRelease(
    RepositoryPackage package, {
    _RemoteInfo? remoteForPush,
  }) async {
    final String tag = _getTag(package);
    print('Tagging release $tag...');
    if (!getBoolArg(_dryRunFlag)) {
      final io.ProcessResult result = await (await gitDir).runCommand(
        <String>['tag', tag],
        throwOnError: false,
      );
      if (result.exitCode != 0) {
        return false;
      }
    }

    if (remoteForPush == null) {
      return true;
    }

    print('Pushing tag to ${remoteForPush.name}...');
    return await _pushTagToRemote(
      tag: tag,
      remote: remoteForPush,
    );
  }

  Future<void> _finish(bool successful) async {
    _pubVersionFinder.httpClient.close();
    await _stdinSubscription?.cancel();
    _stdinSubscription = null;
    if (successful) {
      print('Done!');
    } else {
      printError('Failed, see above for details.');
      throw ToolExit(1);
    }
  }

  Future<bool> _checkGitStatus(RepositoryPackage package) async {
    final io.ProcessResult statusResult = await (await gitDir).runCommand(
      <String>[
        'status',
        '--porcelain',
        '--ignored',
        package.directory.absolute.path
      ],
      throwOnError: false,
    );
    if (statusResult.exitCode != 0) {
      return false;
    }

    final String statusOutput = statusResult.stdout as String;
    if (statusOutput.isNotEmpty) {
      printError(
          "There are files in the package directory that haven't been saved in git. Refusing to publish these files:\n\n"
          '$statusOutput\n'
          'If the directory should be clean, you can run `git clean -xdf && git reset --hard HEAD` to wipe all local changes.');
    }
    return statusOutput.isEmpty;
  }

  Future<String?> _verifyRemote(String remote) async {
    final io.ProcessResult getRemoteUrlResult = await (await gitDir).runCommand(
      <String>['remote', 'get-url', remote],
      throwOnError: false,
    );
    if (getRemoteUrlResult.exitCode != 0) {
      return null;
    }
    return getRemoteUrlResult.stdout as String?;
  }

  Future<bool> _publish(RepositoryPackage package) async {
    final List<String> publishFlags = getStringListArg(_pubFlagsOption);
    print('Running `pub publish ${publishFlags.join(' ')}` in '
        '${package.directory.absolute.path}...\n');
    if (getBoolArg(_dryRunFlag)) {
      return true;
    }

    if (getBoolArg(_skipConfirmationFlag)) {
      publishFlags.add('--force');
    }
    if (publishFlags.contains('--force')) {
      _ensureValidPubCredential();
    }

    final io.Process publish = await processRunner.start(
        flutterCommand, <String>['pub', 'publish'] + publishFlags,
        workingDirectory: package.directory);
    publish.stdout.transform(utf8.decoder).listen((String data) => print(data));
    publish.stderr.transform(utf8.decoder).listen((String data) => print(data));
    _stdinSubscription ??= _stdin
        .transform(utf8.decoder)
        .listen((String data) => publish.stdin.writeln(data));
    final int result = await publish.exitCode;
    if (result != 0) {
      printError('Publishing ${package.directory.basename} failed.');
      return false;
    }
    return true;
  }

  String _getTag(RepositoryPackage package) {
    final File pubspecFile = package.pubspecFile;
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final String name = pubspecYaml['name'] as String;
    final String version = pubspecYaml['version'] as String;
    // We should have failed to publish if these were unset.
    assert(name.isNotEmpty && version.isNotEmpty);
    return _tagFormat
        .replaceAll('%PACKAGE%', name)
        .replaceAll('%VERSION%', version);
  }

  // Pushes the `tag` to `remote`
  //
  // Return `true` if successful, `false` otherwise.
  Future<bool> _pushTagToRemote({
    required String tag,
    required _RemoteInfo remote,
  }) async {
    assert(remote != null && tag != null);
    if (!getBoolArg(_dryRunFlag)) {
      final io.ProcessResult result = await (await gitDir).runCommand(
        <String>['push', remote.name, tag],
        throwOnError: false,
      );
      if (result.exitCode != 0) {
        return false;
      }
    }
    return true;
  }

  void _ensureValidPubCredential() {
    final String credentialsPath = _credentialsPath;
    final File credentialFile = packagesDir.fileSystem.file(credentialsPath);
    if (credentialFile.existsSync() &&
        credentialFile.readAsStringSync().isNotEmpty) {
      return;
    }
    final String? credential = io.Platform.environment[_pubCredentialName];
    if (credential == null) {
      printError('''
No pub credential available. Please check if `$credentialsPath` is valid.
If running this command on CI, you can set the pub credential content in the $_pubCredentialName environment variable.
''');
      throw ToolExit(1);
    }
    credentialFile.openSync(mode: FileMode.writeOnlyAppend)
      ..writeStringSync(credential)
      ..closeSync();
  }

  /// Returns the correct path where the pub credential is stored.
  @visibleForTesting
  static String getCredentialPath() {
    return _credentialsPath;
  }
}

/// The path in which pub expects to find its credentials file.
final String _credentialsPath = () {
  // This follows the same logic as pub:
  // https://github.com/dart-lang/pub/blob/d99b0d58f4059d7bb4ac4616fd3d54ec00a2b5d4/lib/src/system_cache.dart#L34-L43
  String? cacheDir;
  final String? pubCache = io.Platform.environment['PUB_CACHE'];
  print(pubCache);
  if (pubCache != null) {
    cacheDir = pubCache;
  } else if (io.Platform.isWindows) {
    final String? appData = io.Platform.environment['APPDATA'];
    if (appData == null) {
      printError('"APPDATA" environment variable is not set.');
    } else {
      cacheDir = p.join(appData, 'Pub', 'Cache');
    }
  } else {
    final String? home = io.Platform.environment['HOME'];
    if (home == null) {
      printError('"HOME" environment variable is not set.');
    } else {
      cacheDir = p.join(home, '.pub-cache');
    }
  }

  if (cacheDir == null) {
    printError('Unable to determine pub cache location');
    throw ToolExit(1);
  }

  return p.join(cacheDir, 'credentials.json');
}();

enum _CheckNeedsReleaseResult {
  // The package needs to be released.
  release,

  // The package does not need to be released.
  noRelease,

  // There's an error when trying to determine whether the package needs to be released.
  failure,
}
