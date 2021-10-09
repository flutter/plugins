// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
import 'package:flutter_plugin_tools/src/federation_safety_check_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  FileSystem fileSystem;
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late CommandRunner<void> runner;
  late RecordingProcessRunner processRunner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockPlatform = MockPlatform();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);

    final MockGitDir gitDir = MockGitDir();
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

    processRunner = RecordingProcessRunner();
    final FederationSafetyCheckCommand command = FederationSafetyCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir);

    runner = CommandRunner<void>('federation_safety_check_command',
        'Test for $FederationSafetyCheckCommand');
    runner.addCommand(command);
  });

  test('skips non-plugin packages', () async {
    final Directory package = createFakePackage('foo', packagesDir);

    final String changedFileOutput = <File>[
      package.childDirectory('lib').childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo...'),
        contains('Not a plugin'),
        contains('Skipped 1 package(s)'),
      ]),
    );
  });

  test('skips unfederated plugins', () async {
    final Directory package = createFakePlugin('foo', packagesDir);

    final String changedFileOutput = <File>[
      package.childDirectory('lib').childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo...'),
        contains('Not a federated plugin'),
        contains('Skipped 1 package(s)'),
      ]),
    );
  });

  test('skips interface packages', () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory platformInterface =
        createFakePlugin('foo_platform_interface', pluginGroupDir);

    final String changedFileOutput = <File>[
      platformInterface.childDirectory('lib').childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo_platform_interface...'),
        contains('Platform interface changes are not validated.'),
        contains('Skipped 1 package(s)'),
      ]),
    );
  });

  test('allows changes to just an interface package', () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory platformInterface =
        createFakePlugin('foo_platform_interface', pluginGroupDir);
    createFakePlugin('foo', pluginGroupDir);
    createFakePlugin('foo_ios', pluginGroupDir);
    createFakePlugin('foo_android', pluginGroupDir);

    final String changedFileOutput = <File>[
      platformInterface.childDirectory('lib').childFile('foo.dart'),
      platformInterface.childFile('pubspec.yaml'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo/foo...'),
        contains('No Dart changes.'),
        contains('Running for foo_android...'),
        contains('No Dart changes.'),
        contains('Running for foo_ios...'),
        contains('No Dart changes.'),
        contains('Running for foo_platform_interface...'),
        contains('Ran for 3 package(s)'),
        contains('Skipped 1 package(s)'),
      ]),
    );
    expect(
      output,
      isNot(contains(<Matcher>[
        contains('No published changes for foo_platform_interface'),
      ])),
    );
  });

  test('allows changes to multiple non-interface packages', () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory appFacing = createFakePlugin('foo', pluginGroupDir);
    final Directory implementation =
        createFakePlugin('foo_bar', pluginGroupDir);
    createFakePlugin('foo_platform_interface', pluginGroupDir);

    final String changedFileOutput = <File>[
      appFacing.childFile('foo.dart'),
      implementation.childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo/foo...'),
        contains('No published changes for foo_platform_interface.'),
        contains('Running for foo_bar...'),
        contains('No published changes for foo_platform_interface.'),
      ]),
    );
  });

  test(
      'fails on changes to interface and non-interface packages in the same plugin',
      () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory appFacing = createFakePlugin('foo', pluginGroupDir);
    final Directory implementation =
        createFakePlugin('foo_bar', pluginGroupDir);
    final Directory platformInterface =
        createFakePlugin('foo_platform_interface', pluginGroupDir);

    final String changedFileOutput = <File>[
      appFacing.childFile('foo.dart'),
      implementation.childFile('foo.dart'),
      platformInterface.childFile('pubspec.yaml'),
      platformInterface.childDirectory('lib').childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['federation-safety-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo/foo...'),
        contains('Dart changes are not allowed to other packages in foo in the '
            'same PR as changes to public Dart code in foo_platform_interface, '
            'as this can cause accidental breaking changes to be missed by '
            'automated checks. Please split the changes to these two packages '
            'into separate PRs.'),
        contains('Running for foo_bar...'),
        contains('Dart changes are not allowed to other packages in foo'),
        contains('The following packages had errors:'),
        contains('foo/foo:\n'
            '    foo_platform_interface changed.'),
        contains('foo_bar:\n'
            '    foo_platform_interface changed.'),
      ]),
    );
  });

  test('ignores test-only changes to interface packages', () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory appFacing = createFakePlugin('foo', pluginGroupDir);
    final Directory implementation =
        createFakePlugin('foo_bar', pluginGroupDir);
    final Directory platformInterface =
        createFakePlugin('foo_platform_interface', pluginGroupDir);

    final String changedFileOutput = <File>[
      appFacing.childFile('foo.dart'),
      implementation.childFile('foo.dart'),
      platformInterface.childFile('pubspec.yaml'),
      platformInterface.childDirectory('test').childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo/foo...'),
        contains('No public code changes for foo_platform_interface.'),
        contains('Running for foo_bar...'),
        contains('No public code changes for foo_platform_interface.'),
      ]),
    );
  });

  test('ignores unpublished changes to interface packages', () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory appFacing = createFakePlugin('foo', pluginGroupDir);
    final Directory implementation =
        createFakePlugin('foo_bar', pluginGroupDir);
    final Directory platformInterface =
        createFakePlugin('foo_platform_interface', pluginGroupDir);

    final String changedFileOutput = <File>[
      appFacing.childFile('foo.dart'),
      implementation.childFile('foo.dart'),
      platformInterface.childFile('pubspec.yaml'),
      platformInterface.childDirectory('lib').childFile('foo.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];
    // Simulate no change to the version in the interface's pubspec.yaml.
    processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
      MockProcess(
          stdout: RepositoryPackage(platformInterface)
              .pubspecFile
              .readAsStringSync()),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo/foo...'),
        contains('No published changes for foo_platform_interface.'),
        contains('Running for foo_bar...'),
        contains('No published changes for foo_platform_interface.'),
      ]),
    );
  });

  test('allows things that look like mass changes, with warning', () async {
    final Directory pluginGroupDir = packagesDir.childDirectory('foo');
    final Directory appFacing = createFakePlugin('foo', pluginGroupDir);
    final Directory implementation =
        createFakePlugin('foo_bar', pluginGroupDir);
    final Directory platformInterface =
        createFakePlugin('foo_platform_interface', pluginGroupDir);

    final Directory otherPlugin1 = createFakePlugin('bar', packagesDir);
    final Directory otherPlugin2 = createFakePlugin('baz', packagesDir);

    final String changedFileOutput = <File>[
      appFacing.childFile('foo.dart'),
      implementation.childFile('foo.dart'),
      platformInterface.childFile('pubspec.yaml'),
      platformInterface.childDirectory('lib').childFile('foo.dart'),
      otherPlugin1.childFile('bar.dart'),
      otherPlugin2.childFile('baz.dart'),
    ].map((File file) => file.path).join('\n');
    processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
      MockProcess(stdout: changedFileOutput),
    ];

    final List<String> output =
        await runCapturingPrint(runner, <String>['federation-safety-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for foo/foo...'),
        contains(
            'Ignoring potentially dangerous change, as this appears to be a mass change.'),
        contains('Running for foo_bar...'),
        contains(
            'Ignoring potentially dangerous change, as this appears to be a mass change.'),
        contains('Ran for 2 package(s) (2 with warnings)'),
      ]),
    );
  });
}
