// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  String mainVersion,
  String headVersion, {
  bool allowed = true,
  NextVersionType? nextVersionType,
}) {
  final Version main = Version.parse(mainVersion);
  final Version head = Version.parse(headVersion);
  final Map<Version, NextVersionType> allowedVersions =
      getAllowedNextVersions(main, newVersion: head);
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
  group('VersionCheckCommand', () {
    late FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late MockGitDir gitDir;
    // Ignored if mockHttpResponse is set.
    int mockHttpStatus;
    Map<String, dynamic>? mockHttpResponse;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);

      gitDir = MockGitDir();
      when(gitDir.path).thenReturn(packagesDir.parent.path);
      when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
          .thenAnswer((Invocation invocation) {
        final List<String> arguments =
            invocation.positionalArguments[0]! as List<String>;
        // Route git calls through the process runner, to make mock output
        // consistent with other processes. Attach the first argument to the
        // command to make targeting the mock results easier.
        final String gitCommand = arguments.removeAt(0);
        return processRunner.run('git-$gitCommand', arguments);
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
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('1.0.0 -> 2.0.0'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show', <String>['main:packages/plugin/pubspec.yaml'], null)
          ]));
    });

    test('denies invalid version', () async {
      createFakePlugin('plugin', packagesDir, version: '0.2.0');
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 0.0.1'),
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Incorrectly updated version.'),
          ]));
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show', <String>['main:packages/plugin/pubspec.yaml'], null)
          ]));
    });

    test('uses merge-base without explicit base-sha', () async {
      createFakePlugin('plugin', packagesDir, version: '2.0.0');
      processRunner.mockProcessesForExecutable['git-merge-base'] = <io.Process>[
        MockProcess(stdout: 'abc123'),
        MockProcess(stdout: 'abc123'),
      ];
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];
      final List<String> output =
          await runCapturingPrint(runner, <String>['version-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('1.0.0 -> 2.0.0'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall('git-merge-base',
                <String>['--fork-point', 'FETCH_HEAD', 'HEAD'], null),
            ProcessCall('git-show',
                <String>['abc123:packages/plugin/pubspec.yaml'], null),
          ]));
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
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 0.6.2'),
      ];
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('New version is lower than previous version. '
              'This is assumed to be a revert.'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show', <String>['main:packages/plugin/pubspec.yaml'], null)
          ]));
    });

    test('denies lower version that could not be a simple revert', () async {
      createFakePlugin('plugin', packagesDir, version: '0.5.1');
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 0.6.2'),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Incorrectly updated version.'),
          ]));
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show', <String>['main:packages/plugin/pubspec.yaml'], null)
          ]));
    });

    test('allows minor changes to platform interfaces', () async {
      createFakePlugin('plugin_platform_interface', packagesDir,
          version: '1.1.0');
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('1.0.0 -> 1.1.0'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show',
                <String>[
                  'main:packages/plugin_platform_interface/pubspec.yaml'
                ],
                null)
          ]));
    });

    test('disallows breaking changes to platform interfaces by default',
        () async {
      createFakePlugin('plugin_platform_interface', packagesDir,
          version: '2.0.0');
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                '  Breaking changes to platform interfaces are not allowed '
                'without explicit justification.\n'
                '  See https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages '
                'for more information.'),
          ]));
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show',
                <String>[
                  'main:packages/plugin_platform_interface/pubspec.yaml'
                ],
                null)
          ]));
    });

    test('allows breaking changes to platform interfaces with override label',
        () async {
      createFakePlugin('plugin_platform_interface', packagesDir,
          version: '2.0.0');
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=main',
        '--pr-labels=some label,override: allow breaking change,another-label'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Allowing breaking change to plugin_platform_interface '
              'due to the "override: allow breaking change" label.'),
          contains('Ran for 1 package(s) (1 with warnings)'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show',
                <String>[
                  'main:packages/plugin_platform_interface/pubspec.yaml'
                ],
                null)
          ]));
    });

    test('allows breaking changes to platform interfaces with bypass flag',
        () async {
      createFakePlugin('plugin_platform_interface', packagesDir,
          version: '2.0.0');
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=main',
        '--ignore-platform-interface-breaks'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Allowing breaking change to plugin_platform_interface due '
              'to --ignore-platform-interface-breaks'),
          contains('Ran for 1 package(s) (1 with warnings)'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(const <ProcessCall>[
            ProcessCall(
                'git-show',
                <String>[
                  'main:packages/plugin_platform_interface/pubspec.yaml'
                ],
                null)
          ]));
    });

    test('Allow empty lines in front of the first version in CHANGELOG',
        () async {
      const String version = '1.0.1';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: version);
      const String changelog = '''

## $version
* Some changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
        ]),
      );
    });

    test('Throws if versions in changelog and pubspec do not match', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: '1.0.1');
      const String changelog = '''
## 1.0.2
* Some changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Versions in CHANGELOG.md and pubspec.yaml do not match.'),
        ]),
      );
    });

    test('Success if CHANGELOG and pubspec versions match', () async {
      const String version = '1.0.1';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## $version
* Some changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);
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
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: '1.0.0');

      const String changelog = '''
## 1.0.1
* Some changes.
## 1.0.0
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
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
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## NEXT
* Some changes that won't be published until the next time there's a release.
## $version
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];

      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Found NEXT; validating next version in the CHANGELOG.'),
        ]),
      );
    });

    test('Fail if NEXT appears after a version', () async {
      const String version = '1.0.1';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## $version
* Some changes.
## NEXT
* Some changes that should have been folded in 1.0.1.
## 1.0.0
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('When bumping the version for release, the NEXT section '
              "should be incorporated into the new version's release notes.")
        ]),
      );
    });

    test('Fail if NEXT is left in the CHANGELOG when adding a version bump',
        () async {
      const String version = '1.0.1';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: version);

      const String changelog = '''
## NEXT
* Some changes that should have been folded in 1.0.1.
## $version
* Some changes.
## 1.0.0
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);

      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('When bumping the version for release, the NEXT section '
              "should be incorporated into the new version's release notes."),
          contains('plugin:\n'
              '    CHANGELOG.md failed validation.'),
        ]),
      );
    });

    test('fails if the version increases without replacing NEXT', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: '1.0.1');

      const String changelog = '''
## NEXT
* Some changes that should be listed as part of 1.0.1.
## 1.0.0
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);

      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('When bumping the version for release, the NEXT section '
              "should be incorporated into the new version's release notes.")
        ]),
      );
    });

    test('allows NEXT for a revert', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: '1.0.0');

      const String changelog = '''
## NEXT
* Some changes that should be listed as part of 1.0.1.
## 1.0.0
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      plugin.changelogFile.writeAsStringSync(changelog);
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.1'),
      ];

      final List<String> output = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main']);
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('New version is lower than previous version. '
              'This is assumed to be a revert.'),
        ]),
      );
    });

    test(
        'fails gracefully if the version headers are not found due to using the wrong style',
        () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: '1.0.0');

      const String changelog = '''
## NEXT
* Some changes for a later release.
# 1.0.0
* Some other changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=main',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to find a version in CHANGELOG.md'),
          contains('The current version should be on a line starting with '
              '"## ", either on the first non-empty line or after a "## NEXT" '
              'section.'),
        ]),
      );
    });

    test('fails gracefully if the version is unparseable', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, version: '1.0.0');

      const String changelog = '''
## Alpha
* Some changes.
''';
      plugin.changelogFile.writeAsStringSync(changelog);
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'version-check',
        '--base-sha=main',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('"Alpha" could not be parsed as a version.'),
        ]),
      );
    });

    group('missing change detection', () {
      Future<List<String>> _runWithMissingChangeDetection(
          List<String> extraArgs,
          {void Function(Error error)? errorHandler}) async {
        return runCapturingPrint(
            runner,
            <String>[
              'version-check',
              '--base-sha=main',
              '--check-for-missing-changes',
              ...extraArgs,
            ],
            errorHandler: errorHandler);
      }

      test('passes for unchanged packages', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: ''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
          ]),
        );
      });

      test(
          'fails if a version change is missing from a change that does not '
          'pass the exemption check', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/lib/plugin.dart
'''),
        ];

        Error? commandError;
        final List<String> output = await _runWithMissingChangeDetection(
            <String>[], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No version change found'),
            contains('plugin:\n'
                '    Missing version change'),
          ]),
        );
      });

      test('passes version change requirement when version changes', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.1');

        const String changelog = '''
## 1.0.1
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/lib/plugin.dart
packages/plugin/CHANGELOG.md
packages/plugin/pubspec.yaml
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
          ]),
        );
      });

      test('version change check ignores files outside the package', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin_a/lib/plugin.dart
tool/plugin/lib/plugin.dart
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
          ]),
        );
      });

      test('allows missing version change for exempt changes', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/example/android/lint-baseline.xml
packages/plugin/example/android/src/androidTest/foo/bar/FooTest.java
packages/plugin/example/ios/RunnerTests/Foo.m
packages/plugin/example/ios/RunnerUITests/info.plist
packages/plugin/CHANGELOG.md
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
          ]),
        );
      });

      test('allows missing version change with override label', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/lib/plugin.dart
packages/plugin/CHANGELOG.md
packages/plugin/pubspec.yaml
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[
          '--pr-labels=some label,override: no versioning needed,another-label'
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ignoring lack of version change due to the '
                '"override: no versioning needed" label.'),
          ]),
        );
      });

      test('fails if a CHANGELOG change is missing', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/example/lib/foo.dart
'''),
        ];

        Error? commandError;
        final List<String> output = await _runWithMissingChangeDetection(
            <String>[], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No CHANGELOG change found'),
            contains('plugin:\n'
                '    Missing CHANGELOG change'),
          ]),
        );
      });

      test('passes CHANGELOG check when the CHANGELOG is changed', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/example/lib/foo.dart
packages/plugin/CHANGELOG.md
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
          ]),
        );
      });

      test('fails CHANGELOG check if only another package CHANGELOG chages',
          () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/example/lib/foo.dart
packages/another_plugin/CHANGELOG.md
'''),
        ];

        Error? commandError;
        final List<String> output = await _runWithMissingChangeDetection(
            <String>[], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No CHANGELOG change found'),
          ]),
        );
      });

      test('allows missing CHANGELOG change with justification', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          MockProcess(stdout: '''
packages/plugin/example/lib/foo.dart
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[
          '--pr-labels=some label,override: no changelog needed,another-label'
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ignoring lack of CHANGELOG update due to the '
                '"override: no changelog needed" label.'),
          ]),
        );
      });

      // This test ensures that Dependabot Gradle changes to test-only files
      // aren't flagged by the version check.
      test(
          'allows missing CHANGELOG and version change for test-only Gradle changes',
          () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin', packagesDir, version: '1.0.0');

        const String changelog = '''
## 1.0.0
* Some changes.
''';
        plugin.changelogFile.writeAsStringSync(changelog);
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
          // File list.
          MockProcess(stdout: '''
packages/plugin/android/build.gradle
'''),
          // build.gradle diff
          MockProcess(stdout: '''
-  androidTestImplementation 'androidx.test.espresso:espresso-core:3.2.0'
-  testImplementation 'junit:junit:4.10.0'
+  androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'
+  testImplementation 'junit:junit:4.13.2'
'''),
        ];

        final List<String> output =
            await _runWithMissingChangeDetection(<String>[]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
          ]),
        );
      });
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
      final List<String> output = await runCapturingPrint(runner,
          <String>['version-check', '--base-sha=main', '--against-pub']);

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

      bool hasError = false;
      final List<String> result = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
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
      bool hasError = false;
      final List<String> result = await runCapturingPrint(
          runner, <String>['version-check', '--base-sha=main', '--against-pub'],
          errorHandler: (Error e) {
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
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: 'version: 1.0.0'),
      ];
      final List<String> result = await runCapturingPrint(runner,
          <String>['version-check', '--base-sha=main', '--against-pub']);

      expect(
        result,
        containsAllInOrder(<Matcher>[
          contains('Unable to find previous version on pub server.'),
        ]),
      );
    });

    group('prelease versions', () {
      test(
          'allow an otherwise-valid transition that also adds a pre-release component',
          () async {
        createFakePlugin('plugin', packagesDir, version: '2.0.0-dev');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.0.0'),
        ];
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('1.0.0 -> 2.0.0-dev'),
          ]),
        );
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });

      test('allow releasing a pre-release', () async {
        createFakePlugin('plugin', packagesDir, version: '1.2.0');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.2.0-dev'),
        ];
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('1.2.0-dev -> 1.2.0'),
          ]),
        );
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });

      // Allow abandoning a pre-release version in favor of a different version
      // change type.
      test(
          'allow an otherwise-valid transition that also removes a pre-release component',
          () async {
        createFakePlugin('plugin', packagesDir, version: '2.0.0');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.2.0-dev'),
        ];
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('1.2.0-dev -> 2.0.0'),
          ]),
        );
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });

      test('allow changing only the pre-release version', () async {
        createFakePlugin('plugin', packagesDir, version: '1.2.0-dev.2');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 1.2.0-dev.1'),
        ];
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('1.2.0-dev.1 -> 1.2.0-dev.2'),
          ]),
        );
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });

      test('denies invalid version change that also adds a pre-release',
          () async {
        createFakePlugin('plugin', packagesDir, version: '0.2.0-dev');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 0.0.1'),
        ];
        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Incorrectly updated version.'),
            ]));
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });

      test('denies invalid version change that also removes a pre-release',
          () async {
        createFakePlugin('plugin', packagesDir, version: '0.2.0');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 0.0.1-dev'),
        ];
        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Incorrectly updated version.'),
            ]));
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });

      test('denies invalid version change between pre-releases', () async {
        createFakePlugin('plugin', packagesDir, version: '0.2.0-dev');
        processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
          MockProcess(stdout: 'version: 0.0.1-dev'),
        ];
        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['version-check', '--base-sha=main'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Incorrectly updated version.'),
            ]));
        expect(
            processRunner.recordedCalls,
            containsAllInOrder(const <ProcessCall>[
              ProcessCall('git-show',
                  <String>['main:packages/plugin/pubspec.yaml'], null)
            ]));
      });
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
