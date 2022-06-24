// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to remove dependencies that aren't used by the library code
/// itself, such as `build_runner` and `pigeon`.
///
/// This is intended for use with legacy Flutter version testing, to allow
/// running analysis or tests with versions that are supported for clients of
/// the library, but not for development of the library.
class TrimDevDependenciesCommand extends PackageLoopingCommand {
  /// Creates a publish metadata updater command instance.
  TrimDevDependenciesCommand(Directory packagesDir) : super(packagesDir);

  @override
  final String name = 'trim-dev-dependencies';

  @override
  final String description = 'Removes a known set of packages that are never '
      'included by Dart code, but used in plugin development in the '
      'repository, to allow more legacy testing.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    const Set<String> targetDependencies = <String>{
      'build_runner',
      'pigeon',
    };

    bool removedPackage = false;
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    const String devDependenciesKey = 'dev_dependencies';
    final YamlNode root = editablePubspec.parseAt(<String>[]);
    final YamlMap? devDependencies =
        (root as YamlMap)[devDependenciesKey] as YamlMap?;
    if (devDependencies != null) {
      for (final String dependency in targetDependencies) {
        if (devDependencies[dependency] != null) {
          removedPackage = true;
          print('${indentation}Removed $dependency');
          editablePubspec.remove(<String>[devDependenciesKey, dependency]);
        }
      }
    }

    if (removedPackage) {
      package.pubspecFile.writeAsStringSync(editablePubspec.toString());
    }

    return removedPackage
        ? PackageResult.success()
        : PackageResult.skip('Nothing to remove.');
  }
}
