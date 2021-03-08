// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:git/git.dart';

import 'common.dart';

const String _kBaseSha = 'base_sha';

/// Get the changed packages based on base_sha.
///
/// Outputs the final result in a comma separated format.
/// e.g. plugin1,plugin2...
class GetChangedPackageCommand extends PluginCommand {

  /// Constructor of the command.
  ///
  /// An optional `gitDir` can be specified if the `gitDir` used is not the top level dir.
  GetChangedPackageCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
    this.gitDir,
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addOption(_kBaseSha);
  }

  /// The git directory to use. By default it uses the parent directory.
  ///
  /// This can be mocked for testing.
  final GitDir gitDir;

  @override
  final String name = 'get-changed-packages';

  @override
  final String description =
      'Determines a list of changed packages based on the diff between base_sha and HEAD.\n'
      'The changed packages are returned through stdout and are separated by commas. (plugin1,plugin2..)';

  @override
  Future<Null> run() async {
    checkSharding();

    final String rootDir = packagesDir.parent.absolute.path;
    String baseSha = argResults[_kBaseSha];

    GitDir baseGitDir = gitDir;
    if (baseGitDir == null) {
      if (!await GitDir.isGitDir(rootDir)) {
        print('$rootDir is not a valid Git repository.');
        throw ToolExit(2);
      }
      baseGitDir = await GitDir.fromExisting(rootDir);
    }

    final GitVersionFinder gitVersionFinder =
        GitVersionFinder(baseGitDir, baseSha);

    final List<String> allChangedFiles = await gitVersionFinder.getChangedFiles();
    final Set<String> plugins = <String>{};
    allChangedFiles.forEach((String path) {
      final List<String> pathComponents = path.split('/');
      final int packagesIndex = pathComponents.indexWhere((String element) => element == 'package');
      if (packagesIndex != -1) {
        plugins.add(pathComponents[packagesIndex+1]);
      }
    });
    print(plugins.join(','));
  }
}
