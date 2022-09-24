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

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/package_looping_command.dart';
import 'common/package_state_utils.dart';
import 'common/process_runner.dart';
import 'common/pub_version_finder.dart';
import 'common/repository_package.dart';

/// Categories of version change types.
enum NextVersionType {
  /// A breaking change.
  BREAKING_MAJOR,

  /// A minor change (e.g., added feature).
  MINOR,

  /// A bugfix change.
  PATCH,

  /// The release of an existing pre-1.0 version.
  V1_RELEASE,
}

/// The state of a package's version relative to the comparison base.
enum _CurrentVersionState {
  /// The version is unchanged.
  unchanged,

  /// The version has increased, and the transition is valid.
  validIncrease,

  /// The version has decrease, and the transition is a valid revert.
  validRevert,

  /// The version has changed, and the transition is invalid.
  invalidChange,

  /// There was an error determining the version state.
  unknown,
}

/// Returns the set of allowed next non-prerelease versions, with their change
/// type, for [version].
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
    final Version nextBuildVersion = Version(
      version.major,
      version.minor,
      version.patch,
      build: nextBuildNumber.toString(),
    );
    allowedNextVersions.clear();
    allowedNextVersions[version.nextMajor] = NextVersionType.V1_RELEASE;
    allowedNextVersions[version.nextMinor] = NextVersionType.BREAKING_MAJOR;
    allowedNextVersions[version.nextPatch] = NextVersionType.MINOR;
    allowedNextVersions[nextBuildVersion] = NextVersionType.PATCH;
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
    );
    argParser.addOption(_prLabelsArg,
        help: 'A comma-separated list of labels associated with this PR, '
            'if applicable.\n\n'
            'If supplied, this may be to allow overrides to some version '
            'checks.');
    argParser.addFlag(_checkForMissingChanges,
        help: 'Validates that changes to packages include CHANGELOG and '
            'version changes unless they meet an established exemption.\n\n'
            'If used with --$_prLabelsArg, this is should only be '
            'used in pre-submit CI checks, to  prevent post-submit breakage '
            'when labels are no longer applicable.',
        hide: true);
    argParser.addFlag(_ignorePlatformInterfaceBreaks,
        help: 'Bypasses the check that platform interfaces do not contain '
            'breaking changes.\n\n'
            'This is only intended for use in post-submit CI checks, to '
            'prevent post-submit breakage when overriding the check with '
            'labels. Pre-submit checks should always use '
            '--$_prLabelsArg instead.',
        hide: true);
  }

  static const String _againstPubFlag = 'against-pub';
  static const String _prLabelsArg = 'pr-labels';
  static const String _checkForMissingChanges = 'check-for-missing-changes';
  static const String _ignorePlatformInterfaceBreaks =
      'ignore-platform-interface-breaks';

  /// The label that must be on a PR to allow a breaking
  /// change to a platform interface.
  static const String _breakingChangeOverrideLabel =
      'override: allow breaking change';

  /// The label that must be on a PR to allow skipping a version change for a PR
  /// that would normally require one.
  static const String _missingVersionChangeOverrideLabel =
      'override: no versioning needed';

  /// The label that must be on a PR to allow skipping a CHANGELOG change for a
  /// PR that would normally require one.
  static const String _missingChangelogChangeOverrideLabel =
      'override: no changelog needed';

  final PubVersionFinder _pubVersionFinder;

  late final GitVersionFinder _gitVersionFinder;
  late final String _mergeBase;
  late final List<String> _changedFiles;

  late final Set<String> _prLabels = _getPRLabels();

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
  Future<void> initializeRun() async {
    _gitVersionFinder = await retrieveVersionFinder();
    _mergeBase = await _gitVersionFinder.getBaseSha();
    _changedFiles = await _gitVersionFinder.getChangedFiles();
  }

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
      case _CurrentVersionState.validIncrease:
      case _CurrentVersionState.validRevert:
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
        pubspec: pubspec, pubspecVersionState: versionState))) {
      errors.add('CHANGELOG.md failed validation.');
    }

    // If there are no other issues, make sure that there isn't a missing
    // change to the version and/or CHANGELOG.
    if (getBoolArg(_checkForMissingChanges) &&
        !versionChanged &&
        errors.isEmpty) {
      final String? error = await _checkForMissingChangeError(package);
      if (error != null) {
        errors.add(error);
      }
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
  Future<Version?> _getPreviousVersionFromGit(RepositoryPackage package) async {
    final File pubspecFile = package.pubspecFile;
    final String relativePath =
        path.relative(pubspecFile.absolute.path, from: (await gitDir).path);
    // Use Posix-style paths for git.
    final String gitPath = path.style == p.Style.windows
        ? p.posix.joinAll(path.split(relativePath))
        : relativePath;
    return await _gitVersionFinder.getPackageVersion(gitPath,
        gitRef: _mergeBase);
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
    String previousVersionSource;
    if (getBoolArg(_againstPubFlag)) {
      previousVersionSource = 'pub';
      previousVersion = await _fetchPreviousVersionFromPub(pubspec.name);
      if (previousVersion == null) {
        return _CurrentVersionState.unknown;
      }
      if (previousVersion != Version.none) {
        print(
            '$indentation${pubspec.name}: Current largest version on pub: $previousVersion');
      }
    } else {
      previousVersionSource = _mergeBase;
      previousVersion =
          await _getPreviousVersionFromGit(package) ?? Version.none;
    }
    if (previousVersion == Version.none) {
      print('${indentation}Unable to find previous version '
          '${getBoolArg(_againstPubFlag) ? 'on pub server' : 'at git base'}.');
      logWarning(
          '${indentation}If this plugin is not new, something has gone wrong.');
      return _CurrentVersionState.validIncrease; // Assume new, thus valid.
    }

    if (previousVersion == currentVersion) {
      print('${indentation}No version change.');
      return _CurrentVersionState.unchanged;
    }

    // Check for reverts when doing local validation.
    if (!getBoolArg(_againstPubFlag) && currentVersion < previousVersion) {
      // Since this skips validation, try to ensure that it really is likely
      // to be a revert rather than a typo by checking that the transition
      // from the lower version to the new version would have been valid.
      if (_shouldAllowVersionChange(
          oldVersion: currentVersion, newVersion: previousVersion)) {
        logWarning('${indentation}New version is lower than previous version. '
            'This is assumed to be a revert.');
        return _CurrentVersionState.validRevert;
      }
    }

    final Map<Version, NextVersionType> allowedNextVersions =
        getAllowedNextVersions(previousVersion, newVersion: currentVersion);

    if (_shouldAllowVersionChange(
        oldVersion: previousVersion, newVersion: currentVersion)) {
      print('$indentation$previousVersion -> $currentVersion');
    } else {
      printError('${indentation}Incorrectly updated version.\n'
          '${indentation}HEAD: $currentVersion, $previousVersionSource: $previousVersion.\n'
          '${indentation}Allowed versions: $allowedNextVersions');
      return _CurrentVersionState.invalidChange;
    }

    // Check whether the version (or for a pre-release, the version that
    // pre-release would eventually be released as) is a breaking change, and
    // if so, validate it.
    final Version targetReleaseVersion =
        currentVersion.isPreRelease ? currentVersion.nextPatch : currentVersion;
    if (allowedNextVersions[targetReleaseVersion] ==
            NextVersionType.BREAKING_MAJOR &&
        !_validateBreakingChange(package)) {
      printError('${indentation}Breaking change detected.\n'
          '${indentation}Breaking changes to platform interfaces are not '
          'allowed without explicit justification.\n'
          '${indentation}See '
          'https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages '
          'for more information.');
      return _CurrentVersionState.invalidChange;
    }

    return _CurrentVersionState.validIncrease;
  }

  /// Checks whether or not [package]'s CHANGELOG's versioning is correct,
  /// both that it matches [pubspec] and that NEXT is used correctly, printing
  /// the results of its checks.
  ///
  /// Returns false if the CHANGELOG fails validation.
  Future<bool> _validateChangelogVersion(
    RepositoryPackage package, {
    required Pubspec pubspec,
    required _CurrentVersionState pubspecVersionState,
  }) async {
    // This method isn't called unless `version` is non-null.
    final Version fromPubspec = pubspec.version!;

    // get first version from CHANGELOG
    final File changelog = package.changelogFile;
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
        "version's release notes.";

    // Skip validation for the special NEXT version that's used to accumulate
    // changes that don't warrant publishing on their own.
    final bool hasNextSection = versionString == 'NEXT';
    if (hasNextSection) {
      // NEXT should not be present in a commit that increases the version.
      if (pubspecVersionState == _CurrentVersionState.validIncrease ||
          pubspecVersionState == _CurrentVersionState.invalidChange) {
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
    try {
      final Pubspec pubspec = package.parsePubspec();
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

    if (_prLabels.contains(_breakingChangeOverrideLabel)) {
      logWarning(
          '${indentation}Allowing breaking change to ${package.displayName} '
          'due to the "$_breakingChangeOverrideLabel" label.');
      return true;
    }

    return false;
  }

  /// Returns the labels associated with this PR, if any, or an empty set
  /// if that flag is not provided.
  Set<String> _getPRLabels() {
    final String labels = getStringArg(_prLabelsArg);
    if (labels.isEmpty) {
      return <String>{};
    }
    return labels.split(',').map((String label) => label.trim()).toSet();
  }

  /// Returns true if the given version transition should be allowed.
  bool _shouldAllowVersionChange(
      {required Version oldVersion, required Version newVersion}) {
    // Get the non-pre-release next version mapping.
    final Map<Version, NextVersionType> allowedNextVersions =
        getAllowedNextVersions(oldVersion, newVersion: newVersion);

    if (allowedNextVersions.containsKey(newVersion)) {
      return true;
    }
    // Allow a pre-release version of a version that would be a valid
    // transition.
    if (newVersion.isPreRelease) {
      final Version targetReleaseVersion = newVersion.nextPatch;
      if (allowedNextVersions.containsKey(targetReleaseVersion)) {
        return true;
      }
    }
    return false;
  }

  /// Returns an error string if the changes to this package should have
  /// resulted in a version change, or shoud have resulted in a CHANGELOG change
  /// but didn't.
  ///
  /// This should only be called if the version did not change.
  Future<String?> _checkForMissingChangeError(RepositoryPackage package) async {
    // Find the relative path to the current package, as it would appear at the
    // beginning of a path reported by getChangedFiles() (which always uses
    // Posix paths).
    final Directory gitRoot =
        packagesDir.fileSystem.directory((await gitDir).path);
    final String relativePackagePath =
        getRelativePosixPath(package.directory, from: gitRoot);

    final PackageChangeState state = await checkPackageChangeState(package,
        changedPaths: _changedFiles,
        relativePackagePath: relativePackagePath,
        git: await retrieveVersionFinder());

    if (!state.hasChanges) {
      return null;
    }

    if (state.needsVersionChange) {
      if (_prLabels.contains(_missingVersionChangeOverrideLabel)) {
        logWarning('Ignoring lack of version change due to the '
            '"$_missingVersionChangeOverrideLabel" label.');
      } else {
        printError(
            'No version change found, but the change to this package could '
            'not be verified to be exempt from version changes according to '
            'repository policy. If this is a false positive, please comment in '
            'the PR to explain why the PR is exempt, and add (or ask your '
            'reviewer to add) the "$_missingVersionChangeOverrideLabel" '
            'label.');
        return 'Missing version change';
      }
    }

    if (!state.hasChangelogChange && state.needsChangelogChange) {
      if (_prLabels.contains(_missingChangelogChangeOverrideLabel)) {
        logWarning('Ignoring lack of CHANGELOG update due to the '
            '"$_missingChangelogChangeOverrideLabel" label.');
      } else {
        printError(
            'No CHANGELOG change found. If this PR needs an exemption from '
            'the standard policy of listing all changes in the CHANGELOG, '
            'comment in the PR to explain why the PR is exempt, and add (or '
            'ask your reviewer to add) the '
            '"$_missingChangelogChangeOverrideLabel" label. Otherwise, '
            'please add a NEXT entry in the CHANGELOG as described in '
            'the contributing guide.');
        return 'Missing CHANGELOG change';
      }
    }

    return null;
  }
}
