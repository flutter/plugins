// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/readme_check_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late RecordingProcessRunner processRunner;
  late FileSystem fileSystem;
  late MockPlatform mockPlatform;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockPlatform = MockPlatform();
    packagesDir = fileSystem.currentDirectory.childDirectory('packages');
    createPackagesDirectory(parentDir: packagesDir.parent);
    processRunner = RecordingProcessRunner();
    final ReadmeCheckCommand command = ReadmeCheckCommand(
      packagesDir,
      processRunner: processRunner,
      platform: mockPlatform,
    );

    runner = CommandRunner<void>(
        'readme_check_command', 'Test for readme_check_command');
    runner.addCommand(command);
  });

  test('prints paths of checked READMEs', () async {
    final RepositoryPackage package = createFakePackage(
        'a_package', packagesDir,
        examples: <String>['example1', 'example2']);
    for (final RepositoryPackage example in package.getExamples()) {
      example.readmeFile.writeAsStringSync('A readme');
    }
    getExampleDir(package).childFile('README.md').writeAsStringSync('A readme');

    final List<String> output =
        await runCapturingPrint(runner, <String>['readme-check']);

    expect(
      output,
      containsAll(<Matcher>[
        contains('  Checking README.md...'),
        contains('  Checking example/README.md...'),
        contains('  Checking example/example1/README.md...'),
        contains('  Checking example/example2/README.md...'),
      ]),
    );
  });

  test('fails when package README is missing', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.deleteSync();

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['readme-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Missing README.md'),
      ]),
    );
  });

  test('passes when example README is missing', () async {
    createFakePackage('a_package', packagesDir);

    final List<String> output =
        await runCapturingPrint(runner, <String>['readme-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('No README for example'),
      ]),
    );
  });

  test('does not inculde non-example subpackages', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    const String subpackageName = 'special_test';
    final RepositoryPackage miscSubpackage =
        createFakePackage(subpackageName, package.directory);
    miscSubpackage.readmeFile.delete();

    final List<String> output =
        await runCapturingPrint(runner, <String>['readme-check']);

    expect(output, isNot(contains(subpackageName)));
  });

  test('fails when README still has plugin template boilerplate', () async {
    final RepositoryPackage package = createFakePlugin('a_plugin', packagesDir);
    package.readmeFile.writeAsStringSync('''
## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['readme-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('The boilerplate section about getting started with Flutter '
            'should not be left in.'),
        contains('Contains template boilerplate'),
      ]),
    );
  });

  test('fails when example README still has application template boilerplate',
      () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.getExamples().first.readmeFile.writeAsStringSync('''
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['readme-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('The boilerplate section about getting started with Flutter '
            'should not be left in.'),
        contains('Contains template boilerplate'),
      ]),
    );
  });

  test(
      'fails when a plugin implementation package example README has the '
      'template boilerplate', () async {
    final RepositoryPackage package = createFakePlugin(
        'a_plugin_ios', packagesDir.childDirectory('a_plugin'));
    package.getExamples().first.readmeFile.writeAsStringSync('''
# a_plugin_ios_example

Demonstrates how to use the a_plugin_ios plugin.
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['readme-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('The boilerplate should not be left in for a federated plugin '
            "implementation package's example."),
        contains('Contains template boilerplate'),
      ]),
    );
  });

  test(
      'allows the template boilerplate in the example README for packages '
      'other than plugin implementation packages', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir.childDirectory('a_plugin'),
      platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline),
      },
    );
    // Write a README with an OS support table so that the main README check
    // passes.
    package.readmeFile.writeAsStringSync('''
# a_plugin

|                | Android |
|----------------|---------|
| **Support**    | SDK 19+ |

A great plugin.
''');
    package.getExamples().first.readmeFile.writeAsStringSync('''
# a_plugin_example

Demonstrates how to use the a_plugin plugin.
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['readme-check']);

    expect(
      output,
      containsAll(<Matcher>[
        contains('  Checking README.md...'),
        contains('  Checking example/README.md...'),
      ]),
    );
  });

  test(
      'fails when a plugin implementation package example README does not have '
      'the repo-standard message', () async {
    final RepositoryPackage package = createFakePlugin(
        'a_plugin_ios', packagesDir.childDirectory('a_plugin'));
    package.getExamples().first.readmeFile.writeAsStringSync('''
# a_plugin_ios_example

Some random description.
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['readme-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('The example README for a platform implementation package '
            'should warn readers about its intended use. Please copy the '
            'example README from another implementation package in this '
            'repository.'),
        contains('Missing implementation package example warning'),
      ]),
    );
  });

  test('passes for a plugin implementation package with the expected content',
      () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir.childDirectory('a_plugin'),
      platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline),
      },
    );
    // Write a README with an OS support table so that the main README check
    // passes.
    package.readmeFile.writeAsStringSync('''
# a_plugin

|                | Android |
|----------------|---------|
| **Support**    | SDK 19+ |

A great plugin.
''');
    package.getExamples().first.readmeFile.writeAsStringSync('''
# Platform Implementation Test App

This is a test app for manual testing and automated integration testing
of this platform implementation. It is not intended to demonstrate actual use of
this package, since the intent is that plugin clients use the app-facing
package.

Unless you are making changes to this implementation package, this example is
very unlikely to be relevant.
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['readme-check']);

    expect(
      output,
      containsAll(<Matcher>[
        contains('  Checking README.md...'),
        contains('  Checking example/README.md...'),
      ]),
    );
  });

  test(
      'fails when multi-example top-level example directory README still has '
      'application template boilerplate', () async {
    final RepositoryPackage package = createFakePackage(
        'a_package', packagesDir,
        examples: <String>['example1', 'example2']);
    package.directory
        .childDirectory('example')
        .childFile('README.md')
        .writeAsStringSync('''
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['readme-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('The boilerplate section about getting started with Flutter '
            'should not be left in.'),
        contains('Contains template boilerplate'),
      ]),
    );
  });

  group('plugin OS support', () {
    test(
        'does not check support table for anything other than app-facing plugin packages',
        () async {
      const String federatedPluginName = 'a_federated_plugin';
      final Directory federatedDir =
          packagesDir.childDirectory(federatedPluginName);
      // A non-plugin package.
      createFakePackage('a_package', packagesDir);
      // Non-app-facing parts of a federated plugin.
      createFakePlugin(
          '${federatedPluginName}_platform_interface', federatedDir);
      createFakePlugin('${federatedPluginName}_android', federatedDir);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'readme-check',
      ]);

      expect(
        output,
        containsAll(<Matcher>[
          contains('Running for a_package...'),
          contains('Running for a_federated_plugin_platform_interface...'),
          contains('Running for a_federated_plugin_android...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when non-federated plugin is missing an OS support table',
        () async {
      createFakePlugin('a_plugin', packagesDir);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No OS support table found'),
        ]),
      );
    });

    test(
        'fails when app-facing part of a federated plugin is missing an OS support table',
        () async {
      createFakePlugin('a_plugin', packagesDir.childDirectory('a_plugin'));

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No OS support table found'),
        ]),
      );
    });

    test('fails the OS support table is missing the header', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);

      plugin.readmeFile.writeAsStringSync('''
A very useful plugin.

| **Support**    | SDK 21+ | iOS 10+* | [See `camera_web `][1] |
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('OS support table does not have the expected header format'),
        ]),
      );
    });

    test('fails if the OS support table is missing a supported OS', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      plugin.readmeFile.writeAsStringSync('''
A very useful plugin.

|                | Android | iOS      |
|----------------|---------|----------|
| **Support**    | SDK 21+ | iOS 10+* |
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('  OS support table does not match supported platforms:\n'
              '    Actual:     android, ios, web\n'
              '    Documented: android, ios'),
          contains('Incorrect OS support table'),
        ]),
      );
    });

    test('fails if the OS support table lists an extra OS', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      plugin.readmeFile.writeAsStringSync('''
A very useful plugin.

|                | Android | iOS      | Web                    |
|----------------|---------|----------|------------------------|
| **Support**    | SDK 21+ | iOS 10+* | [See `camera_web `][1] |
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('  OS support table does not match supported platforms:\n'
              '    Actual:     android, ios\n'
              '    Documented: android, ios, web'),
          contains('Incorrect OS support table'),
        ]),
      );
    });

    test('fails if the OS support table has unexpected OS formatting',
        () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
          platformMacOS: const PlatformDetails(PlatformSupport.inline),
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      plugin.readmeFile.writeAsStringSync('''
A very useful plugin.

|                | android | ios      | MacOS | web                    |
|----------------|---------|----------|-------|------------------------|
| **Support**    | SDK 21+ | iOS 10+* | 10.11 | [See `camera_web `][1] |
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('  Incorrect OS capitalization: android, ios, MacOS, web\n'
              '    Please use standard capitalizations: Android, iOS, macOS, Web\n'),
          contains('Incorrect OS support formatting'),
        ]),
      );
    });
  });

  group('code blocks', () {
    test('fails on missing info string', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      package.readmeFile.writeAsStringSync('''
Example:

```
void main() {
  // ...
}
```
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Code block at line 3 is missing a language identifier.'),
          contains('Missing language identifier for code block'),
        ]),
      );
    });

    test('allows unknown info strings', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      package.readmeFile.writeAsStringSync('''
Example:

```someunknowninfotag
A B C
```
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'readme-check',
      ]);

      expect(
        output,
        containsAll(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('allows space around info strings', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      package.readmeFile.writeAsStringSync('''
Example:

```  dart
A B C
```
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'readme-check',
      ]);

      expect(
        output,
        containsAll(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('passes when excerpt requirement is met', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>[kReadmeExcerptConfigPath],
      );

      package.readmeFile.writeAsStringSync('''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A B C
```
''');

      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check', '--require-excerpts']);

      expect(
        output,
        containsAll(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when excerpts are used but the package is not configured',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      package.readmeFile.writeAsStringSync('''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A B C
```
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check', '--require-excerpts'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('code-excerpt tag found, but the package is not configured '
              'for excerpting. Follow the instructions at\n'
              'https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages\n'
              'for setting up a build.excerpt.yaml file.'),
          contains('Missing code-excerpt configuration'),
        ]),
      );
    });

    test('fails on missing excerpt tag when requested', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      package.readmeFile.writeAsStringSync('''
Example:

```dart
A B C
```
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['readme-check', '--require-excerpts'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Dart code block at line 3 is not managed by code-excerpt.'),
          // Ensure that the failure message links to instructions.
          contains(
              'https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages'),
          contains('Missing code-excerpt management for code block'),
        ]),
      );
    });
  });
}
