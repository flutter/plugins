// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// A command to enforce pubspec conventions across the repository.
///
/// This both ensures that repo best practices for which optional fields are
/// used are followed, and that the structure is consistent to make edits
/// across multiple pubspec files easier.
class PubspecCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the version check command.
  PubspecCheckCommand(
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

  // Section order for plugins. Because the 'flutter' section is critical
  // information for plugins, and usually small, it goes near the top unlike in
  // a normal app or package.
  static const List<String> _majorPluginSections = <String>[
    'environment:',
    'flutter:',
    'dependencies:',
    'dev_dependencies:',
    'false_secrets:',
  ];

  static const List<String> _majorPackageSections = <String>[
    'environment:',
    'dependencies:',
    'dev_dependencies:',
    'flutter:',
    'false_secrets:',
  ];

  static const String _expectedIssueLinkFormat =
      'https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A';

  @override
  final String name = 'pubspec-check';

  @override
  final String description =
      'Checks that pubspecs follow repository conventions.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final File pubspec = package.pubspecFile;
    final bool passesCheck =
        !pubspec.existsSync() || await _checkPubspec(pubspec, package: package);
    if (!passesCheck) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }

  Future<bool> _checkPubspec(
    File pubspecFile, {
    required RepositoryPackage package,
  }) async {
    final String contents = pubspecFile.readAsStringSync();
    final Pubspec? pubspec = _tryParsePubspec(contents);
    if (pubspec == null) {
      return false;
    }

    final List<String> pubspecLines = contents.split('\n');
    final bool isPlugin = pubspec.flutter?.containsKey('plugin') ?? false;
    final List<String> sectionOrder =
        isPlugin ? _majorPluginSections : _majorPackageSections;
    bool passing = _checkSectionOrder(pubspecLines, sectionOrder);
    if (!passing) {
      printError('${indentation}Major sections should follow standard '
          'repository ordering:');
      final String listIndentation = indentation * 2;
      printError('$listIndentation${sectionOrder.join('\n$listIndentation')}');
    }

    if (isPlugin) {
      final String? implementsError =
          _checkForImplementsError(pubspec, package: package);
      if (implementsError != null) {
        printError('$indentation$implementsError');
        passing = false;
      }

      final String? defaultPackageError =
          _checkForDefaultPackageError(pubspec, package: package);
      if (defaultPackageError != null) {
        printError('$indentation$defaultPackageError');
        passing = false;
      }
    }

    // Ignore metadata that's only relevant for published packages if the
    // packages is not intended for publishing.
    if (pubspec.publishTo != 'none') {
      final List<String> repositoryErrors =
          _checkForRepositoryLinkErrors(pubspec, package: package);
      if (repositoryErrors.isNotEmpty) {
        for (final String error in repositoryErrors) {
          printError('$indentation$error');
        }
        passing = false;
      }

      if (!_checkIssueLink(pubspec)) {
        printError(
            '${indentation}A package should have an "issue_tracker" link to a '
            'search for open flutter/flutter bugs with the relevant label:\n'
            '${indentation * 2}$_expectedIssueLinkFormat<package label>');
        passing = false;
      }

      // Don't check descriptions for federated package components other than
      // the app-facing package, since they are unlisted, and are expected to
      // have short descriptions.
      if (!package.isPlatformInterface && !package.isPlatformImplementation) {
        final String? descriptionError =
            _checkDescription(pubspec, package: package);
        if (descriptionError != null) {
          printError('$indentation$descriptionError');
          passing = false;
        }
      }
    }

    return passing;
  }

  Pubspec? _tryParsePubspec(String pubspecContents) {
    try {
      return Pubspec.parse(pubspecContents);
    } on Exception catch (exception) {
      print('  Cannot parse pubspec.yaml: $exception');
    }
    return null;
  }

  bool _checkSectionOrder(
      List<String> pubspecLines, List<String> sectionOrder) {
    int previousSectionIndex = 0;
    for (final String line in pubspecLines) {
      final int index = sectionOrder.indexOf(line);
      if (index == -1) {
        continue;
      }
      if (index < previousSectionIndex) {
        return false;
      }
      previousSectionIndex = index;
    }
    return true;
  }

  List<String> _checkForRepositoryLinkErrors(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    final List<String> errorMessages = <String>[];
    if (pubspec.repository == null) {
      errorMessages.add('Missing "repository"');
    } else {
      final String relativePackagePath =
          getRelativePosixPath(package.directory, from: packagesDir.parent);
      if (!pubspec.repository!.path.endsWith(relativePackagePath)) {
        errorMessages
            .add('The "repository" link should end with the package path.');
      }

      if (pubspec.repository!.path.contains('/master/')) {
        errorMessages
            .add('The "repository" link should use "main", not "master".');
      }
    }

    if (pubspec.homepage != null) {
      errorMessages
          .add('Found a "homepage" entry; only "repository" should be used.');
    }

    return errorMessages;
  }

  // Validates the "description" field for a package, returning an error
  // string if there are any issues.
  String? _checkDescription(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    final String? description = pubspec.description;
    if (description == null) {
      return 'Missing "description"';
    }

    if (description.length < 60) {
      return '"description" is too short. pub.dev recommends package '
          'descriptions of 60-180 characters.';
    }
    if (description.length > 180) {
      return '"description" is too long. pub.dev recommends package '
          'descriptions of 60-180 characters.';
    }
    return null;
  }

  bool _checkIssueLink(Pubspec pubspec) {
    return pubspec.issueTracker
            ?.toString()
            .startsWith(_expectedIssueLinkFormat) ??
        false;
  }

  // Validates the "implements" keyword for a plugin, returning an error
  // string if there are any issues.
  //
  // Should only be called on plugin packages.
  String? _checkForImplementsError(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    if (_isImplementationPackage(package)) {
      final String? implements =
          pubspec.flutter!['plugin']!['implements'] as String?;
      final String expectedImplements = package.directory.parent.basename;
      if (implements == null) {
        return 'Missing "implements: $expectedImplements" in "plugin" section.';
      } else if (implements != expectedImplements) {
        return 'Expecetd "implements: $expectedImplements"; '
            'found "implements: $implements".';
      }
    }
    return null;
  }

  // Validates any "default_package" entries a plugin, returning an error
  // string if there are any issues.
  //
  // Should only be called on plugin packages.
  String? _checkForDefaultPackageError(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    final dynamic platformsEntry = pubspec.flutter!['plugin']!['platforms'];
    if (platformsEntry == null) {
      logWarning('Does not implement any platforms');
      return null;
    }
    final YamlMap platforms = platformsEntry as YamlMap;
    final String packageName = package.directory.basename;

    // Validate that the default_package entries look correct (e.g., no typos).
    final Set<String> defaultPackages = <String>{};
    for (final MapEntry<dynamic, dynamic> platformEntry in platforms.entries) {
      final String? defaultPackage =
          platformEntry.value['default_package'] as String?;
      if (defaultPackage != null) {
        defaultPackages.add(defaultPackage);
        if (!defaultPackage.startsWith('${packageName}_')) {
          return '"$defaultPackage" is not an expected implementation name '
              'for "$packageName"';
        }
      }
    }

    // Validate that all default_packages are also dependencies.
    final Iterable<String> dependencies = pubspec.dependencies.keys;
    final Iterable<String> missingPackages = defaultPackages
        .where((String package) => !dependencies.contains(package));
    if (missingPackages.isNotEmpty) {
      return 'The following default_packages are missing '
          'corresponding dependencies:\n'
          '  ${missingPackages.join('\n  ')}';
    }

    return null;
  }

  // Returns true if [packageName] appears to be an implementation package
  // according to repository conventions.
  bool _isImplementationPackage(RepositoryPackage package) {
    if (!package.isFederated) {
      return false;
    }
    final String packageName = package.directory.basename;
    final String parentName = package.directory.parent.basename;
    // A few known package names are not implementation packages; assume
    // anything else is. (This is done instead of listing known implementation
    // suffixes to allow for non-standard suffixes; e.g., to put several
    // platforms in one package for code-sharing purposes.)
    const Set<String> nonImplementationSuffixes = <String>{
      '', // App-facing package.
      '_platform_interface', // Platform interface package.
    };
    final String suffix = packageName.substring(parentName.length);
    return !nonImplementationSuffixes.contains(suffix);
  }
}
