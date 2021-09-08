// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/version_check_command.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void testAllowedVersion(
  String masterVersion,
  String headVersion, {
  bool allowed = true,
  NextVersionType? nextVersionType,
}) {
  final Version master = Version.parse(masterVersion);
  final Version head = Version.parse(headVersion);
  final Map<Version, NextVersionType> allowedVersions =
      getAllowedNextVersions(master, newVersion: head);
  if (allowed) {
    expect(allowedVersions, contains(head));
    if (nextVersionType != null) {
      expect(allowedVersions[head], equals(nextVersionType));
    }
  } else {
    expect(allowedVersions, isNot(contains(head)));
  }
}

class MockProcessResult extends Mock implements io.ProcessResult {}

void main() {
  const String indentation = '  ';
  group('$VersionCheckCommand', () {
    FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late List<List<String>> gitDirCommands;
    Map<String, String> gitShowResponses;
    late MockGitDir gitDir;
    // Ignored if mockHttpResponse is set.
    int mockHttpStatus;
    Map<String, dynamic>? mockHttpResponse;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);

      gitDirCommands = <List<String>>[];
      gitShowResponses = <String, String>{};
      gitDir = MockGitDir();
      when(gitDir.path).thenReturn(packagesDir.parent.path);
      when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
          .thenAnswer((Invocation invocation) {
        gitDirCommands.add(invocation.positionalArguments[0] as List<String>);
        final MockProcessResult mockProcessResult = MockProcessResult();
        if (invocation.positionalArguments[0][0] == 'show') {
          final String? response =
              gitShowResponses[invocation.positionalArguments[0][1]];
          if (response == null) {
            throw const io.ProcessException('git', <String>['show']);
          }
          when<String?>(mockProcessResult.stdout as String?)
              .thenReturn(response);
        } else if (invocation.positionalArguments[0][0] == 'merge-base') {
          when<String?>(mockProcessResult.stdout as String?)
              .thenReturn('abc123');
        }
        return Future<io.ProcessResult>.value(mockProcessResult);
      });

      // Default to simulating the plugin never having been published.
      mockHttpStatus = 404;
      mockHttpResponse = null;
      final MockClient mockClient = MockClient((http.Request request) async {
        return http.Response(json.encode(mockHttpResponse),
            mockHttpResponse == null ? mockHttpStatus : 200);
      });

      processRunner = RecordingProcessRunner();
      final VersionCheckCommand command = VersionCheckCommand(packagesDir,
          processRunner: processRunner,
          platform: mockPlatform,
          gitDir: gitDir,
          httpClient: mockClient);

      runner = CommandRunner<void>(
          'version_check_command', 'Test for $VersionCheckCommand');
      runner.addCommand(command);
    });

    test('allows valid version', () async {
      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('1.0.0 -> 2.0.0'),
        ]),
      );
      expect(gitDirCommands.length, equals(1));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>['show', 'master:packages/plugin/pubspec.yaml']),
          ]));
    });

    test('denies invalid version', () async {
      createFakePlugin('plugin', packagesDir, version: '0.2.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 0.0.1',
      };
      final Future<List<String>> result = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);

      await expectLater(
        result,
        throwsA(isA<ToolExit>()),
      );
      expect(gitDirCommands.length, equals(1));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>['show', 'master:packages/plugin/pubspec.yaml']),
          ]));
    });

    test('allows valid version without explicit base-sha', () async {
      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      gitShowResponses = <String, String>{
        'abc123:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };
      final List<String> output =
          await runCapturingPrint(runner, <String>['version-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('1.0.0 -> 2.0.0'),
        ]),
      );
    });

    test('allows valid version for new package.', () async {
      createFakePlugin('plugin', packagesDir, version: '1.0.0');
      final List<String> output =
          await runCapturingPrint(runner, <String>['version-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Unable to find previous version at git base.'),
        ]),
      );
    });

    test('allows likely reverts.', () async {
      createFakePlugin('plugin', packagesDir, version: '0.6.1');
      gitShowResponses = <String, String>{
        'abc123:packages/plugin/pubspec.yaml': 'version: 0.6.2',
      };
      final List<String> output =
          await runCapturingPrint(runner, <String>['version-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('New version is lower than previous version. '
              'This is assumed to be a revert.'),
        ]),
      );
    });

    test('denies lower version that could not be a simple revert', () async {
      createFakePlugin('plugin', packagesDir, version: '0.5.1');
      gitShowResponses = <String, String>{
        'abc123:packages/plugin/pubspec.yaml': 'version: 0.6.2',
      };
      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['version-check']);

      await expectLater(
        result,
        throwsA(isA<ToolExit>()),
      );
    });

    test('denies invalid version without explicit base-sha', () async {
      createFakePlugin('plugin', packagesDir, version: '0.2.0');
      gitShowResponses = <String, String>{
        'abc123:packages/plugin/pubspec.yaml': 'version: 0.0.1',
      };
      final Future<List<String>> result =
          runCapturingPrint(runner, <String>['version-check']);

      await expectLater(
        result,
        throwsA(isA<ToolExit>()),
      );
    });

    test('allows minor changes to platform interfaces', () async {
      createFakePlugin('plugin_platform_interface', packagesDir,
          version: '1.1.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin_platform_interface/pubspec.yaml':
            'version: 1.0.0',
      };
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('1.0.0 -> 1.1.0'),
        ]),
      );
      expect(gitDirCommands.length, equals(1));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>[
              'show',
              'master:packages/plugin_platform_interface/pubspec.yaml'
            ]),
          ]));
    });

    test('disallows breaking changes to platform interfaces', () async {
      createFakePlugin('plugin_platform_interface', packagesDir,
          version: '2.0.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin_platform_interface/pubspec.yaml':
            'version: 1.0.0',
      };
      final Future<List<String>> output = runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        throwsA(isA<ToolExit>()),
      );
      expect(gitDirCommands.length, equals(1));
      expect(
          gitDirCommands,
          containsAll(<Matcher>[
            equals(<String>[
              'show',
              'master:packages/plugin_platform_interface/pubspec.yaml'
            ]),
          ]));
    });

    test('Allow empty lines in front of the first version in CHANGELOG',
        () async {
      const String version = '1.0.1';
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: version);
      const String changelog = '''

## $version
* Some changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
        ]),
      );
    });

    test('Throws if versions in changelog and pubspec do not match', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: '1.0.1');
      const String changelog = '''
## 1.0.2
* Some changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      bool hasError = false;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Versions in CHANGELOG.md and pubspec.yaml do not match.'),
        ]),
      );
    });

    test('Success if CHANGELOG and pubspec versions match', () async {
      const String version = '1.0.1';
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## $version
* Some changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
        ]),
      );
    });

    test(
        'Fail if pubspec version only matches an older version listed in CHANGELOG',
        () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: '1.0.0');

      const String changelog = '''
## 1.0.1
* Some changes.
## 1.0.0
* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      bool hasError = false;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Versions in CHANGELOG.md and pubspec.yaml do not match.'),
        ]),
      );
    });

    test('Allow NEXT as a placeholder for gathering CHANGELOG entries',
        () async {
      const String version = '1.0.0';
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## NEXT
* Some changes that won't be published until the next time there's a release.
## $version
* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };

      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=master']);
      await expectLater(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Found NEXT; validating next version in the CHANGELOG.'),
        ]),
      );
    });

    test('Fail if NEXT appears after a version', () async {
      const String version = '1.0.1';
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## $version
* Some changes.
## NEXT
* Some changes that should have been folded in 1.0.1.
## 1.0.0
* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      bool hasError = false;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('When bumping the version for release, the NEXT section '
              'should be incorporated into the new version\'s release notes.')
        ]),
      );
    });

    test('Fail if NEXT is left in the CHANGELOG when adding a version bump',
        () async {
      const String version = '1.0.1';
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## NEXT
* Some changes that should have been folded in 1.0.1.
## $version
* Some changes.
## 1.0.0
* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };

      bool hasError = false;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('When bumping the version for release, the NEXT section '
              'should be incorporated into the new version\'s release notes.'),
          contains('plugin:\n'
              '    CHANGELOG.md failed validation.'),
        ]),
      );
    });

    test('Fail if the version changes without replacing NEXT', () async {
      final Directory pluginDirectory =
          createFakePlugin('plugin', packagesDir, version: '1.0.1');

      const String changelog = '''
## NEXT
* Some changes that should be listed as part of 1.0.1.
## 1.0.0
* Some other changes.
''';
      createFakeCHANGELOG(pluginDirectory, changelog);
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };

      bool hasError = false;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('When bumping the version for release, the NEXT section '
              'should be incorporated into the new version\'s release notes.')
        ]),
      );
    });

    test('allows valid against pub', () async {
      mockHttpResponse = <String, dynamic>{
        'name': 'some_package',
        'versions': <String>[
          '0.0.1',
          '0.0.2',
          '1.0.0',
        ],
      };

      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };
      final List<String> output = await runCapturingPrint(runner,
          <String>['version-check', '--base-sha=master', '--against-pub']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('plugin: Current largest version on pub: 1.0.0'),
        ]),
      );
    });

    test('denies invalid against pub', () async {
      mockHttpResponse = <String, dynamic>{
        'name': 'some_package',
        'versions': <String>[
          '0.0.1',
          '0.0.2',
        ],
      };

      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };

      bool hasError = false;
      final List<String> result = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        result,
        containsAllInOrder(<Matcher>[
          contains('''
${indentation}Incorrectly updated version.
${indentation}HEAD: 2.0.0, pub: 0.0.2.
${indentation}Allowed versions: {1.0.0: NextVersionType.BREAKING_MAJOR, 0.1.0: NextVersionType.MINOR, 0.0.3: NextVersionType.PATCH}''')
        ]),
      );
    });

    test(
        'throw and print error message if http request failed when checking against pub',
        () async {
      mockHttpStatus = 400;

      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };
      bool hasError = false;
      final List<String> result = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=master',
        '--against-pub'
      ], errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        result,
        containsAllInOrder(<Matcher>[
          contains('''
${indentation}Error fetching version on pub for plugin.
${indentation}HTTP Status 400
${indentation}HTTP response: null
''')
        ]),
      );
    });

    test('when checking against pub, allow any version if http status is 404.',
        () async {
      mockHttpStatus = 404;

      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      gitShowResponses = <String, String>{
        'master:packages/plugin/pubspec.yaml': 'version: 1.0.0',
      };
      final List<String> result = await runCapturingPrint(runner,
          <String>['version-check', '--base-sha=master', '--against-pub']);

      expect(
        result,
        containsAllInOrder(<Matcher>[
          contains('Unable to find previous version on pub server.'),
        ]),
      );
    });
  });

  group('Pre 1.0', () {
    test('nextVersion allows patch version', () {
      testAllowedVersion('0.12.0', '0.12.0+1',
          nextVersionType: NextVersionType.PATCH);
      testAllowedVersion('0.12.0+4', '0.12.0+5',
          nextVersionType: NextVersionType.PATCH);
    });

    test('nextVersion does not allow jumping patch', () {
      testAllowedVersion('0.12.0', '0.12.0+2', allowed: false);
      testAllowedVersion('0.12.0+2', '0.12.0+4', allowed: false);
    });

    test('nextVersion does not allow going back', () {
      testAllowedVersion('0.12.0', '0.11.0', allowed: false);
      testAllowedVersion('0.12.0+2', '0.12.0+1', allowed: false);
      testAllowedVersion('0.12.0+1', '0.12.0', allowed: false);
    });

    test('nextVersion allows minor version', () {
      testAllowedVersion('0.12.0', '0.12.1',
          nextVersionType: NextVersionType.MINOR);
      testAllowedVersion('0.12.0+4', '0.12.1',
          nextVersionType: NextVersionType.MINOR);
    });

    test('nextVersion does not allow jumping minor', () {
      testAllowedVersion('0.12.0', '0.12.2', allowed: false);
      testAllowedVersion('0.12.0+2', '0.12.3', allowed: false);
    });
  });

  group('Releasing 1.0', () {
    test('nextVersion allows releasing 1.0', () {
      testAllowedVersion('0.12.0', '1.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
      testAllowedVersion('0.12.0+4', '1.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
    });

    test('nextVersion does not allow jumping major', () {
      testAllowedVersion('0.12.0', '2.0.0', allowed: false);
      testAllowedVersion('0.12.0+4', '2.0.0', allowed: false);
    });

    test('nextVersion does not allow un-releasing', () {
      testAllowedVersion('1.0.0', '0.12.0+4', allowed: false);
      testAllowedVersion('1.0.0', '0.12.0', allowed: false);
    });
  });

  group('Post 1.0', () {
    test('nextVersion allows patch jumps', () {
      testAllowedVersion('1.0.1', '1.0.2',
          nextVersionType: NextVersionType.PATCH);
      testAllowedVersion('1.0.0', '1.0.1',
          nextVersionType: NextVersionType.PATCH);
    });

    test('nextVersion does not allow build jumps', () {
      testAllowedVersion('1.0.1', '1.0.1+1', allowed: false);
      testAllowedVersion('1.0.0+5', '1.0.0+6', allowed: false);
    });

    test('nextVersion does not allow skipping patches', () {
      testAllowedVersion('1.0.1', '1.0.3', allowed: false);
      testAllowedVersion('1.0.0', '1.0.6', allowed: false);
    });

    test('nextVersion allows minor version jumps', () {
      testAllowedVersion('1.0.1', '1.1.0',
          nextVersionType: NextVersionType.MINOR);
      testAllowedVersion('1.0.0', '1.1.0',
          nextVersionType: NextVersionType.MINOR);
    });

    test('nextVersion does not allow skipping minor versions', () {
      testAllowedVersion('1.0.1', '1.2.0', allowed: false);
      testAllowedVersion('1.1.0', '1.3.0', allowed: false);
    });

    test('nextVersion allows breaking changes', () {
      testAllowedVersion('1.0.1', '2.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
      testAllowedVersion('1.0.0', '2.0.0',
          nextVersionType: NextVersionType.BREAKING_MAJOR);
    });

    test('nextVersion does not allow skipping major versions', () {
      testAllowedVersion('1.0.1', '3.0.0', allowed: false);
      testAllowedVersion('1.1.0', '2.3.0', allowed: false);
    });
  });
}
