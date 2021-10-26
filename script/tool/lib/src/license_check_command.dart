// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/plugin_command.dart';

const Set<String> _codeFileExtensions = <String>{
  '.c',
  '.cc',
  '.cpp',
  '.dart',
  '.h',
  '.html',
  '.java',
  '.kt',
  '.m',
  '.mm',
  '.swift',
  '.sh',
};

// Basenames without extensions of files to ignore.
const Set<String> _ignoreBasenameList = <String>{
  'flutter_export_environment',
  'GeneratedPluginRegistrant',
  'generated_plugin_registrant',
};

// File suffixes that otherwise match _codeFileExtensions to ignore.
const Set<String> _ignoreSuffixList = <String>{
  '.g.dart', // Generated API code.
  '.mocks.dart', // Generated by Mockito.
};

// Full basenames of files to ignore.
const Set<String> _ignoredFullBasenameList = <String>{
  'resource.h', // Generated by VS.
};

// Copyright and license regexes for third-party code.
//
// These are intentionally very simple, since there is very little third-party
// code in this repository. Complexity can be added as-needed on a case-by-case
// basis.
//
// When adding license regexes here, include the copyright info to ensure that
// any new additions are flagged for added scrutiny in review.
final List<RegExp> _thirdPartyLicenseBlockRegexes = <RegExp>[
  // Third-party code used in url_launcher_web.
  RegExp(
    r'^// Copyright 2017 Workiva Inc\..*'
    r'^// Licensed under the Apache License, Version 2\.0',
    multiLine: true,
    dotAll: true,
  ),
  // Third-party code used in google_maps_flutter_web.
  RegExp(
    r'^// The MIT License [^C]+ Copyright \(c\) 2008 Krasimir Tsonev',
    multiLine: true,
  ),
  // bsdiff in flutter/packages.
  RegExp(
    r'// Copyright 2003-2005 Colin Percival\. All rights reserved\.\n'
    r'// Use of this source code is governed by a BSD-style license that can be\n'
    r'// found in the LICENSE file\.\n',
  ),
];

// The exact format of the BSD license that our license files should contain.
// Slight variants are not accepted because they may prevent consolidation in
// tools that assemble all licenses used in distributed applications.
// standardized.
const String _fullBsdLicenseText = '''
Copyright 2013 The Flutter Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
''';

/// Validates that code files have copyright and license blocks.
class LicenseCheckCommand extends PluginCommand {
  /// Creates a new license check command for [packagesDir].
  LicenseCheckCommand(Directory packagesDir) : super(packagesDir);

  @override
  final String name = 'license-check';

  @override
  final String description =
      'Ensures that all code files have copyright/license blocks.';

  @override
  Future<void> run() async {
    final Iterable<File> allFiles = await _getAllFiles();

    final Iterable<File> codeFiles = allFiles.where((File file) =>
        _codeFileExtensions.contains(p.extension(file.path)) &&
        !_shouldIgnoreFile(file));
    final Iterable<File> firstPartyLicenseFiles = allFiles.where((File file) =>
        path.basename(file.basename) == 'LICENSE' && !_isThirdParty(file));

    final List<File> licenseFileFailures =
        await _checkLicenseFiles(firstPartyLicenseFiles);
    final Map<_LicenseFailureType, List<File>> codeFileFailures =
        await _checkCodeLicenses(codeFiles);

    bool passed = true;

    print('\n=======================================\n');

    if (licenseFileFailures.isNotEmpty) {
      passed = false;
      printError(
          'The following LICENSE files do not follow the expected format:');
      for (final File file in licenseFileFailures) {
        printError('  ${file.path}');
      }
      printError('Please ensure that they use the exact format used in this '
          'repository".\n');
    }

    if (codeFileFailures[_LicenseFailureType.incorrectFirstParty]!.isNotEmpty) {
      passed = false;
      printError('The license block for these files is missing or incorrect:');
      for (final File file
          in codeFileFailures[_LicenseFailureType.incorrectFirstParty]!) {
        printError('  ${file.path}');
      }
      printError(
          'If this third-party code, move it to a "third_party/" directory, '
          'otherwise ensure that you are using the exact copyright and license '
          'text used by all first-party files in this repository.\n');
    }

    if (codeFileFailures[_LicenseFailureType.unknownThirdParty]!.isNotEmpty) {
      passed = false;
      printError(
          'No recognized license was found for the following third-party files:');
      for (final File file
          in codeFileFailures[_LicenseFailureType.unknownThirdParty]!) {
        printError('  ${file.path}');
      }
      print('Please check that they have a license at the top of the file. '
          'If they do, the license check needs to be updated to recognize '
          'the new third-party license block.\n');
    }

    if (!passed) {
      throw ToolExit(1);
    }

    printSuccess('All files passed validation!');
  }

  // Creates the expected copyright+license block for first-party code.
  String _generateLicenseBlock(
    String comment, {
    String prefix = '',
    String suffix = '',
  }) {
    return '$prefix${comment}Copyright 2013 The Flutter Authors. All rights reserved.\n'
        '${comment}Use of this source code is governed by a BSD-style license that can be\n'
        '${comment}found in the LICENSE file.$suffix\n';
  }

  /// Checks all license blocks for [codeFiles], returning any that fail
  /// validation.
  Future<Map<_LicenseFailureType, List<File>>> _checkCodeLicenses(
      Iterable<File> codeFiles) async {
    final List<File> incorrectFirstPartyFiles = <File>[];
    final List<File> unrecognizedThirdPartyFiles = <File>[];

    // Most code file types in the repository use '//' comments.
    final String defaultFirstParyLicenseBlock = _generateLicenseBlock('// ');
    // A few file types have a different comment structure.
    final Map<String, String> firstPartyLicenseBlockByExtension =
        <String, String>{
      '.sh': _generateLicenseBlock('# '),
      '.html': _generateLicenseBlock('', prefix: '<!-- ', suffix: ' -->'),
    };

    for (final File file in codeFiles) {
      print('Checking ${file.path}');
      // On Windows, git may auto-convert line endings on checkout; this should
      // still pass since they will be converted back on commit.
      final String content =
          (await file.readAsString()).replaceAll('\r\n', '\n');

      final String firstParyLicense =
          firstPartyLicenseBlockByExtension[p.extension(file.path)] ??
              defaultFirstParyLicenseBlock;
      if (_isThirdParty(file)) {
        // Third-party directories allow either known third-party licenses, our
        // the first-party license, as there may be local additions.
        if (!_thirdPartyLicenseBlockRegexes
                .any((RegExp regex) => regex.hasMatch(content)) &&
            !content.contains(firstParyLicense)) {
          unrecognizedThirdPartyFiles.add(file);
        }
      } else {
        if (!content.contains(firstParyLicense)) {
          incorrectFirstPartyFiles.add(file);
        }
      }
    }

    // Sort by path for more usable output.
    final int Function(File, File) pathCompare =
        (File a, File b) => a.path.compareTo(b.path);
    incorrectFirstPartyFiles.sort(pathCompare);
    unrecognizedThirdPartyFiles.sort(pathCompare);

    return <_LicenseFailureType, List<File>>{
      _LicenseFailureType.incorrectFirstParty: incorrectFirstPartyFiles,
      _LicenseFailureType.unknownThirdParty: unrecognizedThirdPartyFiles,
    };
  }

  /// Checks all provided LICENSE [files], returning any that fail validation.
  Future<List<File>> _checkLicenseFiles(Iterable<File> files) async {
    final List<File> incorrectLicenseFiles = <File>[];

    for (final File file in files) {
      print('Checking ${file.path}');
      // On Windows, git may auto-convert line endings on checkout; this should
      // still pass since they will be converted back on commit.
      final String contents = file.readAsStringSync().replaceAll('\r\n', '\n');
      if (!contents.contains(_fullBsdLicenseText)) {
        incorrectLicenseFiles.add(file);
      }
    }

    return incorrectLicenseFiles;
  }

  bool _shouldIgnoreFile(File file) {
    final String path = file.path;
    return _ignoreBasenameList.contains(p.basenameWithoutExtension(path)) ||
        _ignoreSuffixList.any((String suffix) =>
            path.endsWith(suffix) ||
            _ignoredFullBasenameList.contains(p.basename(path)));
  }

  bool _isThirdParty(File file) {
    return path.split(file.path).contains('third_party');
  }

  Future<List<File>> _getAllFiles() => packagesDir.parent
      .list(recursive: true, followLinks: false)
      .where((FileSystemEntity entity) => entity is File)
      .map((FileSystemEntity file) => file as File)
      .toList();
}

enum _LicenseFailureType { incorrectFirstParty, unknownThirdParty }
