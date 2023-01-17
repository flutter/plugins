// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/package_command.dart';
import 'common/repository_package.dart';

/// A command to list different types of repository content.
class ListCommand extends PackageCommand {
  /// Creates an instance of the list command, whose behavior depends on the
  /// 'type' argument it provides.
  ListCommand(
    Directory packagesDir, {
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, platform: platform) {
    argParser.addOption(
      _type,
      defaultsTo: _package,
      allowed: <String>[_package, _example, _allPackage, _file],
      help: 'What type of file system content to list.',
    );
  }

  static const String _type = 'type';
  static const String _allPackage = 'package-or-subpackage';
  static const String _example = 'example';
  static const String _package = 'package';
  static const String _file = 'file';

  @override
  final String name = 'list';

  @override
  final String description = 'Lists packages or files';

  @override
  Future<void> run() async {
    switch (getStringArg(_type)) {
      case _package:
        await for (final PackageEnumerationEntry entry in getTargetPackages()) {
          print(entry.package.path);
        }
        break;
      case _example:
        final Stream<RepositoryPackage> examples = getTargetPackages()
            .expand<RepositoryPackage>(
                (PackageEnumerationEntry entry) => entry.package.getExamples());
        await for (final RepositoryPackage package in examples) {
          print(package.path);
        }
        break;
      case _allPackage:
        await for (final PackageEnumerationEntry entry
            in getTargetPackagesAndSubpackages()) {
          print(entry.package.path);
        }
        break;
      case _file:
        await for (final File file in getFiles()) {
          print(file.path);
        }
        break;
    }
  }
}
