// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// A command to enforce README conventions across the repository.
class ReadmeCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the README check command.
  ReadmeCheckCommand(
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

  // Standardized capitalizations for platforms that a plugin can support.
  static const Map<String, String> _standardPlatformNames = <String, String>{
    'android': 'Android',
    'ios': 'iOS',
    'linux': 'Linux',
    'macos': 'macOS',
    'web': 'Web',
    'windows': 'Windows',
  };

  @override
  final String name = 'readme-check';

  @override
  final String description =
      'Checks that READMEs follow repository conventions.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final File readme = package.readmeFile;

    if (!readme.existsSync()) {
      return PackageResult.fail(<String>['Missing README.md']);
    }

    final List<String> errors = <String>[];

    final Pubspec pubspec = package.parsePubspec();
    final bool isPlugin = pubspec.flutter?['plugin'] != null;

    if (isPlugin && (!package.isFederated || package.isAppFacing)) {
      final String? error = _validateSupportedPlatforms(package, pubspec);
      if (error != null) {
        errors.add(error);
      }
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  /// Validates that the plugin has a supported platforms table following the
  /// expected format, returning an error string if any issues are found.
  String? _validateSupportedPlatforms(
      RepositoryPackage package, Pubspec pubspec) {
    final List<String> contents = package.readmeFile.readAsLinesSync();

    // Example table following expected format:
    // |                | Android | iOS      | Web                    |
    // |----------------|---------|----------|------------------------|
    // | **Support**    | SDK 21+ | iOS 10+* | [See `camera_web `][1] |
    final int detailsLineNumber =
        contents.indexWhere((String line) => line.startsWith('| **Support**'));
    if (detailsLineNumber == -1) {
      return 'No OS support table found';
    }
    final int osLineNumber = detailsLineNumber - 2;
    if (osLineNumber < 0 || !contents[osLineNumber].startsWith('|')) {
      return 'OS support table does not have the expected header format';
    }

    // Utility method to convert an iterable of strings to a case-insensitive
    // sorted, comma-separated string of its elements.
    String sortedListString(Iterable<String> entries) {
      final List<String> entryList = entries.toList();
      entryList.sort(
          (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return entryList.join(', ');
    }

    // Validate that the supported OS lists match.
    final dynamic platformsEntry = pubspec.flutter!['plugin']!['platforms'];
    if (platformsEntry == null) {
      logWarning('Plugin not support any platforms');
      return null;
    }
    final YamlMap platformSupportMaps = platformsEntry as YamlMap;
    final Set<String> actuallySupportedPlatform =
        platformSupportMaps.keys.toSet().cast<String>();
    final Iterable<String> documentedPlatforms = contents[osLineNumber]
        .split('|')
        .map((String entry) => entry.trim())
        .where((String entry) => entry.isNotEmpty);
    final Set<String> documentedPlatformsLowercase =
        documentedPlatforms.map((String entry) => entry.toLowerCase()).toSet();
    if (actuallySupportedPlatform.length != documentedPlatforms.length ||
        actuallySupportedPlatform
                .intersection(documentedPlatformsLowercase)
                .length !=
            actuallySupportedPlatform.length) {
      printError('''
${indentation}OS support table does not match supported platforms:
${indentation * 2}Actual:     ${sortedListString(actuallySupportedPlatform)}
${indentation * 2}Documented: ${sortedListString(documentedPlatformsLowercase)}
''');
      return 'Incorrect OS support table';
    }

    // Enforce a standard set of capitalizations for the OS headings.
    final Iterable<String> incorrectCapitalizations = documentedPlatforms
        .toSet()
        .difference(_standardPlatformNames.values.toSet());
    if (incorrectCapitalizations.isNotEmpty) {
      final Iterable<String> expectedVersions = incorrectCapitalizations
          .map((String name) => _standardPlatformNames[name.toLowerCase()]!);
      printError('''
${indentation}Incorrect OS capitalization: ${sortedListString(incorrectCapitalizations)}
${indentation * 2}Please use standard capitalizations: ${sortedListString(expectedVersions)}
''');
      return 'Incorrect OS support formatting';
    }

    // TODO(stuartmorgan): Add validation that the minimums in the table are
    // consistent with what the current implementations require. See
    // https://github.com/flutter/flutter/issues/84200
    return null;
  }
}
