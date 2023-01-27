// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// A command to update README code excerpts from code files.
class UpdateExcerptsCommand extends PackageLoopingCommand {
  /// Creates a excerpt updater command instance.
  UpdateExcerptsCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
    GitDir? gitDir,
  }) : super(
          packagesDir,
          processRunner: processRunner,
          platform: platform,
          gitDir: gitDir,
        ) {
    argParser.addFlag(_failOnChangeFlag, hide: true);
  }

  static const String _failOnChangeFlag = 'fail-on-change';

  static const String _buildRunnerConfigName = 'excerpt';
  // The name of the build_runner configuration file that will be in an example
  // directory if the package is set up to use `code-excerpt`.
  static const String _buildRunnerConfigFile =
      'build.$_buildRunnerConfigName.yaml';

  // The relative directory path to put the extracted excerpt yaml files.
  static const String _excerptOutputDir = 'excerpts';

  // The filename to store the pre-modification copy of the pubspec.
  static const String _originalPubspecFilename =
      'pubspec.plugin_tools_original.yaml';

  @override
  final String name = 'update-excerpts';

  @override
  final String description = 'Updates code excerpts in README.md files, based '
      'on code from code files, via code-excerpt';

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final Iterable<RepositoryPackage> configuredExamples = package
        .getExamples()
        .where((RepositoryPackage example) =>
            example.directory.childFile(_buildRunnerConfigFile).existsSync());

    if (configuredExamples.isEmpty) {
      return PackageResult.skip(
          'No $_buildRunnerConfigFile found in example(s).');
    }

    final Directory repoRoot =
        packagesDir.fileSystem.directory((await gitDir).path);

    for (final RepositoryPackage example in configuredExamples) {
      _addSubmoduleDependencies(example, repoRoot: repoRoot);

      try {
        // Ensure that dependencies are available.
        final int pubGetExitCode = await processRunner.runAndStream(
            'dart', <String>['pub', 'get'],
            workingDir: example.directory);
        if (pubGetExitCode != 0) {
          return PackageResult.fail(
              <String>['Unable to get script dependencies']);
        }

        // Update the excerpts.
        if (!await _extractSnippets(example)) {
          return PackageResult.fail(<String>['Unable to extract excerpts']);
        }
        if (!await _injectSnippets(example, targetPackage: package)) {
          return PackageResult.fail(<String>['Unable to inject excerpts']);
        }
      } finally {
        // Clean up the pubspec changes and extracted excerpts directory.
        _undoPubspecChanges(example);
        final Directory excerptDirectory =
            example.directory.childDirectory(_excerptOutputDir);
        if (excerptDirectory.existsSync()) {
          excerptDirectory.deleteSync(recursive: true);
        }
      }
    }

    if (getBoolArg(_failOnChangeFlag)) {
      final String? stateError = await _validateRepositoryState();
      if (stateError != null) {
        printError('README.md is out of sync with its source excerpts.\n\n'
            'If you edited code in README.md directly, you should instead edit '
            'the example source files. If you edited source files, run the '
            'repository tooling\'s "$name" command on this package, and update '
            'your PR with the resulting changes.');
        return PackageResult.fail(<String>[stateError]);
      }
    }

    return PackageResult.success();
  }

  /// Runs the extraction step to create the excerpt files for the given
  /// example, returning true on success.
  Future<bool> _extractSnippets(RepositoryPackage example) async {
    final int exitCode = await processRunner.runAndStream(
        'dart',
        <String>[
          'run',
          'build_runner',
          'build',
          '--config',
          _buildRunnerConfigName,
          '--output',
          _excerptOutputDir,
          '--delete-conflicting-outputs',
        ],
        workingDir: example.directory);
    return exitCode == 0;
  }

  /// Runs the injection step to update [targetPackage]'s README with the latest
  /// excerpts from [example], returning true on success.
  Future<bool> _injectSnippets(
    RepositoryPackage example, {
    required RepositoryPackage targetPackage,
  }) async {
    final String relativeReadmePath =
        getRelativePosixPath(targetPackage.readmeFile, from: example.directory);
    final int exitCode = await processRunner.runAndStream(
        'dart',
        <String>[
          'run',
          'code_excerpt_updater',
          '--write-in-place',
          '--yaml',
          '--no-escape-ng-interpolation',
          relativeReadmePath,
        ],
        workingDir: example.directory);
    return exitCode == 0;
  }

  /// Adds `code_excerpter` and `code_excerpt_updater` to [package]'s
  /// `dev_dependencies` using path-based references to the submodule copies.
  ///
  /// This is done on the fly rather than being checked in so that:
  /// - Just building examples don't require everyone to check out submodules.
  /// - Examples can be analyzed/built even on versions of Flutter that these
  ///   submodules do not support.
  void _addSubmoduleDependencies(RepositoryPackage package,
      {required Directory repoRoot}) {
    final String pubspecContents = package.pubspecFile.readAsStringSync();
    // Save aside a copy of the current pubspec state. This allows restoration
    // to the previous state regardless of its git status at the time the script
    // ran.
    package.directory
        .childFile(_originalPubspecFilename)
        .writeAsStringSync(pubspecContents);

    // Update the actual pubspec.
    final YamlEditor editablePubspec = YamlEditor(pubspecContents);
    const String devDependenciesKey = 'dev_dependencies';
    final YamlNode root = editablePubspec.parseAt(<String>[]);
    // Ensure that there's a `dev_dependencies` entry to update.
    if ((root as YamlMap)[devDependenciesKey] == null) {
      editablePubspec.update(<String>['dev_dependencies'], YamlMap());
    }
    final Set<String> submoduleDependencies = <String>{
      'code_excerpter',
      'code_excerpt_updater',
    };
    final String relativeRootPath =
        getRelativePosixPath(repoRoot, from: package.directory);
    for (final String dependency in submoduleDependencies) {
      editablePubspec.update(<String>[
        devDependenciesKey,
        dependency
      ], <String, String>{
        'path': '$relativeRootPath/site-shared/packages/$dependency'
      });
    }
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());
  }

  /// Restores the version of the pubspec that was present before running
  /// [_addSubmoduleDependencies].
  void _undoPubspecChanges(RepositoryPackage package) {
    package.directory
        .childFile(_originalPubspecFilename)
        .renameSync(package.pubspecFile.path);
  }

  /// Checks the git state, returning an error string if any .md files have
  /// changed.
  Future<String?> _validateRepositoryState() async {
    final io.ProcessResult checkFiles = await processRunner.run(
      'git',
      <String>['ls-files', '--modified'],
      workingDir: packagesDir,
      logOnError: true,
    );
    if (checkFiles.exitCode != 0) {
      return 'Unable to determine local file state';
    }

    final String stdout = checkFiles.stdout as String;
    final List<String> changedFiles = stdout.trim().split('\n');
    final Iterable<String> changedMDFiles =
        changedFiles.where((String filePath) => filePath.endsWith('.md'));
    if (changedMDFiles.isNotEmpty) {
      return 'Snippets are out of sync in the following files: '
          '${changedMDFiles.join(', ')}';
    }

    return null;
  }
}
