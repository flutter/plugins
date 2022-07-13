// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';

import 'core.dart';

export 'package:pubspec_parse/pubspec_parse.dart' show Pubspec;
export 'core.dart' show FlutterPlatform;

/// A package in the repository.
//
// TODO(stuartmorgan): Add more package-related info here, such as an on-demand
// cache of the parsed pubspec.
class RepositoryPackage {
  /// Creates a representation of the package at [directory].
  RepositoryPackage(this.directory);

  /// The location of the package.
  final Directory directory;

  /// The path to the package.
  String get path => directory.path;

  /// Returns the string to use when referring to the package in user-targeted
  /// messages.
  ///
  /// Callers should not expect a specific format for this string, since
  /// it uses heuristics to try to be precise without being overly verbose. If
  /// an exact format (e.g., published name, or basename) is required, that
  /// should be used instead.
  String get displayName {
    List<String> components = directory.fileSystem.path.split(directory.path);
    // Remove everything up to the packages directory.
    final int packagesIndex = components.indexOf('packages');
    if (packagesIndex != -1) {
      components = components.sublist(packagesIndex + 1);
    }
    // For the common federated plugin pattern of `foo/foo_subpackage`, drop
    // the first part since it's not useful.
    if (components.length >= 2 &&
        components[1].startsWith('${components[0]}_')) {
      components = components.sublist(1);
    }
    return p.posix.joinAll(components);
  }

  /// The package's top-level pubspec.yaml.
  File get pubspecFile => directory.childFile('pubspec.yaml');

  /// The package's top-level README.
  File get readmeFile => directory.childFile('README.md');

  /// The package's top-level README.
  File get changelogFile => directory.childFile('CHANGELOG.md');

  /// The package's top-level README.
  File get authorsFile => directory.childFile('AUTHORS');

  /// The lib directory containing the package's code.
  Directory get libDirectory => directory.childDirectory('lib');

  /// The test directory containing the package's Dart tests.
  Directory get testDirectory => directory.childDirectory('test');

  /// Returns the directory containing support for [platform].
  Directory platformDirectory(FlutterPlatform platform) {
    late final String directoryName;
    switch (platform) {
      case FlutterPlatform.android:
        directoryName = 'android';
        break;
      case FlutterPlatform.ios:
        directoryName = 'ios';
        break;
      case FlutterPlatform.linux:
        directoryName = 'linux';
        break;
      case FlutterPlatform.macos:
        directoryName = 'macos';
        break;
      case FlutterPlatform.web:
        directoryName = 'web';
        break;
      case FlutterPlatform.windows:
        directoryName = 'windows';
        break;
    }
    return directory.childDirectory(directoryName);
  }

  late final Pubspec _parsedPubspec =
      Pubspec.parse(pubspecFile.readAsStringSync());

  /// Returns the parsed [pubspecFile].
  ///
  /// Caches for future use.
  Pubspec parsePubspec() => _parsedPubspec;

  /// Returns true if the package depends on Flutter.
  bool requiresFlutter() {
    final Pubspec pubspec = parsePubspec();
    return pubspec.dependencies.containsKey('flutter');
  }

  /// True if this appears to be a federated plugin package, according to
  /// repository conventions.
  bool get isFederated =>
      directory.parent.basename != 'packages' &&
      directory.basename.startsWith(directory.parent.basename);

  /// True if this appears to be the app-facing package of a federated plugin,
  /// according to repository conventions.
  bool get isAppFacing =>
      directory.parent.basename != 'packages' &&
      directory.basename == directory.parent.basename;

  /// True if this appears to be a platform interface package, according to
  /// repository conventions.
  bool get isPlatformInterface =>
      directory.basename.endsWith('_platform_interface');

  /// True if this appears to be a platform implementation package, according to
  /// repository conventions.
  bool get isPlatformImplementation =>
      // Any part of a federated plugin that isn't the platform interface and
      // isn't the app-facing package should be an implementation package.
      isFederated &&
      !isPlatformInterface &&
      directory.basename != directory.parent.basename;

  /// Returns the Flutter example packages contained in the package, if any.
  Iterable<RepositoryPackage> getExamples() {
    final Directory exampleDirectory = directory.childDirectory('example');
    if (!exampleDirectory.existsSync()) {
      return <RepositoryPackage>[];
    }
    if (isPackage(exampleDirectory)) {
      return <RepositoryPackage>[RepositoryPackage(exampleDirectory)];
    }
    // Only look at the subdirectories of the example directory if the example
    // directory itself is not a Dart package, and only look one level below the
    // example directory for other Dart packages.
    return exampleDirectory
        .listSync()
        .where((FileSystemEntity entity) => isPackage(entity))
        // isPackage guarantees that the cast to Directory is safe.
        .map((FileSystemEntity entity) =>
            RepositoryPackage(entity as Directory));
  }
}
