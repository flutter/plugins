// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/pub_version_finder.dart';
import 'common/repository_package.dart';

const int _exitMissingChangeDescriptionFile = 3;

/// Categories of version change types.
enum NextVersionType {
  /// A breaking change.
  BREAKING_MAJOR,

  /// A minor change (e.g., added feature).
  MINOR,

  /// A bugfix change.
  PATCH,

  /// The release of an existing prerelease version.
  RELEASE,
}

/// The state of a package's version relative to the comparison base.
enum _CurrentVersionState {
  /// The version is unchanged.
  unchanged,

  /// The version has changed, and the transition is valid.
  validChange,

  /// The version has changed, and the transition is invalid.
  invalidChange,

  /// There was an error determining the version state.
  unknown,
}

/// Returns the set of allowed next versions, with their change type, for
/// [version].
///
/// [newVersion] is used to check whether this is a pre-1.0 version bump, as
/// those have different semver rules.
@visibleForTesting
Map<Version, NextVersionType> getAllowedNextVersions(
  Version version, {
  required Version newVersion,
}) {
  final Map<Version, NextVersionType> allowedNextVersions =
      <Version, NextVersionType>{
    version.nextMajor: NextVersionType.BREAKING_MAJOR,
    version.nextMinor: NextVersionType.MINOR,
    version.nextPatch: NextVersionType.PATCH,
  };

  if (version.major < 1 && newVersion.major < 1) {
    int nextBuildNumber = -1;
    if (version.build.isEmpty) {
      nextBuildNumber = 1;
    } else {
      final int currentBuildNumber = version.build.first as int;
      nextBuildNumber = currentBuildNumber + 1;
    }
    final Version preReleaseVersion = Version(
      version.major,
      version.minor,
      version.patch,
      build: nextBuildNumber.toString(),
    );
    allowedNextVersions.clear();
    allowedNextVersions[version.nextMajor] = NextVersionType.RELEASE;
    allowedNextVersions[version.nextMinor] = NextVersionType.BREAKING_MAJOR;
    allowedNextVersions[version.nextPatch] = NextVersionType.MINOR;
    allowedNextVersions[preReleaseVersion] = NextVersionType.PATCH;
  }
  return allowedNextVersions;
}

/// A command to validate version changes to packages.
class VersionCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the version check command.
  VersionCheckCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
    GitDir? gitDir,
    http.Client? httpClient,
  })  : _pubVersionFinder =
            PubVersionFinder(httpClient: httpClient ?? http.Client()),
        super(
          packagesDir,
          processRunner: processRunner,
          platform: platform,
          gitDir: gitDir,
        ) {
    argParser.addFlag(
      _againstPubFlag,
      help: 'Whether the version check should run against the version on pub.\n'
          'Defaults to false, which means the version check only run against '
          'the previous version in code.',
      defaultsTo: false,
      negatable: true,
    );
    argParser.addOption(_changeDescriptionFile,
        help: 'The path to a file containing the description of the change '
            '(e.g., PR description or commit message).\n\n'
            'If supplied, this is used to allow overrides to some version '
            'checks.');
    argParser.addFlag(_ignorePlatformInterfaceBreaks,
        help: 'Bypasses the check that platform interfaces do not contain '
            'breaking changes.\n\n'
            'This is only intended for use in post-submit CI checks, to '
            'prevent the possibility of post-submit breakage if a change '
            'description justification is not transferred into the commit '
            'message. Pre-submit checks should always use '
            '--$_changeDescriptionFile instead.',
        hide: true);
  }

  static const String _againstPubFlag = 'against-pub';
  static const String _changeDescriptionFile = 'change-description-file';
  static const String _ignorePlatformInterfaceBreaks =
      'ignore-platform-interface-breaks';

  /// The string that must be in [_changeDescriptionFile] to allow a breaking
  /// change to a platform interface.
  static const String _breakingChangeJustificationMarker =
      '## Breaking change justification';

  final PubVersionFinder _pubVersionFinder;

  @override
  final String name = 'version-check';

  @override
  final String description =
      'Checks if the versions of the plugins have been incremented per pub specification.\n'
      'Also checks if the latest version in CHANGELOG matches the version in pubspec.\n\n'
      'This command requires "pub" and "flutter" to be in your path.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<void> initializeRun() async {}

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final Pubspec? pubspec = _tryParsePubspec(package);
    if (pubspec == null) {
      // No remaining checks make sense, so fail immediately.
      return PackageResult.fail(<String>['Invalid pubspec.yaml.']);
    }

    if (pubspec.publishTo == 'none') {
      return PackageResult.skip('Found "publish_to: none".');
    }

    final Version? currentPubspecVersion = pubspec.version;
    if (currentPubspecVersion == null) {
      printError('${indentation}No version found in pubspec.yaml. A package '
          'that intentionally has no version should be marked '
          '"publish_to: none".');
      // No remaining checks make sense, so fail immediately.
      return PackageResult.fail(<String>['No pubspec.yaml version.']);
    }

    final List<String> errors = <String>[];

    bool versionChanged;
    final _CurrentVersionState versionState =
        await _getVersionState(package, pubspec: pubspec);
    switch (versionState) {
      case _CurrentVersionState.unchanged:
        versionChanged = false;
        break;
      case _CurrentVersionState.validChange:
        versionChanged = true;
        break;
      case _CurrentVersionState.invalidChange:
        versionChanged = true;
        errors.add('Disallowed version change.');
        break;
      case _CurrentVersionState.unknown:
        versionChanged = false;
        errors.add('Unable to determine previous version.');
        break;
    }

    if (!(await _validateChangelogVersion(package,
        pubspec: pubspec, pubspecVersionChanged: versionChanged))) {
      errors.add('CHANGELOG.md failed validation.');
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  @override
  Future<void> completeRun() async {
    _pubVersionFinder.httpClient.close();
  }

  /// Returns the previous published version of [package].
  ///
  /// [packageName] must be the actual name of the package as published (i.e.,
  /// the name from pubspec.yaml, not the on disk name if different.)
  Future<Version?> _fetchPreviousVersionFromPub(String packageName) async {
    final PubVersionFinderResponse pubVersionFinderResponse =
        await _pubVersionFinder.getPackageVersion(packageName: packageName);
    switch (pubVersionFinderResponse.result) {
      case PubVersionFinderResult.success:
        return pubVersionFinderResponse.versions.first;
      case PubVersionFinderResult.fail:
        printError('''
${indentation}Error fetching version on pub for $packageName.
${indentation}HTTP Status ${pubVersionFinderResponse.httpResponse.statusCode}
${indentation}HTTP response: ${pubVersionFinderResponse.httpResponse.body}
''');
        return null;
      case PubVersionFinderResult.noPackageFound:
        return Version.none;
    }
  }

  /// Returns the version of [package] from git at the base comparison hash.
  Future<Version?> _getPreviousVersionFromGit(
    RepositoryPackage package, {
    required GitVersionFinder gitVersionFinder,
  }) async {
    final File pubspecFile = package.pubspecFile;
    final String relativePath =
        path.relative(pubspecFile.absolute.path, from: (await gitDir).path);
    // Use Posix-style paths for git.
    final String gitPath = path.style == p.Style.windows
        ? p.posix.joinAll(path.split(relativePath))
        : relativePath;
    return await gitVersionFinder.getPackageVersion(gitPath);
  }

  /// Returns the state of the verison of [package] relative to the comparison
  /// base (git or pub, depending on flags).
  Future<_CurrentVersionState> _getVersionState(
    RepositoryPackage package, {
    required Pubspec pubspec,
  }) async {
    // This method isn't called unless `version` is non-null.
    final Version currentVersion = pubspec.version!;
    Version? previousVersion;
    if (getBoolArg(_againstPubFlag)) {
      previousVersion = await _fetchPreviousVersionFromPub(pubspec.name);
      if (previousVersion == null) {
        return _CurrentVersionState.unknown;
      }
      if (previousVersion != Version.none) {
        print(
            '$indentation${pubspec.name}: Current largest version on pub: $previousVersion');
      }
    } else {
      final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
      previousVersion = await _getPreviousVersionFromGit(package,
              gitVersionFinder: gitVersionFinder) ??
          Version.none;
    }
    if (previousVersion == Version.none) {
      print('${indentation}Unable to find previous version '
          '${getBoolArg(_againstPubFlag) ? 'on pub server' : 'at git base'}.');
      logWarning(
          '${indentation}If this plugin is not new, something has gone wrong.');
      return _CurrentVersionState.validChange; // Assume new, thus valid.
    }

    if (previousVersion == currentVersion) {
      print('${indentation}No version change.');
      return _CurrentVersionState.unchanged;
    }

    // Check for reverts when doing local validation.
    if (!getBoolArg(_againstPubFlag) && currentVersion < previousVersion) {
      final Map<Version, NextVersionType> possibleVersionsFromNewVersion =
          getAllowedNextVersions(currentVersion, newVersion: previousVersion);
      // Since this skips validation, try to ensure that it really is likely
      // to be a revert rather than a typo by checking that the transition
      // from the lower version to the new version would have been valid.
      if (possibleVersionsFromNewVersion.containsKey(previousVersion)) {
        logWarning('${indentation}New version is lower than previous version. '
            'This is assumed to be a revert.');
        return _CurrentVersionState.validChange;
      }
    }

    final Map<Version, NextVersionType> allowedNextVersions =
        getAllowedNextVersions(previousVersion, newVersion: currentVersion);

    if (allowedNextVersions.containsKey(currentVersion)) {
      print('$indentation$previousVersion -> $currentVersion');
    } else {
      final String source = (getBoolArg(_againstPubFlag)) ? 'pub' : 'master';
      printError('${indentation}Incorrectly updated version.\n'
          '${indentation}HEAD: $currentVersion, $source: $previousVersion.\n'
          '${indentation}Allowed versions: $allowedNextVersions');
      return _CurrentVersionState.invalidChange;
    }

    if (allowedNextVersions[currentVersion] == NextVersionType.BREAKING_MAJOR &&
        !_validateBreakingChange(package)) {
      printError('${indentation}Breaking change detected.\n'
          '${indentation}Breaking changes to platform interfaces are not '
          'allowed without explicit justification.\n'
          '${indentation}See '
          'https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages '
          'for more information.');
      return _CurrentVersionState.invalidChange;
    }

    return _CurrentVersionState.validChange;
  }

  /// Checks whether or not [package]'s CHANGELOG's versioning is correct,
  /// both that it matches [pubspec] and that NEXT is used correctly, printing
  /// the results of its checks.
  ///
  /// Returns false if the CHANGELOG fails validation.
  Future<bool> _validateChangelogVersion(
    RepositoryPackage package, {
    required Pubspec pubspec,
    required bool pubspecVersionChanged,
  }) async {
    // This method isn't called unless `version` is non-null.
    final Version fromPubspec = pubspec.version!;

    // get first version from CHANGELOG
    final File changelog = package.directory.childFile('CHANGELOG.md');
    final List<String> lines = changelog.readAsLinesSync();
    String? firstLineWithText;
    final Iterator<String> iterator = lines.iterator;
    while (iterator.moveNext()) {
      if (iterator.current.trim().isNotEmpty) {
        firstLineWithText = iterator.current.trim();
        break;
      }
    }
    // Remove all leading mark down syntax from the version line.
    String? versionString = firstLineWithText?.split(' ').last;

    final String badNextErrorMessage = '${indentation}When bumping the version '
        'for release, the NEXT section should be incorporated into the new '
        'version\'s release notes.';

    // Skip validation for the special NEXT version that's used to accumulate
    // changes that don't warrant publishing on their own.
    final bool hasNextSection = versionString == 'NEXT';
    if (hasNextSection) {
      // NEXT should not be present in a commit that changes the version.
      if (pubspecVersionChanged) {
        printError(badNextErrorMessage);
        return false;
      }
      print(
          '${indentation}Found NEXT; validating next version in the CHANGELOG.');
      // Ensure that the version in pubspec hasn't changed without updating
      // CHANGELOG. That means the next version entry in the CHANGELOG should
      // pass the normal validation.
      versionString = null;
      while (iterator.moveNext()) {
        if (iterator.current.trim().startsWith('## ')) {
          versionString = iterator.current.trim().split(' ').last;
          break;
        }
      }
    }

    if (versionString == null) {
      printError('${indentation}Unable to find a version in CHANGELOG.md');
      print('${indentation}The current version should be on a line starting '
          'with "## ", either on the first non-empty line or after a "## NEXT" '
          'section.');
      return false;
    }

    final Version fromChangeLog;
    try {
      fromChangeLog = Version.parse(versionString);
    } on FormatException {
      printError('"$versionString" could not be parsed as a version.');
      return false;
    }

    if (fromPubspec != fromChangeLog) {
      printError('''
${indentation}Versions in CHANGELOG.md and pubspec.yaml do not match.
${indentation}The version in pubspec.yaml is $fromPubspec.
${indentation}The first version listed in CHANGELOG.md is $fromChangeLog.
''');
      return false;
    }

    // If NEXT wasn't the first section, it should not exist at all.
    if (!hasNextSection) {
      final RegExp nextRegex = RegExp(r'^#+\s*NEXT\s*$');
      if (lines.any((String line) => nextRegex.hasMatch(line))) {
        printError(badNextErrorMessage);
        return false;
      }
    }

    return true;
  }

  Pubspec? _tryParsePubspec(RepositoryPackage package) {
    final File pubspecFile = package.pubspecFile;

    try {
      final Pubspec pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
      return pubspec;
    } on Exception catch (exception) {
      printError('${indentation}Failed to parse `pubspec.yaml`: $exception}');
      return null;
    }
  }

  /// Checks whether the current breaking change to [package] should be allowed,
  /// logging extra information for auditing when allowing unusual cases.
  bool _validateBreakingChange(RepositoryPackage package) {
    // Only platform interfaces have breaking change restrictions.
    if (!package.isPlatformInterface) {
      return true;
    }

    if (getBoolArg(_ignorePlatformInterfaceBreaks)) {
      logWarning(
          '${indentation}Allowing breaking change to ${package.displayName} '
          'due to --$_ignorePlatformInterfaceBreaks');
      return true;
    }

    if (_getChangeDescription().contains(_breakingChangeJustificationMarker)) {
      logWarning(
          '${indentation}Allowing breaking change to ${package.displayName} '
          'due to "$_breakingChangeJustificationMarker" in the change '
          'description.');
      return true;
    }

    return false;
  }

  /// Returns the contents of the file pointed to by [_changeDescriptionFile],
  /// or an empty string if that flag is not provided.
  String _getChangeDescription() {
    final String path = getStringArg(_changeDescriptionFile);
    if (path.isEmpty) {
      return '';
    }
    final File file = packagesDir.fileSystem.file(path);
    if (!file.existsSync()) {
      printError('${indentation}No such file: $path');
      throw ToolExit(_exitMissingChangeDescriptionFile);
    }
    return file.readAsStringSync();
  }
}
