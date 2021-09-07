// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Finding diffs based on `baseGitDir` and `baseSha`.
class GitVersionFinder {
  /// Constructor
  GitVersionFinder(this.baseGitDir, String? baseSha) : _baseSha = baseSha;

  /// The top level directory of the git repo.
  ///
  /// That is where the .git/ folder exists.
  final GitDir baseGitDir;

  /// The base sha used to get diff.
  String? _baseSha;

  static bool _isPubspec(String file) {
    return file.trim().endsWith('pubspec.yaml');
  }

  /// Get a list of all the pubspec.yaml file that is changed.
  Future<List<String>> getChangedPubSpecs() async {
    return (await getChangedFiles()).where(_isPubspec).toList();
  }

  /// Get a list of all the changed files.
  Future<List<String>> getChangedFiles() async {
    final String baseSha = await getBaseSha();
    final io.ProcessResult changedFilesCommand = await baseGitDir
        .runCommand(<String>['diff', '--name-only', baseSha, 'HEAD']);
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
    final String ref = gitRef ?? (await getBaseSha());

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

  /// Returns the base used to diff against.
  Future<String> getBaseSha() async {
    String? baseSha = _baseSha;
    if (baseSha != null && baseSha.isNotEmpty) {
      return baseSha;
    }

    io.ProcessResult baseShaFromMergeBase = await baseGitDir.runCommand(
        <String>['merge-base', '--fork-point', 'FETCH_HEAD', 'HEAD'],
        throwOnError: false);
    if (baseShaFromMergeBase.stderr != null ||
        baseShaFromMergeBase.stdout == null) {
      baseShaFromMergeBase = await baseGitDir
          .runCommand(<String>['merge-base', 'FETCH_HEAD', 'HEAD']);
    }
    baseSha = (baseShaFromMergeBase.stdout as String).trim();
    _baseSha = baseSha;
    return baseSha;
  }
}
