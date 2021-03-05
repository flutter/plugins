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
      _allFlag,
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
  }

  static const String _packageOption = 'package';
  static const String _tagReleaseOption = 'tag-release';
  static const String _pushTagsOption = 'push-tags';
  static const String _pubFlagsOption = 'pub-publish-flags';
  static const String _remoteOption = 'remote';
  static const String _allFlag = 'all';
  static const String _dryRunFlag = 'dry-run';

  // Version tags should follow <package-name>-v<semantic-version>. For example,
  // `flutter_plugin_tools-v0.0.24`.
  static const String _tagFormat = '%PACKAGE%-v%VERSION%';

  @override
  final String name = 'publish-plugin';

  @override
  final String description =
      'Attempts to publish the given plugin and tag its release on GitHub.';

  final Print _print;
  final io.Stdin _stdin;
  StreamSubscription<String> _stdinSubscription;
  bool _startedListenToStdStream = false;

  @override
  Future<void> run() async {
    final String package = argResults[_packageOption] as String;
    final bool all = argResults[_allFlag] as bool;
    if (package == null && !all) {
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

    final bool shouldPushTag = argResults[_pushTagsOption] == true;
    final String remote = argResults[_remoteOption] as String;
    String remoteUrl;
    if (shouldPushTag) {
      remoteUrl = await _verifyRemote(remote);
    }
    _print('Local repo is ready!');

    if (all) {
      await _publishAllPackages(
          remote: remote,
          remoteUrl: remoteUrl,
          shouldPushTag: shouldPushTag,
          baseGitDir: baseGitDir);
    } else {
      await _publishAndReleasePackage(
          packageDir: _getPackageDir(package),
          remote: remote,
          remoteUrl: remoteUrl,
          shouldPushTag: shouldPushTag);
    }
    await _finishSuccesfully();
  }

  Future<void> _publishAllPackages(
      {String remote,
      String remoteUrl,
      bool shouldPushTag,
      GitDir baseGitDir}) async {
    final List<String> packagesReleased = <String>[];
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final List<String> changedPubspecs =
        await gitVersionFinder.getChangedPubSpecs();
    if (changedPubspecs.isEmpty) {
      _print('No version updates in this commit, exiting...');
      return;
    }
    _print('Getting existing tags...');
    final io.ProcessResult existingTagsResult =
        await baseGitDir.runCommand(<String>['tag', '--sort=-committerdate']);
    final List<String> existingTags = (existingTagsResult.stdout as String)
        .split('\n')
          ..removeWhere((element) => element == '');
    for (final String pubspecPath in changedPubspecs) {
      final File pubspecFile =
          fileSystem.directory(baseGitDir.path).childFile(pubspecPath);
      if (!pubspecFile.existsSync()) {
        printErrorAndExit(
            errorMessage:
                'Fatal: The pubspec file at ${pubspecFile.path} does not exist.');
      }
      final bool needsRelease = await _checkNeedsRelease(
          pubspecPath: pubspecPath,
          pubspecFile: pubspecFile,
          gitVersionFinder: gitVersionFinder,
          existingTags: existingTags);
      if (!needsRelease) {
        continue;
      }
      _print('\n');
      await _publishAndReleasePackage(
          packageDir: pubspecFile.parent,
          remote: remote,
          remoteUrl: remoteUrl,
          shouldPushTag: shouldPushTag);
      packagesReleased.add(pubspecFile.parent.basename);
      _print('\n');
    }
    _print('Packages released: ${packagesReleased.join(', ')}');
  }

  Future<void> _publishAndReleasePackage(
      {@required Directory packageDir,
      @required String remote,
      @required String remoteUrl,
      @required bool shouldPushTag}) async {
    await _publishPlugin(packageDir: packageDir);
    if (argResults[_tagReleaseOption] as bool) {
      await _tagRelease(
          packageDir: packageDir,
          remote: remote,
          remoteUrl: remoteUrl,
          shouldPushTag: shouldPushTag);
    }
    _print('Release ${packageDir.basename} successful.');
  }

  // Returns `true` if needs to release the version, `false` if needs to skip
  Future<bool> _checkNeedsRelease({
    @required String pubspecPath,
    @required File pubspecFile,
    @required GitVersionFinder gitVersionFinder,
    @required List<String> existingTags,
  }) async {
    final Pubspec pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    if (pubspec.publishTo == 'none') {
      return false;
    }

    final Version headVersion =
        await gitVersionFinder.getPackageVersion(pubspecPath, gitRef: 'HEAD');
    if (headVersion == null) {
      printErrorAndExit(
          errorMessage: 'No version found. A package that '
              'intentionally has no version should be marked '
              '"publish_to: none".');
    }

    if (pubspec.name == null) {
      printErrorAndExit(errorMessage: 'Fatal: Package name is null.');
    }
    // Get latest tagged version and compare with the current version.
    final String latestTag = existingTags.isNotEmpty
        ? existingTags
            .firstWhere((String tag) => tag.split('-v').first == pubspec.name)
        : '';
    if (latestTag.isNotEmpty) {
      final String latestTaggedVersion = latestTag.split('-v').last;
      final Version latestVersion = Version.parse(latestTaggedVersion);
      if (pubspec.version < latestVersion) {
        _print(
            'The new version (${pubspec.version}) is lower than the current version ($latestVersion) for ${pubspec.name}.\nThis git commit is a revert, no release is tagged.');
        return false;
      }
    }
    return true;
  }

  Future<void> _publishPlugin({@required Directory packageDir}) async {
    await _checkGitStatus(packageDir);
    await _publish(packageDir);
    _print('Package published!');
  }

  Future<void> _tagRelease(
      {@required Directory packageDir,
      @required String remote,
      @required String remoteUrl,
      @required bool shouldPushTag}) async {
    final String tag = _getTag(packageDir);
    if (argResults[_dryRunFlag] as bool) {
      _print('DRY RUN: Tagging release $tag...');
      if (!shouldPushTag) {
        return;
      }
      _print('DRY RUN: Pushing tag to $remote...');
      return;
    }
    _print('Tagging release $tag...');
    await processRunner.runAndExitOnError('git', <String>['tag', tag],
        workingDir: packageDir);
    if (!shouldPushTag) {
      return;
    }

    _print('Pushing tag to $remote...');
    await _pushTagToRemote(remote: remote, tag: tag, remoteUrl: remoteUrl);
  }

  Future<void> _finishSuccesfully() async {
    if (_stdinSubscription != null) {
      await _stdinSubscription.cancel();
    }
    _print('Done!');
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

  Future<void> _checkGitStatus(Directory packageDir) async {
    final io.ProcessResult statusResult = await processRunner.runAndExitOnError(
        'git',
        <String>[
          'status',
          '--porcelain',
          '--ignored',
          packageDir.absolute.path
        ],
        workingDir: packageDir);

    final String statusOutput = statusResult.stdout as String;
    if (statusOutput.isNotEmpty) {
      _print(
          "There are files in the package directory that haven't been saved in git. Refusing to publish these files:\n\n"
          '$statusOutput\n'
          'If the directory should be clean, you can run `git clean -xdf && git reset --hard HEAD` to wipe all local changes.');
      throw ToolExit(1);
    }
  }

  Future<String> _verifyRemote(String remote) async {
    final io.ProcessResult remoteInfo = await processRunner.runAndExitOnError(
        'git', <String>['remote', 'get-url', remote],
        workingDir: packagesDir);
    return remoteInfo.stdout as String;
  }

  Future<void> _publish(Directory packageDir) async {
    final List<String> publishFlags =
        argResults[_pubFlagsOption] as List<String>;
    if (argResults[_dryRunFlag] as bool) {
      _print(
          'DRY RUN: Running `pub publish ${publishFlags.join(' ')}` in ${packageDir.absolute.path}...\n');
      return;
    }

    _print(
        'Running `pub publish ${publishFlags.join(' ')}` in ${packageDir.absolute.path}...\n');
    final io.Process publish = await processRunner.start(
        'flutter', <String>['pub', 'publish'] + publishFlags,
        workingDirectory: packageDir);

    if (!_startedListenToStdStream) {
      publish.stdout
          .transform(utf8.decoder)
          .listen((String data) => _print(data));
      publish.stderr
          .transform(utf8.decoder)
          .listen((String data) => _print(data));
      _stdinSubscription = _stdin
          .transform(utf8.decoder)
          .listen((String data) => publish.stdin.writeln(data));

      _startedListenToStdStream = true;
    }
    final int result = await publish.exitCode;
    if (result != 0) {
      _print('Publish failed. Exiting.');
      throw ToolExit(result);
    }
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

  Future<void> _pushTagToRemote(
      {@required String remote,
      @required String tag,
      @required String remoteUrl}) async {
    assert(remote != null && tag != null && remoteUrl != null);
    _print('Ready to push $tag to $remoteUrl (y/n)?');
    final String input = _stdin.readLineSync();
    if (input.toLowerCase() != 'y') {
      _print('Tag push canceled.');
      throw ToolExit(1);
    }
    await processRunner.runAndExitOnError('git', <String>['push', remote, tag],
        workingDir: packagesDir);
  }
}
