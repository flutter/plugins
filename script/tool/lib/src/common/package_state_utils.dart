// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'repository_package.dart';

/// The state of a package on disk relative to git state.
@immutable
class PackageChangeState {
  /// Creates a new immutable state instance.
  const PackageChangeState({
    required this.hasChanges,
    required this.hasChangelogChange,
    required this.needsVersionChange,
  });

  /// True if there are any changes to files in the package.
  final bool hasChanges;

  /// True if the package's CHANGELOG.md has been changed.
  final bool hasChangelogChange;

  /// True if any changes in the package require a version change according
  /// to repository policy.
  final bool needsVersionChange;
}

/// Checks [package] against [changedPaths] to determine what changes it has
/// and how those changes relate to repository policy about CHANGELOG and
/// version updates.
///
/// [changedPaths] should be a list of POSIX-style paths from a common root,
/// and [relativePackagePath] should be the path to [package] from that same
/// root. Commonly these will come from `gitVersionFinder.getChangedFiles()`
/// and `getRelativePoixPath(package.directory, gitDir.path)` respectively;
/// they are arguments mainly to allow for caching the changed paths for an
/// entire command run.
PackageChangeState checkPackageChangeState(
  RepositoryPackage package, {
  required List<String> changedPaths,
  required String relativePackagePath,
}) {
  final String packagePrefix = relativePackagePath.endsWith('/')
      ? relativePackagePath
      : '$relativePackagePath/';

  bool hasChanges = false;
  bool hasChangelogChange = false;
  bool needsVersionChange = false;
  for (final String path in changedPaths) {
    // Only consider files within the package.
    if (!path.startsWith(packagePrefix)) {
      continue;
    }
    final String packageRelativePath = path.substring(packagePrefix.length);
    hasChanges = true;

    final List<String> components = p.posix.split(packageRelativePath);
    if (components.isEmpty) {
      continue;
    }
    final bool isChangelog = components.first == 'CHANGELOG.md';
    if (isChangelog) {
      hasChangelogChange = true;
    }

    if (!needsVersionChange &&
        !isChangelog &&
        // One of a few special files example will be shown on pub.dev, but for
        // anything else in the example publishing has no purpose.
        !(components.first == 'example' &&
            !<String>{'main.dart', 'readme.md', 'example.md'}
                .contains(components.last.toLowerCase())) &&
        // Changes to tests don't need to be published.
        !components.contains('test') &&
        !components.contains('androidTest') &&
        !components.contains('RunnerTests') &&
        !components.contains('RunnerUITests') &&
        // The top-level "tool" directory is for non-client-facing utility code,
        // so doesn't need to be published.
        components.first != 'tool' &&
        // Ignoring lints doesn't affect clients.
        !components.contains('lint-baseline.xml')) {
      needsVersionChange = true;
    }
  }

  return PackageChangeState(
      hasChanges: hasChanges,
      hasChangelogChange: hasChangelogChange,
      needsVersionChange: needsVersionChange);
}
