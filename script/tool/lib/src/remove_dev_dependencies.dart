// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to remove dev_dependencies, which are not used by package clients.
///
/// This is intended for use with legacy Flutter version testing, to allow
/// running analysis (with --lib-only) with versions that are supported for
/// clients of the library, but not for development of the library.
class RemoveDevDependenciesCommand extends PackageLoopingCommand {
  /// Creates a publish metadata updater command instance.
  RemoveDevDependenciesCommand(Directory packagesDir) : super(packagesDir);

  @override
  final String name = 'remove-dev-dependencies';

  @override
  final String description = 'Removes any dev_dependencies section from a '
      'package, to allow more legacy testing.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    bool changed = false;
    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    const String devDependenciesKey = 'dev_dependencies';
    final YamlNode root = editablePubspec.parseAt(<String>[]);
    final YamlMap? devDependencies =
        (root as YamlMap)[devDependenciesKey] as YamlMap?;
    if (devDependencies != null) {
      changed = true;
      print('${indentation}Removed dev_dependencies');
      editablePubspec.remove(<String>[devDependenciesKey]);
    }

    if (changed) {
      package.pubspecFile.writeAsStringSync(editablePubspec.toString());
    }

    return changed
        ? PackageResult.success()
        : PackageResult.skip('Nothing to remove.');
  }
}
