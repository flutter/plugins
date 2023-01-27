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

const String _instructionWikiUrl =
    'https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages';

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
        ) {
    argParser.addFlag(_requireExcerptsArg,
        help: 'Require that Dart code blocks be managed by code-excerpt.');
  }

  static const String _requireExcerptsArg = 'require-excerpts';

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
    final List<String> errors = _validateReadme(package.readmeFile,
        mainPackage: package, isExample: false);
    for (final RepositoryPackage packageToCheck in package.getExamples()) {
      errors.addAll(_validateReadme(packageToCheck.readmeFile,
          mainPackage: package, isExample: true));
    }

    // If there's an example/README.md for a multi-example package, validate
    // that as well, as it will be shown on pub.dev.
    final Directory exampleDir = package.directory.childDirectory('example');
    final File exampleDirReadme = exampleDir.childFile('README.md');
    if (exampleDir.existsSync() && !isPackage(exampleDir)) {
      errors.addAll(_validateReadme(exampleDirReadme,
          mainPackage: package, isExample: true));
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  List<String> _validateReadme(File readme,
      {required RepositoryPackage mainPackage, required bool isExample}) {
    if (!readme.existsSync()) {
      if (isExample) {
        print('${indentation}No README for '
            '${getRelativePosixPath(readme.parent, from: mainPackage.directory)}');
        return <String>[];
      } else {
        printError('${indentation}No README found at '
            '${getRelativePosixPath(readme, from: mainPackage.directory)}');
        return <String>['Missing README.md'];
      }
    }

    print('${indentation}Checking '
        '${getRelativePosixPath(readme, from: mainPackage.directory)}...');

    final List<String> readmeLines = readme.readAsLinesSync();
    final List<String> errors = <String>[];

    final String? blockValidationError =
        _validateCodeBlocks(readmeLines, mainPackage: mainPackage);
    if (blockValidationError != null) {
      errors.add(blockValidationError);
    }

    errors.addAll(_validateBoilerplate(readmeLines,
        mainPackage: mainPackage, isExample: isExample));

    // Check if this is the main readme for a plugin, and if so enforce extra
    // checks.
    if (!isExample) {
      final Pubspec pubspec = mainPackage.parsePubspec();
      final bool isPlugin = pubspec.flutter?['plugin'] != null;
      if (isPlugin && (!mainPackage.isFederated || mainPackage.isAppFacing)) {
        final String? error = _validateSupportedPlatforms(readmeLines, pubspec);
        if (error != null) {
          errors.add(error);
        }
      }
    }

    return errors;
  }

  /// Validates that code blocks (``` ... ```) follow repository standards.
  String? _validateCodeBlocks(
    List<String> readmeLines, {
    required RepositoryPackage mainPackage,
  }) {
    final RegExp codeBlockDelimiterPattern = RegExp(r'^\s*```\s*([^ ]*)\s*');
    const String excerptTagStart = '<?code-excerpt ';
    final List<int> missingLanguageLines = <int>[];
    final List<int> missingExcerptLines = <int>[];
    bool inBlock = false;
    for (int i = 0; i < readmeLines.length; ++i) {
      final RegExpMatch? match =
          codeBlockDelimiterPattern.firstMatch(readmeLines[i]);
      if (match == null) {
        continue;
      }
      if (inBlock) {
        inBlock = false;
        continue;
      }
      inBlock = true;

      final int humanReadableLineNumber = i + 1;

      // Ensure that there's a language tag.
      final String infoString = match[1] ?? '';
      if (infoString.isEmpty) {
        missingLanguageLines.add(humanReadableLineNumber);
        continue;
      }

      // Check for code-excerpt usage if requested.
      if (getBoolArg(_requireExcerptsArg) && infoString == 'dart') {
        if (i == 0 || !readmeLines[i - 1].trim().startsWith(excerptTagStart)) {
          missingExcerptLines.add(humanReadableLineNumber);
        }
      }
    }

    String? errorSummary;

    if (missingLanguageLines.isNotEmpty) {
      for (final int lineNumber in missingLanguageLines) {
        printError('${indentation}Code block at line $lineNumber is missing '
            'a language identifier.');
      }
      printError(
          '\n${indentation}For each block listed above, add a language tag to '
          'the opening block. For instance, for Dart code, use:\n'
          '${indentation * 2}```dart\n');
      errorSummary = 'Missing language identifier for code block';
    }

    // If any blocks use code excerpts, make sure excerpting is configured
    // for the package.
    if (readmeLines.any((String line) => line.startsWith(excerptTagStart))) {
      const String buildRunnerConfigFile = 'build.excerpt.yaml';
      if (!mainPackage.getExamples().any((RepositoryPackage example) =>
          example.directory.childFile(buildRunnerConfigFile).existsSync())) {
        printError('code-excerpt tag found, but the package is not configured '
            'for excerpting. Follow the instructions at\n'
            '$_instructionWikiUrl\n'
            'for setting up a build.excerpt.yaml file.');
        errorSummary ??= 'Missing code-excerpt configuration';
      }
    }

    if (missingExcerptLines.isNotEmpty) {
      for (final int lineNumber in missingExcerptLines) {
        printError('${indentation}Dart code block at line $lineNumber is not '
            'managed by code-excerpt.');
      }
      printError(
          '\n${indentation}For each block listed above, add <?code-excerpt ...> '
          'tag on the previous line, and ensure that a build.excerpt.yaml is '
          'configured for the source example as explained at\n'
          '$_instructionWikiUrl');
      errorSummary ??= 'Missing code-excerpt management for code block';
    }

    return errorSummary;
  }

  /// Validates that the plugin has a supported platforms table following the
  /// expected format, returning an error string if any issues are found.
  String? _validateSupportedPlatforms(
      List<String> readmeLines, Pubspec pubspec) {
    // Example table following expected format:
    // |                | Android | iOS      | Web                    |
    // |----------------|---------|----------|------------------------|
    // | **Support**    | SDK 21+ | iOS 10+* | [See `camera_web `][1] |
    final int detailsLineNumber = readmeLines
        .indexWhere((String line) => line.startsWith('| **Support**'));
    if (detailsLineNumber == -1) {
      return 'No OS support table found';
    }
    final int osLineNumber = detailsLineNumber - 2;
    if (osLineNumber < 0 || !readmeLines[osLineNumber].startsWith('|')) {
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
    final YamlMap pluginSection = pubspec.flutter!['plugin'] as YamlMap;
    final dynamic platformsEntry = pluginSection['platforms'];
    if (platformsEntry == null) {
      logWarning('Plugin not support any platforms');
      return null;
    }
    final YamlMap platformSupportMaps = platformsEntry as YamlMap;
    final Set<String> actuallySupportedPlatform =
        platformSupportMaps.keys.toSet().cast<String>();
    final Iterable<String> documentedPlatforms = readmeLines[osLineNumber]
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

  /// Validates [readmeLines], outputing error messages for any issue and
  /// returning an array of error summaries (if any).
  ///
  /// Returns an empty array if validation passes.
  List<String> _validateBoilerplate(
    List<String> readmeLines, {
    required RepositoryPackage mainPackage,
    required bool isExample,
  }) {
    final List<String> errors = <String>[];

    if (_containsTemplateFlutterBoilerplate(readmeLines)) {
      printError('${indentation}The boilerplate section about getting started '
          'with Flutter should not be left in.');
      errors.add('Contains template boilerplate');
    }

    // Enforce a repository-standard message in implementation plugin examples,
    // since they aren't typical examples, which has been a source of
    // confusion for plugin clients who find them.
    if (isExample && mainPackage.isPlatformImplementation) {
      if (_containsExampleBoilerplate(readmeLines)) {
        printError('${indentation}The boilerplate should not be left in for a '
            "federated plugin implementation package's example.");
        errors.add('Contains template boilerplate');
      }
      if (!_containsImplementationExampleExplanation(readmeLines)) {
        printError('${indentation}The example README for a platform '
            'implementation package should warn readers about its intended '
            'use. Please copy the example README from another implementation '
            'package in this repository.');
        errors.add('Missing implementation package example warning');
      }
    }

    return errors;
  }

  /// Returns true if the README still has unwanted parts of the boilerplate
  /// from the `flutter create` templates.
  bool _containsTemplateFlutterBoilerplate(List<String> readmeLines) {
    return readmeLines.any((String line) =>
        line.contains('For help getting started with Flutter'));
  }

  /// Returns true if the README still has the generic description of an
  /// example from the `flutter create` templates.
  bool _containsExampleBoilerplate(List<String> readmeLines) {
    return readmeLines
        .any((String line) => line.contains('Demonstrates how to use the'));
  }

  /// Returns true if the README contains the repository-standard explanation of
  /// the purpose of a federated plugin implementation's example.
  bool _containsImplementationExampleExplanation(List<String> readmeLines) {
    return readmeLines.contains('# Platform Implementation Test App') &&
        readmeLines
            .any((String line) => line.contains('This is a test app for'));
  }
}
