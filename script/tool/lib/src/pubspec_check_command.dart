// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';

import 'common.dart';

/// A command to enforce pubspec conventions across the repository.
///
/// This both ensures that repo best practices for which optional fields are
/// used are followed, and that the structure is consistent to make edits
/// across multiple pubspec files easier.
class PubspecCheckCommand extends PluginCommand {
  /// Creates an instance of the version check command.
  PubspecCheckCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    GitDir? gitDir,
  }) : super(packagesDir, processRunner: processRunner, gitDir: gitDir);

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
  Future<void> run() async {
    final List<String> failingPackages = <String>[];
    await for (final Directory package in getPackages()) {
      final String relativePackagePath =
          p.relative(package.path, from: packagesDir.path);
      print('Checking $relativePackagePath...');
      final File pubspec = package.childFile('pubspec.yaml');
      final bool passesCheck = !pubspec.existsSync() ||
          await _checkPubspec(pubspec, packageName: package.basename);
      if (!passesCheck) {
        failingPackages.add(relativePackagePath);
      }
    }

    if (failingPackages.isNotEmpty) {
      print('The following packages have pubspec issues:');
      for (final String package in failingPackages) {
        print('  $package');
      }
      throw ToolExit(1);
    }

    print('\nNo pubspec issues found!');
  }

  Future<bool> _checkPubspec(
    File pubspecFile, {
    required String packageName,
  }) async {
    const String indentation = '  ';
    final String contents = pubspecFile.readAsStringSync();
    final Pubspec? pubspec = _tryParsePubspec(contents);
    if (pubspec == null) {
      return false;
    }

    final List<String> pubspecLines = contents.split('\n');
    final List<String> sectionOrder = pubspecLines.contains('  plugin:')
        ? _majorPluginSections
        : _majorPackageSections;
    bool passing = _checkSectionOrder(pubspecLines, sectionOrder);
    if (!passing) {
      print('${indentation}Major sections should follow standard '
          'repository ordering:');
      final String listIndentation = indentation * 2;
      print('$listIndentation${sectionOrder.join('\n$listIndentation')}');
    }

    if (pubspec.publishTo != 'none') {
      final List<String> repositoryErrors =
          _checkForRepositoryLinkErrors(pubspec, packageName: packageName);
      if (repositoryErrors.isNotEmpty) {
        for (final String error in repositoryErrors) {
          print('$indentation$error');
        }
        passing = false;
      }

      if (!_checkIssueLink(pubspec)) {
        print(
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
    required String packageName,
  }) {
    final List<String> errorMessages = <String>[];
    if (pubspec.repository == null) {
      errorMessages.add('Missing "repository"');
    } else if (!pubspec.repository!.path.endsWith(packageName)) {
      errorMessages
          .add('The "repository" link should end with the package name.');
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
}
