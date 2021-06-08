// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/pubspec_check_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('test pubspec_check_command', () {
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late FileSystem fileSystem;
    late Directory packagesDir;

    setUp(() {
      fileSystem = MemoryFileSystem();
      packagesDir = fileSystem.currentDirectory.childDirectory('packages');
      createPackagesDirectory(parentDir: packagesDir.parent);
      processRunner = RecordingProcessRunner();
      final PubspecCheckCommand command =
          PubspecCheckCommand(packagesDir, processRunner: processRunner);

      runner = CommandRunner<void>(
          'pubspec_check_command', 'Test for pubspec_check_command');
      runner.addCommand(command);
    });

    String headerSection(
      String name, {
      bool isPlugin = false,
      bool includeRepository = true,
      bool includeHomepage = false,
      bool includeIssueTracker = true,
    }) {
      final String repoLink = 'https://github.com/flutter/'
          '${isPlugin ? 'plugins' : 'packages'}/tree/master/packages/$name';
      final String issueTrackerLink =
          'https://github.com/flutter/flutter/issues?'
          'q=is%3Aissue+is%3Aopen+label%3A%22p%3A+$name%22';
      return '''
name: $name
${includeRepository ? 'repository: $repoLink' : ''}
${includeHomepage ? 'homepage: $repoLink' : ''}
${includeIssueTracker ? 'issue_tracker: $issueTrackerLink' : ''}
version: 1.0.0
''';
    }

    String environmentSection() {
      return '''
environment:
  sdk: ">=2.12.0 <3.0.0"
  flutter: ">=2.0.0"
''';
    }

    String flutterSection({bool isPlugin = false}) {
      const String pluginEntry = '''
  plugin:
    platforms:
''';
      return '''
flutter:
${isPlugin ? pluginEntry : ''}
''';
    }

    String dependenciesSection() {
      return '''
dependencies:
  flutter:
    sdk: flutter
''';
    }

    String devDependenciesSection() {
      return '''
dev_dependencies:
  flutter_test:
    sdk: flutter
''';
    }

    test('passes for a plugin following conventions', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true)}
${environmentSection()}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
${devDependenciesSection()}
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          'Checking plugin...',
          'Checking plugin/example...',
          '\nNo pubspec issues found!',
        ]),
      );
    });

    test('passes for a Flutter package following conventions', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin')}
${environmentSection()}
${dependenciesSection()}
${devDependenciesSection()}
${flutterSection()}
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          'Checking plugin...',
          'Checking plugin/example...',
          '\nNo pubspec issues found!',
        ]),
      );
    });

    test('passes for a minimal package following conventions', () async {
      final Directory packageDirectory = packagesDir.childDirectory('package');
      packageDirectory.createSync(recursive: true);

      packageDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('package')}
${environmentSection()}
${dependenciesSection()}
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          'Checking package...',
          '\nNo pubspec issues found!',
        ]),
      );
    });

    test('fails when homepage is included', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true, includeHomepage: true)}
${environmentSection()}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
${devDependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when repository is missing', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true, includeRepository: false)}
${environmentSection()}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
${devDependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when homepage is given instead of repository', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true, includeHomepage: true, includeRepository: false)}
${environmentSection()}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
${devDependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when issue tracker is missing', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true, includeIssueTracker: false)}
${environmentSection()}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
${devDependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when environment section is out of order', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true)}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
${devDependenciesSection()}
${environmentSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when flutter section is out of order', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true)}
${flutterSection(isPlugin: true)}
${environmentSection()}
${dependenciesSection()}
${devDependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when dependencies section is out of order', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true)}
${environmentSection()}
${flutterSection(isPlugin: true)}
${devDependenciesSection()}
${dependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });

    test('fails when devDependencies section is out of order', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, withSingleExample: true);

      pluginDirectory.childFile('pubspec.yaml').writeAsStringSync('''
${headerSection('plugin', isPlugin: true)}
${environmentSection()}
${devDependenciesSection()}
${flutterSection(isPlugin: true)}
${dependenciesSection()}
''');

      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['pubspec-check']);

      await expectLater(
        result,
        throwsA(const TypeMatcher<ToolExit>()),
      );
    });
  });
}
