// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/license_check_command.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  group('LicenseCheckCommand', () {
    late CommandRunner<void> runner;
    late FileSystem fileSystem;
    late Platform platform;
    late Directory root;

    setUp(() {
      fileSystem = MemoryFileSystem();
      platform = MockPlatformWithSeparator();
      final Directory packagesDir =
          fileSystem.currentDirectory.childDirectory('packages');
      root = packagesDir.parent;

      final MockGitDir gitDir = MockGitDir();
      when(gitDir.path).thenReturn(packagesDir.parent.path);

      final LicenseCheckCommand command = LicenseCheckCommand(
        packagesDir,
        platform: platform,
        gitDir: gitDir,
      );
      runner =
          CommandRunner<void>('license_test', 'Test for $LicenseCheckCommand');
      runner.addCommand(command);
    });

    /// Writes a copyright+license block to [file], defaulting to a standard
    /// block for this repository.
    ///
    /// [commentString] is added to the start of each line.
    /// [prefix] is added to the start of the entire block.
    /// [suffix] is added to the end of the entire block.
    void _writeLicense(
      File file, {
      String comment = '// ',
      String prefix = '',
      String suffix = '',
      String copyright =
          'Copyright 2013 The Flutter Authors. All rights reserved.',
      List<String> license = const <String>[
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
      bool useCrlf = false,
    }) {
      final List<String> lines = <String>['$prefix$comment$copyright'];
      for (final String line in license) {
        lines.add('$comment$line');
      }
      final String newline = useCrlf ? '\r\n' : '\n';
      file.writeAsStringSync(lines.join(newline) + suffix + newline);
    }

    test('looks at only expected extensions', () async {
      final Map<String, bool> extensions = <String, bool>{
        'c': true,
        'cc': true,
        'cpp': true,
        'dart': true,
        'h': true,
        'html': true,
        'java': true,
        'json': false,
        'kt': true,
        'm': true,
        'md': false,
        'mm': true,
        'png': false,
        'swift': true,
        'sh': true,
        'yaml': false,
      };

      const String filenameBase = 'a_file';
      for (final String fileExtension in extensions.keys) {
        root.childFile('$filenameBase.$fileExtension').createSync();
      }

      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        // Ignore failure; the files are empty so the check is expected to fail,
        // but this test isn't for that behavior.
      });

      extensions.forEach((String fileExtension, bool shouldCheck) {
        final Matcher logLineMatcher =
            contains('Checking $filenameBase.$fileExtension');
        expect(output, shouldCheck ? logLineMatcher : isNot(logLineMatcher));
      });
    });

    test('ignore list overrides extension matches', () async {
      final List<String> ignoredFiles = <String>[
        // Ignored base names.
        'flutter_export_environment.sh',
        'GeneratedPluginRegistrant.java',
        'GeneratedPluginRegistrant.m',
        'generated_plugin_registrant.cc',
        'generated_plugin_registrant.cpp',
        // Ignored path suffixes.
        'foo.g.dart',
        'foo.mocks.dart',
        // Ignored files.
        'resource.h',
      ];

      for (final String name in ignoredFiles) {
        root.childFile(name).createSync();
      }

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      for (final String name in ignoredFiles) {
        expect(output, isNot(contains('Checking $name')));
      }
    });

    test('ignores submodules', () async {
      const String submoduleName = 'a_submodule';

      final File submoduleSpec = root.childFile('.gitmodules');
      submoduleSpec.writeAsStringSync('''
[submodule "$submoduleName"]
  path = $submoduleName
  url = https://github.com/foo/$submoduleName
''');

      const List<String> submoduleFiles = <String>[
        '$submoduleName/foo.dart',
        '$submoduleName/a/b/bar.dart',
        '$submoduleName/LICENSE',
      ];
      for (final String filePath in submoduleFiles) {
        root.childFile(filePath).createSync(recursive: true);
      }

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      for (final String filePath in submoduleFiles) {
        expect(output, isNot(contains('Checking $filePath')));
      }
    });

    test('passes if all checked files have license blocks', () async {
      final File checked = root.childFile('checked.cc');
      checked.createSync();
      _writeLicense(checked);
      final File notChecked = root.childFile('not_checked.md');
      notChecked.createSync();

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check a file.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking checked.cc'),
            contains('All files passed validation!'),
          ]));
    });

    test('passes correct license blocks on Windows', () async {
      final File checked = root.childFile('checked.cc');
      checked.createSync();
      _writeLicense(checked, useCrlf: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check a file.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking checked.cc'),
            contains('All files passed validation!'),
          ]));
    });

    test('handles the comment styles for all supported languages', () async {
      final File fileA = root.childFile('file_a.cc');
      fileA.createSync();
      _writeLicense(fileA);
      final File fileB = root.childFile('file_b.sh');
      fileB.createSync();
      _writeLicense(fileB, comment: '# ');
      final File fileC = root.childFile('file_c.html');
      fileC.createSync();
      _writeLicense(fileC, comment: '', prefix: '<!-- ', suffix: ' -->');

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check the files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking file_a.cc'),
            contains('Checking file_b.sh'),
            contains('Checking file_c.html'),
            contains('All files passed validation!'),
          ]));
    });

    test('fails if any checked files are missing license blocks', () async {
      final File goodA = root.childFile('good.cc');
      goodA.createSync();
      _writeLicense(goodA);
      final File goodB = root.childFile('good.h');
      goodB.createSync();
      _writeLicense(goodB);
      root.childFile('bad.cc').createSync();
      root.childFile('bad.h').createSync();

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      // Failure should give information about the problematic files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'The license block for these files is missing or incorrect:'),
            contains('  bad.cc'),
            contains('  bad.h'),
          ]));
      // Failure shouldn't print the success message.
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('fails if any checked files are missing just the copyright', () async {
      final File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      final File bad = root.childFile('bad.cc');
      bad.createSync();
      _writeLicense(bad, copyright: '');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      // Failure should give information about the problematic files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'The license block for these files is missing or incorrect:'),
            contains('  bad.cc'),
          ]));
      // Failure shouldn't print the success message.
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('fails if any checked files are missing just the license', () async {
      final File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      final File bad = root.childFile('bad.cc');
      bad.createSync();
      _writeLicense(bad, license: <String>[]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      // Failure should give information about the problematic files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'The license block for these files is missing or incorrect:'),
            contains('  bad.cc'),
          ]));
      // Failure shouldn't print the success message.
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('fails if any third-party code is not in a third_party directory',
        () async {
      final File thirdPartyFile = root.childFile('third_party.cc');
      thirdPartyFile.createSync();
      _writeLicense(thirdPartyFile, copyright: 'Copyright 2017 Someone Else');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      // Failure should give information about the problematic files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'The license block for these files is missing or incorrect:'),
            contains('  third_party.cc'),
          ]));
      // Failure shouldn't print the success message.
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('succeeds for third-party code in a third_party directory', () async {
      final File thirdPartyFile = root
          .childDirectory('a_plugin')
          .childDirectory('lib')
          .childDirectory('src')
          .childDirectory('third_party')
          .childFile('file.cc');
      thirdPartyFile.createSync(recursive: true);
      _writeLicense(thirdPartyFile,
          copyright: 'Copyright 2017 Workiva Inc.',
          license: <String>[
            'Licensed under the Apache License, Version 2.0 (the "License");',
            'you may not use this file except in compliance with the License.'
          ]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check the file.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking a_plugin/lib/src/third_party/file.cc'),
            contains('All files passed validation!'),
          ]));
    });

    test('allows first-party code in a third_party directory', () async {
      final File firstPartyFileInThirdParty = root
          .childDirectory('a_plugin')
          .childDirectory('lib')
          .childDirectory('src')
          .childDirectory('third_party')
          .childFile('first_party.cc');
      firstPartyFileInThirdParty.createSync(recursive: true);
      _writeLicense(firstPartyFileInThirdParty);

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check the file.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking a_plugin/lib/src/third_party/first_party.cc'),
            contains('All files passed validation!'),
          ]));
    });

    test('fails for licenses that the tool does not expect', () async {
      final File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      final File bad = root.childDirectory('third_party').childFile('bad.cc');
      bad.createSync(recursive: true);
      _writeLicense(bad, license: <String>[
        'This program is free software: you can redistribute it and/or modify',
        'it under the terms of the GNU General Public License',
      ]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      // Failure should give information about the problematic files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'No recognized license was found for the following third-party files:'),
            contains('  third_party/bad.cc'),
          ]));
      // Failure shouldn't print the success message.
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('Apache is not recognized for new authors without validation changes',
        () async {
      final File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      final File bad = root.childDirectory('third_party').childFile('bad.cc');
      bad.createSync(recursive: true);
      _writeLicense(
        bad,
        copyright: 'Copyright 2017 Some New Authors.',
        license: <String>[
          'Licensed under the Apache License, Version 2.0 (the "License");',
          'you may not use this file except in compliance with the License.'
        ],
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      // Failure should give information about the problematic files.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'No recognized license was found for the following third-party files:'),
            contains('  third_party/bad.cc'),
          ]));
      // Failure shouldn't print the success message.
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('passes if all first-party LICENSE files are correctly formatted',
        () async {
      final File license = root.childFile('LICENSE');
      license.createSync();
      license.writeAsStringSync(_correctLicenseFileText);

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check the file.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking LICENSE'),
            contains('All files passed validation!'),
          ]));
    });

    test('passes correct LICENSE files on Windows', () async {
      final File license = root.childFile('LICENSE');
      license.createSync();
      license
          .writeAsStringSync(_correctLicenseFileText.replaceAll('\n', '\r\n'));

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // Sanity check that the test did actually check the file.
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking LICENSE'),
            contains('All files passed validation!'),
          ]));
    });

    test('fails if any first-party LICENSE files are incorrectly formatted',
        () async {
      final File license = root.childFile('LICENSE');
      license.createSync();
      license.writeAsStringSync(_incorrectLicenseFileText);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(output, isNot(contains(contains('All files passed validation!'))));
    });

    test('ignores third-party LICENSE format', () async {
      final File license =
          root.childDirectory('third_party').childFile('LICENSE');
      license.createSync(recursive: true);
      license.writeAsStringSync(_incorrectLicenseFileText);

      final List<String> output =
          await runCapturingPrint(runner, <String>['license-check']);

      // The file shouldn't be checked.
      expect(output, isNot(contains(contains('Checking third_party/LICENSE'))));
    });

    test('outputs all errors at the end', () async {
      root.childFile('bad.cc').createSync();
      root
          .childDirectory('third_party')
          .childFile('bad.cc')
          .createSync(recursive: true);
      final File license = root.childFile('LICENSE');
      license.createSync();
      license.writeAsStringSync(_incorrectLicenseFileText);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['license-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Checking LICENSE'),
            contains('Checking bad.cc'),
            contains('Checking third_party/bad.cc'),
            contains(
                'The following LICENSE files do not follow the expected format:'),
            contains('  LICENSE'),
            contains(
                'The license block for these files is missing or incorrect:'),
            contains('  bad.cc'),
            contains(
                'No recognized license was found for the following third-party files:'),
            contains('  third_party/bad.cc'),
          ]));
    });
  });
}

class MockPlatformWithSeparator extends MockPlatform {
  @override
  String get pathSeparator => isWindows ? r'\' : '/';
}

const String _correctLicenseFileText = '''
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

// A common incorrect version created by copying text intended for a code file,
// with comment markers.
const String _incorrectLicenseFileText = '''
// Copyright 2013 The Flutter Authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//    * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//    * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
''';
