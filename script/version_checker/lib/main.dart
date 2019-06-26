// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:colorize/colorize.dart';
import 'package:git/git.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

const String kRootDirOption = 'root_dir';
const String kBaseSha = 'base_sha';

bool isPubspec(String file) {
  return file.endsWith('pubspec.yaml');
}

Future<List<String>> getChangedPubSpecs(
    GitDir baseGitDir, String baseSha) async {
  final ProcessResult changedFilesCommand =
      await baseGitDir.runCommand(<String>['diff', '--name-only', '$baseSha']);
  final List<String> changedFiles =
      changedFilesCommand.stdout.toString().split('\n');
  return changedFiles.where(isPubspec).toList();
}

Future<Version> getPackageVersion(
    GitDir baseGitDir, String pubspecPath, String ref) async {
  final ProcessResult gitShow =
      await baseGitDir.runCommand(<String>['show', '$ref:$pubspecPath']);
  final String fileContent = gitShow.stdout;
  final String versionString = loadYaml(fileContent)['version'];
  return Version.parse(versionString);
}

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser();
  parser.addOption(kRootDirOption);
  parser.addOption(kBaseSha);

  final ArgResults results = parser.parse(args);
  final String rootDir = results[kRootDirOption];
  final String baseSha = results[kBaseSha];
  int exitCode = 0;

  if (await GitDir.isGitDir(rootDir)) {
    final GitDir baseGitDir = await GitDir.fromExisting(rootDir);
    final List<String> changedPubspecs =
        await getChangedPubSpecs(baseGitDir, baseSha);
    for (final String pubspecPath in changedPubspecs) {
      try {
        final Version masterVersion =
            await getPackageVersion(baseGitDir, pubspecPath, 'master');
        final Version headVersion =
            await getPackageVersion(baseGitDir, pubspecPath, 'HEAD');
        final Map<Version, String> allowedNextVersions = <Version, String>{
          masterVersion.nextBreaking: "BREAKING",
          masterVersion.nextMajor: "MAJOR",
          masterVersion.nextMinor: "MINOR",
          masterVersion.nextPatch: "PATCH",
        };
        if (!allowedNextVersions.containsKey(headVersion)) {
          final String error = '$pubspecPath incorrectly updated version.\n'
              'HEAD: $headVersion, master: $masterVersion.\n'
              'Allowed versions: $allowedNextVersions';
          final Colorize redError = Colorize(error)..red();
          print(redError);
          exitCode = 1;
        }
      } catch (ProcessException) {
        print('Unable to fine pubspec in master for $pubspecPath.'
            ' Safe to ignore if the project is new.');
      }
    }
  } else {
    print('$rootDir is not a valid Git repository.');
    exitCode = 2;
  }
  exit(exitCode);
}
