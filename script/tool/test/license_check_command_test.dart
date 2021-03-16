// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/license_check_command.dart';
import 'package:test/test.dart';

void main() {
  group('$LicenseCheckCommand', () {
    CommandRunner<Null> runner;
    FileSystem fileSystem;
    List<String> printedMessages;
    Directory root;

    setUp(() {
      fileSystem = MemoryFileSystem();
      final Directory packagesDir =
          fileSystem.currentDirectory.childDirectory('packages');
      root = packagesDir.parent;

      printedMessages = <String>[];
      final LicenseCheckCommand command = LicenseCheckCommand(
        packagesDir,
        fileSystem,
        print: (Object message) => printedMessages.add(message.toString()),
      );
      runner =
          CommandRunner<Null>('license_test', 'Test for $LicenseCheckCommand');
      runner.addCommand(command);
    });

    /// Writes a copyright+license block to [file], defaulting to a standard
    /// block for this repository.
    void _writeLicense(
      File file, {
      String commentString = '//',
      String copyright =
          'Copyright 2019 The Chromium Authors. All rights reserved.',
      List<String> license = const <String>[
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    }) {
      List<String> lines = ['$commentString $copyright'];
      for (String line in license) {
        lines.add('$commentString $line');
      }
      file.writeAsStringSync(lines.join('\n'));
    }

    test('looks at only expected extensions', () async {
      Map<String, bool> extensions = <String, bool>{
        'c': true,
        'cc': true,
        'cpp': true,
        'dart': true,
        'h': true,
        'java': true,
        'json': false,
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

      try {
        await runner.run(<String>['license-check']);
      } on ToolExit {
        // Ignore failure; the files are empty so the check is expected to fail,
        // but this test isn't for that behavior.
      }

      extensions.forEach((String fileExtension, bool shouldCheck) {
        final Matcher logLineMatcher =
            contains('Checking $filenameBase.$fileExtension');
        expect(printedMessages,
            shouldCheck ? logLineMatcher : isNot(logLineMatcher));
      });
    });

    test('ignore list overrides extension matches', () async {
      List<String> ignoredFiles = <String>[
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

      await runner.run(<String>['license-check']);

      for (final String name in ignoredFiles) {
        expect(printedMessages, isNot(contains('Checking $name')));
      }
    });

    test('passes if all checked files have license blocks', () async {
      File checked = root.childFile('checked.cc');
      checked.createSync();
      _writeLicense(checked);
      File not_checked = root.childFile('not_checked.md');
      not_checked.createSync();

      await runner.run(<String>['license-check']);

      // Sanity check that the test did actually check a file.
      expect(printedMessages, contains('Checking checked.cc'));
      expect(printedMessages, contains('All files passed validation!'));
    });

    test('fails if any checked files are missing license blocks', () async {
      File good_a = root.childFile('good.cc');
      good_a.createSync();
      _writeLicense(good_a);
      File good_b = root.childFile('good.h');
      good_b.createSync();
      _writeLicense(good_b);
      root.childFile('bad.cc').createSync();
      root.childFile('bad.h').createSync();

      await expectLater(() => runner.run(<String>['license-check']),
          throwsA(const TypeMatcher<ToolExit>()));

      // Failure should give information about the problematic files.
      expect(printedMessages,
          contains('No copyright line was found for the following files:'));
      expect(printedMessages, contains('  bad.cc'));
      expect(printedMessages, contains('  bad.h'));
      // Failure shouldn't print the success message.
      expect(printedMessages, isNot(contains('All files passed validation!')));
    });

    test('fails if any checked files are missing just the copyright', () async {
      File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      File bad = root.childFile('bad.cc');
      bad.createSync();
      _writeLicense(bad, copyright: '');

      await expectLater(() => runner.run(<String>['license-check']),
          throwsA(const TypeMatcher<ToolExit>()));

      // Failure should give information about the problematic files.
      expect(printedMessages,
          contains('No copyright line was found for the following files:'));
      expect(printedMessages, contains('  bad.cc'));
      // Failure shouldn't print the success message.
      expect(printedMessages, isNot(contains('All files passed validation!')));
    });

    test('fails if any checked files are missing just the license', () async {
      File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      File bad = root.childFile('bad.cc');
      bad.createSync();
      _writeLicense(bad, license: <String>[]);

      await expectLater(() => runner.run(<String>['license-check']),
          throwsA(const TypeMatcher<ToolExit>()));

      // Failure should give information about the problematic files.
      expect(printedMessages,
          contains('No recognized license was found for the following files:'));
      expect(printedMessages, contains('  bad.cc'));
      // Failure shouldn't print the success message.
      expect(printedMessages, isNot(contains('All files passed validation!')));
    });

    test('fails for licenses that the tool does not expect', () async {
      File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      File bad = root.childFile('bad.cc');
      bad.createSync();
      _writeLicense(bad, license: <String>[
        'This program is free software: you can redistribute it and/or modify',
        'it under the terms of the GNU General Public License',
      ]);

      await expectLater(() => runner.run(<String>['license-check']),
          throwsA(const TypeMatcher<ToolExit>()));

      // Failure should give information about the problematic files.
      expect(printedMessages,
          contains('No recognized license was found for the following files:'));
      expect(printedMessages, contains('  bad.cc'));
      // Failure shouldn't print the success message.
      expect(printedMessages, isNot(contains('All files passed validation!')));
    });

    test('Apache is not recognized for new authors without validation changes',
        () async {
      File good = root.childFile('good.cc');
      good.createSync();
      _writeLicense(good);
      File bad = root.childFile('bad.cc');
      bad.createSync();
      _writeLicense(
        bad,
        copyright: 'Copyright 2017 Some New Authors',
        license: <String>[
          'Licensed under the Apache License, Version 2.0',
        ],
      );

      await expectLater(() => runner.run(<String>['license-check']),
          throwsA(const TypeMatcher<ToolExit>()));

      // Failure should give information about the problematic files.
      expect(printedMessages,
          contains('No recognized license was found for the following files:'));
      expect(printedMessages, contains('  bad.cc'));
      // Failure shouldn't print the success message.
      expect(printedMessages, isNot(contains('All files passed validation!')));
    });
  });
}
