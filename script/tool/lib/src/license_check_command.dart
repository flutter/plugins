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
      dotAll: true),
  // bsdiff in flutter/packages.
  RegExp(r'// Copyright 2003-2005 Colin Percival\. All rights reserved\.\n'
      r'// Use of this source code is governed by a BSD-style license that can be\n'
      r'// found in the LICENSE file\.\n'),
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
  LicenseCheckCommand(
    Directory packagesDir, {
    Print print = print,
  })  : _print = print,
        super(packagesDir);

  final Print _print;

  @override
  final String name = 'license-check';

  @override
  final String description =
      'Ensures that all code files have copyright/license blocks.';

  @override
  Future<void> run() async {
    final Iterable<File> codeFiles = (await _getAllFiles()).where((File file) =>
        _codeFileExtensions.contains(p.extension(file.path)) &&
        !_shouldIgnoreFile(file));
    final Iterable<File> firstPartyLicenseFiles = (await _getAllFiles()).where(
        (File file) =>
            p.basename(file.basename) == 'LICENSE' && !_isThirdParty(file));

    final bool copyrightCheckSucceeded = await _checkCodeLicenses(codeFiles);
    _print('\n=======================================\n');
    final bool licenseCheckSucceeded =
        await _checkLicenseFiles(firstPartyLicenseFiles);

    if (!copyrightCheckSucceeded || !licenseCheckSucceeded) {
      throw ToolExit(1);
    }
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

  // Checks all license blocks for [codeFiles], returning false if any of them
  // fail validation.
  Future<bool> _checkCodeLicenses(Iterable<File> codeFiles) async {
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
      _print('Checking ${file.path}');
      final String content = await file.readAsString();

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
    _print('\n');

    // Sort by path for more usable output.
    final int Function(File, File) pathCompare =
        (File a, File b) => a.path.compareTo(b.path);
    incorrectFirstPartyFiles.sort(pathCompare);
    unrecognizedThirdPartyFiles.sort(pathCompare);

    if (incorrectFirstPartyFiles.isNotEmpty) {
      _print('The license block for these files is missing or incorrect:');
      for (final File file in incorrectFirstPartyFiles) {
        _print('  ${file.path}');
      }
      _print('If this third-party code, move it to a "third_party/" directory, '
          'otherwise ensure that you are using the exact copyright and license '
          'text used by all first-party files in this repository.\n');
    }

    if (unrecognizedThirdPartyFiles.isNotEmpty) {
      _print(
          'No recognized license was found for the following third-party files:');
      for (final File file in unrecognizedThirdPartyFiles) {
        _print('  ${file.path}');
      }
      _print('Please check that they have a license at the top of the file. '
          'If they do, the license check needs to be updated to recognize '
          'the new third-party license block.\n');
    }

    final bool succeeded =
        incorrectFirstPartyFiles.isEmpty && unrecognizedThirdPartyFiles.isEmpty;
    if (succeeded) {
      _print('All source files passed validation!');
    }
    return succeeded;
  }

  // Checks all provide LICENSE files, returning false if any of them
  // fail validation.
  Future<bool> _checkLicenseFiles(Iterable<File> files) async {
    final List<File> incorrectLicenseFiles = <File>[];

    for (final File file in files) {
      _print('Checking ${file.path}');
      if (!file.readAsStringSync().contains(_fullBsdLicenseText)) {
        incorrectLicenseFiles.add(file);
      }
    }
    _print('\n');

    if (incorrectLicenseFiles.isNotEmpty) {
      _print('The following LICENSE files do not follow the expected format:');
      for (final File file in incorrectLicenseFiles) {
        _print('  ${file.path}');
      }
      _print(
          'Please ensure that they use the exact format used in this repository".\n');
    }

    final bool succeeded = incorrectLicenseFiles.isEmpty;
    if (succeeded) {
      _print('All LICENSE files passed validation!');
    }
    return succeeded;
  }

  bool _shouldIgnoreFile(File file) {
    final String path = file.path;
    return _ignoreBasenameList.contains(p.basenameWithoutExtension(path)) ||
        _ignoreSuffixList.any((String suffix) =>
            path.endsWith(suffix) ||
            _ignoredFullBasenameList.contains(p.basename(path)));
  }

  bool _isThirdParty(File file) {
    return p.split(file.path).contains('third_party');
  }

  Future<List<File>> _getAllFiles() => packagesDir.parent
      .list(recursive: true, followLinks: false)
      .where((FileSystemEntity entity) => entity is File)
      .map((FileSystemEntity file) => file as File)
      .toList();
}
