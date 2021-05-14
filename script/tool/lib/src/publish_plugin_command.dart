// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

import 'common.dart';

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
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
    Print print = print,
    io.Stdin stdinput,
    GitDir gitDir,
  })  : _print = print,
        _stdin = stdinput ?? io.stdin,
        super(packagesDir, fileSystem,
            processRunner: processRunner, gitDir: gitDir) {
    argParser.addOption(
      _packageOption,
      help: 'The package to publish.'
          'If the package directory name is different than its pubspec.yaml name, then this should specify the directory.',
    );
    argParser.addMultiOption(_pubFlagsOption,
        help:
            'A list of options that will be forwarded on to pub. Separate multiple flags with commas.');
    argParser.addFlag(
      _tagReleaseOption,
      help: 'Whether or not to tag the release.',
      defaultsTo: true,
      negatable: true,
    );
    argParser.addFlag(
      _pushTagsOption,
      help:
          'Whether or not tags should be pushed to a remote after creation. Ignored if tag-release is false.',
      defaultsTo: true,
      negatable: true,
    );
    argParser.addOption(
      _remoteOption,
      help:
          'The name of the remote to push the tags to. Ignored if push-tags or tag-release is false.',
      // Flutter convention is to use "upstream" for the single source of truth, and "origin" for personal forks.
      defaultsTo: 'upstream',
    );
    argParser.addFlag(
      _allChangedFlag,
      help:
          'Release all plugins that contains pubspec changes at the current commit compares to the base-sha.\n'
          'The $_packageOption option is ignored if this is on.',
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
            'This command will add a `--force` flag to the `pub publish` command if it is not added with $_pubFlagsOption\n'
            'It also skips the y/n inputs when pushing tags to remote.\n',
        defaultsTo: false,
        negatable: true);
  }

  static const String _packageOption = 'package';
  static const String _tagReleaseOption = 'tag-release';
  static const String _pushTagsOption = 'push-tags';
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
      'Attempts to publish the given plugin and tag its release on GitHub.\n'
      'If running this on CI, an environment variable named $_pubCredentialName must be set to a String that represents the pub credential JSON.\n'
      'WARNING: Do not check in the content of pub credential JSON, it should only come from secure sources.';

  final Print _print;
  final io.Stdin _stdin;
  StreamSubscription<String> _stdinSubscription;

  @override
  Future<void> run() async {
    final String package = getStringArg(_packageOption);
    final bool publishAllChanged = getBoolArg(_allChangedFlag);
    if (package == null && !publishAllChanged) {
      _print(
          'Must specify a package to publish. See `plugin_tools help publish-plugin`.');
      throw ToolExit(1);
    }

    _print('Checking local repo...');
    if (!await GitDir.isGitDir(packagesDir.path)) {
      _print('$packagesDir is not a valid Git repository.');
      throw ToolExit(1);
    }
    final GitDir baseGitDir =
        await GitDir.fromExisting(packagesDir.path, allowSubdirectory: true);

    final bool shouldPushTag = getBoolArg(_pushTagsOption);
    final String remote = getStringArg(_remoteOption);
    String remoteUrl;
    if (shouldPushTag) {
      remoteUrl = await _verifyRemote(remote);
    }
    _print('Local repo is ready!');
    if (getBoolArg(_dryRunFlag)) {
      _print('===============  DRY RUN ===============');
    }

    bool successful;
    if (publishAllChanged) {
      successful = await _publishAllChangedPackages(
        remote: remote,
        remoteUrl: remoteUrl,
        shouldPushTag: shouldPushTag,
        baseGitDir: baseGitDir,
      );
    } else {
      successful = await _publishAndTagPackage(
        packageDir: _getPackageDir(package),
        remote: remote,
        remoteUrl: remoteUrl,
        shouldPushTag: shouldPushTag,
      );
    }
    await _finish(successful);
  }

  Future<bool> _publishAllChangedPackages({
    String remote,
    String remoteUrl,
    bool shouldPushTag,
    GitDir baseGitDir,
  }) async {
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final List<String> changedPubspecs =
        await gitVersionFinder.getChangedPubSpecs();
    if (changedPubspecs.isEmpty) {
      _print('No version updates in this commit.');
      return true;
    }
    _print('Getting existing tags...');
    final io.ProcessResult existingTagsResult =
        await baseGitDir.runCommand(<String>['tag', '--sort=-committerdate']);
    final List<String> existingTags = (existingTagsResult.stdout as String)
        .split('\n')
          ..removeWhere((String element) => element.isEmpty);

    final List<String> packagesReleased = <String>[];
    final List<String> packagesFailed = <String>[];

    for (final String pubspecPath in changedPubspecs) {
      final File pubspecFile =
          fileSystem.directory(baseGitDir.path).childFile(pubspecPath);
      final _CheckNeedsReleaseResult result = await _checkNeedsRelease(
        pubspecFile: pubspecFile,
        gitVersionFinder: gitVersionFinder,
        existingTags: existingTags,
      );
      switch (result) {
        case _CheckNeedsReleaseResult.release:
          break;
        case _CheckNeedsReleaseResult.noRelease:
          continue;
        case _CheckNeedsReleaseResult.failure:
          packagesFailed.add(pubspecFile.parent.basename);
          continue;
      }
      _print('\n');
      if (await _publishAndTagPackage(
        packageDir: pubspecFile.parent,
        remote: remote,
        remoteUrl: remoteUrl,
        shouldPushTag: shouldPushTag,
      )) {
        packagesReleased.add(pubspecFile.parent.basename);
      } else {
        packagesFailed.add(pubspecFile.parent.basename);
      }
      _print('\n');
    }
    if (packagesReleased.isNotEmpty) {
      _print('Packages released: ${packagesReleased.join(', ')}');
    }
    if (packagesFailed.isNotEmpty) {
      _print(
          'Failed to release the following packages: ${packagesFailed.join(', ')}, see above for details.');
    }
    return packagesFailed.isEmpty;
  }

  // Publish the package to pub with `pub publish`.
  // If `_tagReleaseOption` is on, git tag the release.
  // If `shouldPushTag` is `true`, the tag will be pushed to `remote`.
  // Returns `true` if publishing and tag are successful.
  Future<bool> _publishAndTagPackage({
    @required Directory packageDir,
    @required String remote,
    @required String remoteUrl,
    @required bool shouldPushTag,
  }) async {
    if (!await _publishPlugin(packageDir: packageDir)) {
      return false;
    }
    if (getBoolArg(_tagReleaseOption)) {
      if (!await _tagRelease(
        packageDir: packageDir,
        remote: remote,
        remoteUrl: remoteUrl,
        shouldPushTag: shouldPushTag,
      )) {
        return false;
      }
    }
    _print('Released [${packageDir.basename}] successfully.');
    return true;
  }

  // Returns a [_CheckNeedsReleaseResult] that indicates the result.
  Future<_CheckNeedsReleaseResult> _checkNeedsRelease({
    @required File pubspecFile,
    @required GitVersionFinder gitVersionFinder,
    @required List<String> existingTags,
  }) async {
    if (!pubspecFile.existsSync()) {
      _print('''
The file at The pubspec file at ${pubspecFile.path} does not exist. Publishing will not happen for ${pubspecFile.parent.basename}.
Safe to ignore if the package is deleted in this commit.
''');
      return _CheckNeedsReleaseResult.noRelease;
    }

    final Pubspec pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    if (pubspec.publishTo == 'none') {
      return _CheckNeedsReleaseResult.noRelease;
    }

    if (pubspec.version == null) {
      _print(
          'No version found. A package that intentionally has no version should be marked "publish_to: none"');
      return _CheckNeedsReleaseResult.failure;
    }

    if (pubspec.name == null) {
      _print('Fatal: Package name is null.');
      return _CheckNeedsReleaseResult.failure;
    }
    // Get latest tagged version and compare with the current version.
    // TODO(cyanglaz): Check latest version of the package on pub instead of git
    // https://github.com/flutter/flutter/issues/81047

    final String latestTag = existingTags.firstWhere(
        (String tag) => tag.split('-v').first == pubspec.name,
        orElse: () => '');
    if (latestTag.isNotEmpty) {
      final String latestTaggedVersion = latestTag.split('-v').last;
      final Version latestVersion = Version.parse(latestTaggedVersion);
      if (pubspec.version < latestVersion) {
        _print(
            'The new version (${pubspec.version}) is lower than the current version ($latestVersion) for ${pubspec.name}.\nThis git commit is a revert, no release is tagged.');
        return _CheckNeedsReleaseResult.noRelease;
      }
    }
    return _CheckNeedsReleaseResult.release;
  }

  // Publish the plugin.
  //
  // Returns `true` if successful, `false` otherwise.
  Future<bool> _publishPlugin({@required Directory packageDir}) async {
    final bool gitStatusOK = await _checkGitStatus(packageDir);
    if (!gitStatusOK) {
      return false;
    }
    final bool publishOK = await _publish(packageDir);
    if (!publishOK) {
      return false;
    }
    _print('Package published!');
    return true;
  }

  // Tag the release with <plugin-name>-v<version>
  //
  // Return `true` if successful, `false` otherwise.
  Future<bool> _tagRelease({
    @required Directory packageDir,
    @required String remote,
    @required String remoteUrl,
    @required bool shouldPushTag,
  }) async {
    final String tag = _getTag(packageDir);
    _print('Tagging release $tag...');
    if (!getBoolArg(_dryRunFlag)) {
      final io.ProcessResult result = await processRunner.run(
        'git',
        <String>['tag', tag],
        workingDir: packageDir,
        exitOnError: false,
        logOnError: true,
      );
      if (result.exitCode != 0) {
        return false;
      }
    }

    if (!shouldPushTag) {
      return true;
    }

    _print('Pushing tag to $remote...');
    return await _pushTagToRemote(
      remote: remote,
      tag: tag,
      remoteUrl: remoteUrl,
    );
  }

  Future<void> _finish(bool successful) async {
    if (_stdinSubscription != null) {
      await _stdinSubscription.cancel();
      _stdinSubscription = null;
    }
    if (successful) {
      _print('Done!');
    } else {
      _print('Failed, see above for details.');
      throw ToolExit(1);
    }
  }

  // Returns the packageDirectory based on the package name.
  // Throws ToolExit if the `package` doesn't exist.
  Directory _getPackageDir(String package) {
    final Directory packageDir = packagesDir.childDirectory(package);
    if (!packageDir.existsSync()) {
      _print('${packageDir.absolute.path} does not exist.');
      throw ToolExit(1);
    }
    return packageDir;
  }

  Future<bool> _checkGitStatus(Directory packageDir) async {
    final io.ProcessResult statusResult = await processRunner.run(
      'git',
      <String>['status', '--porcelain', '--ignored', packageDir.absolute.path],
      workingDir: packageDir,
      logOnError: true,
      exitOnError: false,
    );
    if (statusResult.exitCode != 0) {
      return false;
    }

    final String statusOutput = statusResult.stdout as String;
    if (statusOutput.isNotEmpty) {
      _print(
          "There are files in the package directory that haven't been saved in git. Refusing to publish these files:\n\n"
          '$statusOutput\n'
          'If the directory should be clean, you can run `git clean -xdf && git reset --hard HEAD` to wipe all local changes.');
    }
    return statusOutput.isEmpty;
  }

  Future<String> _verifyRemote(String remote) async {
    final io.ProcessResult remoteInfo = await processRunner.run(
      'git',
      <String>['remote', 'get-url', remote],
      workingDir: packagesDir,
      exitOnError: true,
      logOnError: true,
    );
    return remoteInfo.stdout as String;
  }

  Future<bool> _publish(Directory packageDir) async {
    final List<String> publishFlags = getStringListArg(_pubFlagsOption);
    _print(
        'Running `pub publish ${publishFlags.join(' ')}` in ${packageDir.absolute.path}...\n');
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
        'flutter', <String>['pub', 'publish'] + publishFlags,
        workingDirectory: packageDir);
    publish.stdout
        .transform(utf8.decoder)
        .listen((String data) => _print(data));
    publish.stderr
        .transform(utf8.decoder)
        .listen((String data) => _print(data));
    _stdinSubscription ??= _stdin
        .transform(utf8.decoder)
        .listen((String data) => publish.stdin.writeln(data));
    final int result = await publish.exitCode;
    if (result != 0) {
      _print('Publish ${packageDir.basename} failed.');
      return false;
    }
    return true;
  }

  String _getTag(Directory packageDir) {
    final File pubspecFile =
        fileSystem.file(p.join(packageDir.path, 'pubspec.yaml'));
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
    @required String remote,
    @required String tag,
    @required String remoteUrl,
  }) async {
    assert(remote != null && tag != null && remoteUrl != null);
    if (!getBoolArg(_skipConfirmationFlag)) {
      _print('Ready to push $tag to $remoteUrl (y/n)?');
      final String input = _stdin.readLineSync();
      if (input.toLowerCase() != 'y') {
        _print('Tag push canceled.');
        return false;
      }
    }
    if (!getBoolArg(_dryRunFlag)) {
      final io.ProcessResult result = await processRunner.run(
        'git',
        <String>['push', remote, tag],
        workingDir: packagesDir,
        exitOnError: false,
        logOnError: true,
      );
      if (result.exitCode != 0) {
        return false;
      }
    }
    return true;
  }

  void _ensureValidPubCredential() {
    final File credentialFile = fileSystem.file(_credentialsPath);
    if (credentialFile.existsSync() &&
        credentialFile.readAsStringSync().isNotEmpty) {
      return;
    }
    final String credential = io.Platform.environment[_pubCredentialName];
    if (credential == null) {
      printErrorAndExit(errorMessage: '''
No pub credential available. Please check if `~/.pub-cache/credentials.json` is valid.
If running this command on CI, you can set the pub credential content in the $_pubCredentialName environment variable.
''');
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
  String cacheDir;
  final String pubCache = io.Platform.environment['PUB_CACHE'];
  print(pubCache);
  if (pubCache != null) {
    cacheDir = pubCache;
  } else if (io.Platform.isWindows) {
    final String appData = io.Platform.environment['APPDATA'];
    cacheDir = p.join(appData, 'Pub', 'Cache');
  } else {
    cacheDir = p.join(io.Platform.environment['HOME'], '.pub-cache');
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
