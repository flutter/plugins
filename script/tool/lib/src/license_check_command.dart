// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

const Set<String> _codeFileExtensions = <String>{
  '.c',
  '.cc',
  '.dart',
  '.java',
  '.m',
  '.mm',
  '.swift',
  '.sh',
};

// Basenames with extensions of files to ignore.
const Set<String> _ignoreList = <String>{
  'flutter_export_environment',
  'GeneratedPluginRegistrant',
  'generated_plugin_registrant',
};

// Copyright and license regexes.
//
// These are intentionally very simple, since almost all source in this
// repository should be using the same license text, comment style, etc., so
// they shouldn't need to be very flexible. Complexity can be added as-needed
// on a case-by-case basis.
final RegExp _copyrightRegex = RegExp(r'^// Copyright', multiLine: true);
final RegExp _bsdLicenseRegex = RegExp(
    r'^// Use of this source code is governed by a BSD-style license',
    multiLine: true);

/// Validates that code files have copyright and license blocks.
class LicenseCheckCommand extends PluginCommand {
  /// Creates a new license check command for [packagesDir].
  LicenseCheckCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addFlag('changed-only',
        help:
            'Checks only files changed on this branch, rather than all files.');
  }

  @override
  final String name = 'license-check';

  @override
  final String description =
      'Ensures that all code files have copyright/license blocks.';

  @override
  Future<Null> run() async {
    Iterable<File> codeFiles =
        (argResults['changed-only'] ? <File>[/* TODO */] : await _getAllFiles())
            .where((File file) =>
                _codeFileExtensions.contains(p.extension(file.path)) &&
                !_ignoreList.contains(p.basenameWithoutExtension(file.path)));

    bool succeeded = await _checkLicenses(codeFiles);

    if (!succeeded) {
      throw ToolExit(1);
    }
  }

  // Checks all license blocks for [codeFiles], returning false if any of them
  // fail validation.
  Future<bool> _checkLicenses(Iterable<File> codeFiles) async {
    final List<File> filesWithoutDetectedCopyright = <File>[];
    final List<File> filesWithoutDetectedLicense = <File>[];
    for (final File file in codeFiles) {
      print('Checking ${file.path}...');
      final String content = await file.readAsString();

      if (!_copyrightRegex.hasMatch(content)) {
        filesWithoutDetectedCopyright.add(file);
        continue;
      }

      if (!_bsdLicenseRegex.hasMatch(content)) {
        filesWithoutDetectedLicense.add(file);
      }
    }
    print('\n\n');

    if (filesWithoutDetectedCopyright.isNotEmpty) {
      print('No copyright line was found for the following files:');
      for (final File file in filesWithoutDetectedCopyright) {
        print('  ${file.path}');
      }
      print('Please check that they have a copyright and license block. '
          'If they do, the license check may need to be updated to recognize its '
          'format.\n\n');
    }

    if (filesWithoutDetectedLicense.isNotEmpty) {
      print('No license block was found for the following files:');
      for (final File file in filesWithoutDetectedLicense) {
        print('  ${file.path}');
      }
      print('Please check that they have a license block. '
          'If they do, the license check may need to be updated to recognize '
          'either the license or the specific format of the license '
          'block.\n\n');
    }

    bool succeeded = filesWithoutDetectedCopyright.isEmpty &&
        filesWithoutDetectedLicense.isEmpty;
    if (succeeded) {
      print('All files passed validation!');
    }

    return filesWithoutDetectedCopyright.isEmpty &&
        filesWithoutDetectedLicense.isEmpty;
  }

  Future<List<File>> _getAllFiles() => packagesDir.parent
      .list(recursive: true, followLinks: false)
      .where((FileSystemEntity entity) => entity is File)
      .map((FileSystemEntity file) => file as File)
      .toList();
}
