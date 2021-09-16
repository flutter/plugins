// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

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
  ];

  static const List<String> _majorPackageSections = <String>[
    'environment:',
    'dependencies:',
    'dev_dependencies:',
    'flutter:',
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
  bool get includeSubpackages => true;

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
      final String? error = _checkForImplementsError(pubspec, package: package);
      if (error != null) {
        printError('$indentation$error');
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
          path.relative(package.path, from: packagesDir.parent.path);
      if (!pubspec.repository!.path.endsWith(relativePackagePath)) {
        errorMessages
            .add('The "repository" link should end with the package path.');
      }
    }

    if (pubspec.homepage != null) {
      errorMessages
          .add('Found a "homepage" entry; only "repository" should be used.');
    }

    return errorMessages;
  }

  bool _checkIssueLink(Pubspec pubspec) {
    return pubspec.issueTracker
            ?.toString()
            .startsWith(_expectedIssueLinkFormat) ==
        true;
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

  // Returns true if [packageName] appears to be an implementation package
  // according to repository conventions.
  bool _isImplementationPackage(RepositoryPackage package) {
    // An implementation package should be in a group folder...
    final Directory parentDir = package.directory.parent;
    if (parentDir.path == packagesDir.path) {
      return false;
    }
    final String packageName = package.directory.basename;
    final String parentName = parentDir.basename;
    // ... whose name is a prefix of the package name.
    if (!packageName.startsWith(parentName)) {
      return false;
    }
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
