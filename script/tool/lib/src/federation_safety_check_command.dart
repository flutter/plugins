// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';

import 'common/core.dart';
import 'common/file_utils.dart';
import 'common/git_version_finder.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// A command to check that PRs don't violate repository best practices that
/// have been established to avoid breakages that building and testing won't
/// catch.
class FederationSafetyCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the safety check command.
  FederationSafetyCheckCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
    GitDir? gitDir,
  }) : super(
          packagesDir,
          processRunner: processRunner,
          platform: platform,
          gitDir: gitDir,
        );

  // A map of package name (as defined by the directory name of the package)
  // to a list of changed Dart files in that package, as Posix paths relative to
  // the package root.
  //
  // This only considers top-level packages, not subpackages such as example/.
  final Map<String, List<String>> _changedDartFiles = <String, List<String>>{};

  // The set of *_platform_interface packages that will have public code changes
  // published.
  final Set<String> _modifiedAndPublishedPlatformInterfacePackages = <String>{};

  // The set of conceptual plugins (not packages) that have changes.
  final Set<String> _changedPlugins = <String>{};

  static const String _platformInterfaceSuffix = '_platform_interface';

  @override
  final String name = 'federation-safety-check';

  @override
  final String description =
      'Checks that the change does not violate repository rules around changes '
      'to federated plugin packages.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<void> initializeRun() async {
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final String baseSha = await gitVersionFinder.getBaseSha();
    print('Validating changes relative to "$baseSha"\n');
    for (final String path in await gitVersionFinder.getChangedFiles()) {
      // Git output always uses Posix paths.
      final List<String> allComponents = p.posix.split(path);
      final int packageIndex = allComponents.indexOf('packages');
      if (packageIndex == -1) {
        continue;
      }
      final List<String> relativeComponents =
          allComponents.sublist(packageIndex + 1);
      // The package name is either the directory directly under packages/, or
      // the directory under that in the case of a federated plugin.
      String packageName = relativeComponents.removeAt(0);
      // Count the top-level plugin as changed.
      _changedPlugins.add(packageName);
      if (relativeComponents[0] == packageName ||
          (relativeComponents.length > 1 &&
              relativeComponents[0].startsWith('${packageName}_'))) {
        packageName = relativeComponents.removeAt(0);
      }

      if (relativeComponents.last.endsWith('.dart')) {
        _changedDartFiles[packageName] ??= <String>[];
        _changedDartFiles[packageName]!
            .add(p.posix.joinAll(relativeComponents));
      }

      if (packageName.endsWith(_platformInterfaceSuffix) &&
          relativeComponents.first == 'pubspec.yaml' &&
          await _packageWillBePublished(path)) {
        _modifiedAndPublishedPlatformInterfacePackages.add(packageName);
      }
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!isFlutterPlugin(package)) {
      return PackageResult.skip('Not a plugin.');
    }

    if (!package.isFederated) {
      return PackageResult.skip('Not a federated plugin.');
    }

    if (package.isPlatformInterface) {
      // As the leaf nodes in the graph, a published package interface change is
      // assumed to be correct, and other changes are validated against that.
      return PackageResult.skip(
          'Platform interface changes are not validated.');
    }

    // Uses basename to match _changedPackageFiles.
    final String basePackageName = package.directory.parent.basename;
    final String platformInterfacePackageName =
        '$basePackageName$_platformInterfaceSuffix';
    final List<String> changedPlatformInterfaceFiles =
        _changedDartFiles[platformInterfacePackageName] ?? <String>[];

    if (!_modifiedAndPublishedPlatformInterfacePackages
        .contains(platformInterfacePackageName)) {
      print('No published changes for $platformInterfacePackageName.');
      return PackageResult.success();
    }

    if (!changedPlatformInterfaceFiles
        .any((String path) => path.startsWith('lib/'))) {
      print('No public code changes for $platformInterfacePackageName.');
      return PackageResult.success();
    }

    final List<String> changedPackageFiles =
        _changedDartFiles[package.directory.basename] ?? <String>[];
    if (changedPackageFiles.isEmpty) {
      print('No Dart changes.');
      return PackageResult.success();
    }

    // If the change would be flagged, but it appears to be a mass change
    // rather than a plugin-specific change, allow it with a warning.
    //
    // This is a tradeoff between safety and convenience; forcing mass changes
    // to be split apart is not ideal, and the assumption is that reviewers are
    // unlikely to accidentally approve a PR that is supposed to be changing a
    // single plugin, but touches other plugins (vs accidentally approving a
    // PR that changes multiple parts of a single plugin, which is a relatively
    // easy mistake to make).
    //
    // 3 is chosen to minimize the chances of accidentally letting something
    // through (vs 2, which could be a single-plugin change with one stray
    // change to another file accidentally included), while not setting too
    // high a bar for detecting mass changes. This can be tuned if there are
    // issues with false positives or false negatives.
    const int massChangePluginThreshold = 3;
    if (_changedPlugins.length >= massChangePluginThreshold) {
      logWarning('Ignoring potentially dangerous change, as this appears '
          'to be a mass change.');
      return PackageResult.success();
    }

    printError('Dart changes are not allowed to other packages in '
        '$basePackageName in the same PR as changes to public Dart code in '
        '$platformInterfacePackageName, as this can cause accidental breaking '
        'changes to be missed by automated checks. Please split the changes to '
        'these two packages into separate PRs.\n\n'
        'If you believe that this is a false positive, please file a bug.');
    return PackageResult.fail(
        <String>['$platformInterfacePackageName changed.']);
  }

  Future<bool> _packageWillBePublished(
      String pubspecRepoRelativePosixPath) async {
    final File pubspecFile = childFileWithSubcomponents(
        packagesDir.parent, p.posix.split(pubspecRepoRelativePosixPath));
    if (!pubspecFile.existsSync()) {
      // If the package was deleted, nothing will be published.
      return false;
    }
    final Pubspec pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    if (pubspec.publishTo == 'none') {
      return false;
    }

    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final Version? previousVersion =
        await gitVersionFinder.getPackageVersion(pubspecRepoRelativePosixPath);
    if (previousVersion == null) {
      // The plugin is new, so it will be published.
      return true;
    }
    return pubspec.version != previousVersion;
  }
}
