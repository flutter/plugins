// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/package_looping_command.dart';
import 'common/package_state_utils.dart';
import 'common/repository_package.dart';

/// Supported version change types, from smallest to largest component.
enum _VersionIncrementType { build, bugfix, minor }

/// Possible results of attempting to update a CHANGELOG.md file.
enum _ChangelogUpdateOutcome { addedSection, updatedSection, failed }

/// A state machine for the process of updating a CHANGELOG.md.
enum _ChangelogUpdateState {
  /// Looking for the first version section.
  findingFirstSection,

  /// Looking for the first list entry in an existing section.
  findingFirstListItem,

  /// Finished with updates.
  finishedUpdating,
}

/// A command to update the changelog, and optionally version, of packages.
class UpdateReleaseInfoCommand extends PackageLoopingCommand {
  /// Creates a publish metadata updater command instance.
  UpdateReleaseInfoCommand(
    Directory packagesDir, {
    GitDir? gitDir,
  }) : super(packagesDir, gitDir: gitDir) {
    argParser.addOption(_changelogFlag,
        mandatory: true,
        help: 'The changelog entry to add. '
            'Each line will be a separate list entry.');
    argParser.addOption(_versionTypeFlag,
        mandatory: true,
        help: 'The version change level',
        allowed: <String>[
          _versionNext,
          _versionMinimal,
          _versionBugfix,
          _versionMinor,
        ],
        allowedHelp: <String, String>{
          _versionNext:
              'No version change; just adds a NEXT entry to the changelog.',
          _versionBugfix: 'Increments the bugfix version.',
          _versionMinor: 'Increments the minor version.',
          _versionMinimal: 'Depending on the changes to each package: '
              'increments the bugfix version (for publishable changes), '
              "uses NEXT (for changes that don't need to be published), "
              'or skips (if no changes).',
        });
  }

  static const String _changelogFlag = 'changelog';
  static const String _versionTypeFlag = 'version';

  static const String _versionNext = 'next';
  static const String _versionBugfix = 'bugfix';
  static const String _versionMinor = 'minor';
  static const String _versionMinimal = 'minimal';

  // The version change type, if there is a set type for all platforms.
  //
  // If null, either there is no version change, or it is dynamic (`minimal`).
  _VersionIncrementType? _versionChange;

  // The cache of changed files, for dynamic version change determination.
  //
  // Only set for `minimal` version change.
  late final List<String> _changedFiles;

  @override
  final String name = 'update-release-info';

  @override
  final String description = 'Updates CHANGELOG.md files, and optionally the '
      'version in pubspec.yaml, in a way that is consistent with version-check '
      'enforcement.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<void> initializeRun() async {
    if (getStringArg(_changelogFlag).trim().isEmpty) {
      throw UsageException('Changelog message must not be empty.', usage);
    }
    switch (getStringArg(_versionTypeFlag)) {
      case _versionMinor:
        _versionChange = _VersionIncrementType.minor;
        break;
      case _versionBugfix:
        _versionChange = _VersionIncrementType.bugfix;
        break;
      case _versionMinimal:
        final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
        // If the line below fails with "Not a valid object name FETCH_HEAD"
        // run "git fetch", FETCH_HEAD is a temporary reference that only exists
        // after a fetch. This can happen when a branch is made locally and
        // pushed but never fetched.
        _changedFiles = await gitVersionFinder.getChangedFiles();
        // Anothing other than a fixed change is null.
        _versionChange = null;
        break;
      case _versionNext:
        _versionChange = null;
        break;
      default:
        throw UnimplementedError('Unimplemented version change type');
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    String nextVersionString;

    _VersionIncrementType? versionChange = _versionChange;

    // If the change type is `minimal` determine what changes, if any, are
    // needed.
    if (versionChange == null &&
        getStringArg(_versionTypeFlag) == _versionMinimal) {
      final Directory gitRoot =
          packagesDir.fileSystem.directory((await gitDir).path);
      final String relativePackagePath =
          getRelativePosixPath(package.directory, from: gitRoot);
      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: _changedFiles,
          relativePackagePath: relativePackagePath);

      if (!state.hasChanges) {
        return PackageResult.skip('No changes to package');
      }
      if (!state.needsVersionChange && !state.needsChangelogChange) {
        return PackageResult.skip('No non-exempt changes to package');
      }
      if (state.needsVersionChange) {
        versionChange = _VersionIncrementType.bugfix;
      }
    }

    if (versionChange != null) {
      final Version? updatedVersion =
          _updatePubspecVersion(package, versionChange);
      if (updatedVersion == null) {
        return PackageResult.fail(
            <String>['Could not determine current version.']);
      }
      nextVersionString = updatedVersion.toString();
      print('${indentation}Incremented version to $nextVersionString.');
    } else {
      nextVersionString = 'NEXT';
    }

    final _ChangelogUpdateOutcome updateOutcome =
        _updateChangelog(package, nextVersionString);
    switch (updateOutcome) {
      case _ChangelogUpdateOutcome.addedSection:
        print('${indentation}Added a $nextVersionString section.');
        break;
      case _ChangelogUpdateOutcome.updatedSection:
        print('${indentation}Updated NEXT section.');
        break;
      case _ChangelogUpdateOutcome.failed:
        return PackageResult.fail(<String>['Could not update CHANGELOG.md.']);
    }

    return PackageResult.success();
  }

  _ChangelogUpdateOutcome _updateChangelog(
      RepositoryPackage package, String version) {
    if (!package.changelogFile.existsSync()) {
      printError('${indentation}Missing CHANGELOG.md.');
      return _ChangelogUpdateOutcome.failed;
    }

    final String newHeader = '## $version';
    final RegExp listItemPattern = RegExp(r'^(\s*[-*])');

    final StringBuffer newChangelog = StringBuffer();
    _ChangelogUpdateState state = _ChangelogUpdateState.findingFirstSection;
    bool updatedExistingSection = false;

    for (final String line in package.changelogFile.readAsLinesSync()) {
      switch (state) {
        case _ChangelogUpdateState.findingFirstSection:
          final String trimmedLine = line.trim();
          if (trimmedLine.isEmpty) {
            // Discard any whitespace at the top of the file.
          } else if (trimmedLine == '## NEXT') {
            // Replace the header with the new version (which may also be NEXT).
            newChangelog.writeln(newHeader);
            // Find the existing list to add to.
            state = _ChangelogUpdateState.findingFirstListItem;
          } else {
            // The first content in the file isn't a NEXT section, so just add
            // the new section.
            <String>[
              newHeader,
              '',
              ..._changelogAdditionsAsList(),
              '',
              line, // Don't drop the current line.
            ].forEach(newChangelog.writeln);
            state = _ChangelogUpdateState.finishedUpdating;
          }
          break;
        case _ChangelogUpdateState.findingFirstListItem:
          final RegExpMatch? match = listItemPattern.firstMatch(line);
          if (match != null) {
            final String listMarker = match[1]!;
            // Add the new items on top. If the new change is changing the
            // version, then the new item should be more relevant to package
            // clients than anything that was already there. If it's still
            // NEXT, the order doesn't matter.
            <String>[
              ..._changelogAdditionsAsList(listMarker: listMarker),
              line, // Don't drop the current line.
            ].forEach(newChangelog.writeln);
            state = _ChangelogUpdateState.finishedUpdating;
            updatedExistingSection = true;
          } else if (line.trim().isEmpty) {
            // Scan past empty lines, but keep them.
            newChangelog.writeln(line);
          } else {
            printError('  Existing NEXT section has unrecognized format.');
            return _ChangelogUpdateOutcome.failed;
          }
          break;
        case _ChangelogUpdateState.finishedUpdating:
          // Once changes are done, add the rest of the lines as-is.
          newChangelog.writeln(line);
          break;
      }
    }

    package.changelogFile.writeAsStringSync(newChangelog.toString());

    return updatedExistingSection
        ? _ChangelogUpdateOutcome.updatedSection
        : _ChangelogUpdateOutcome.addedSection;
  }

  /// Returns the changelog to add as a Markdown list, using the given list
  /// bullet style (default to the repository standard of '*'), and adding
  /// any missing periods.
  ///
  /// E.g., 'A line\nAnother line.' will become:
  /// ```
  /// [ '* A line.', '* Another line.' ]
  /// ```
  Iterable<String> _changelogAdditionsAsList({String listMarker = '*'}) {
    return getStringArg(_changelogFlag).split('\n').map((String entry) {
      String standardizedEntry = entry.trim();
      if (!standardizedEntry.endsWith('.')) {
        standardizedEntry = '$standardizedEntry.';
      }
      return '$listMarker $standardizedEntry';
    });
  }

  /// Updates the version in [package]'s pubspec according to [type], returning
  /// the new version, or null if there was an error updating the version.
  Version? _updatePubspecVersion(
      RepositoryPackage package, _VersionIncrementType type) {
    final Pubspec pubspec = package.parsePubspec();
    final Version? currentVersion = pubspec.version;
    if (currentVersion == null) {
      printError('${indentation}No version in pubspec.yaml');
      return null;
    }

    // For versions less than 1.0, shift the change down one component per
    // Dart versioning conventions.
    final _VersionIncrementType adjustedType = currentVersion.major > 0
        ? type
        : _VersionIncrementType.values[type.index - 1];

    final Version newVersion = _nextVersion(currentVersion, adjustedType);

    // Write the new version to the pubspec.
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    editablePubspec.update(<String>['version'], newVersion.toString());
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());

    return newVersion;
  }

  Version _nextVersion(Version version, _VersionIncrementType type) {
    switch (type) {
      case _VersionIncrementType.minor:
        return version.nextMinor;
      case _VersionIncrementType.bugfix:
        return version.nextPatch;
      case _VersionIncrementType.build:
        final int buildNumber =
            version.build.isEmpty ? 0 : version.build.first as int;
        return Version(version.major, version.minor, version.patch,
            build: '${buildNumber + 1}');
    }
  }
}
