// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';

const String kRootDirOption = 'root_dir';

bool isPubspec(String file) {
  return file.endsWith('pubspec.yaml');
}

Future<List<String>> getChangedPubSpecs(GitDir baseGitDir) async {
  final ProcessResult changedFilesCommand = await baseGitDir
      .runCommand(<String>['diff', '--name-only', 'master..HEAD']);
  final List<String> changedFiles =
      changedFilesCommand.stdout.toString().split('\n');
  return changedFiles.where(isPubspec).toList();
}

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser();
  parser.addOption(kRootDirOption);

  final ArgResults results = parser.parse(args);
  final String rootDir = results[kRootDirOption];

  if (await GitDir.isGitDir(rootDir)) {
    final GitDir baseGitDir = await GitDir.fromExisting(rootDir);
    final List<String> changedPubspecs = await getChangedPubSpecs(baseGitDir);

    print(changedPubspecs);
  } else {
    print('Not a Git directory');
  }
}
