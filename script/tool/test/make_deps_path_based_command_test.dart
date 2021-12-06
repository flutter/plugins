// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
import 'package:flutter_plugin_tools/src/make_deps_path_based_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  FileSystem fileSystem;
  late Directory packagesDir;
  late CommandRunner<void> runner;
  late RecordingProcessRunner processRunner;

  setUp(() {
    fileSystem = MemoryFileSystem();
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
    final MakeDepsPathBasedCommand command =
        MakeDepsPathBasedCommand(packagesDir, gitDir: gitDir);

    runner = CommandRunner<void>(
        'make-deps-path-based_command', 'Test for $MakeDepsPathBasedCommand');
    runner.addCommand(command);
  });

  /// Adds dummy 'dependencies:' entries for each package in [dependencies]
  /// to [package].
  void _addDependencies(
      RepositoryPackage package, Iterable<String> dependencies) {
    final List<String> lines = package.pubspecFile.readAsLinesSync();
    final int dependenciesStartIndex = lines.indexOf('dependencies:');
    assert(dependenciesStartIndex != -1);
    lines.insertAll(dependenciesStartIndex + 1, <String>[
      for (final String dependency in dependencies) '  $dependency: ^1.0.0',
    ]);
    package.pubspecFile.writeAsStringSync(lines.join('\n'));
  }

  test('no-ops for no plugins', () async {
    RepositoryPackage(createFakePackage('foo', packagesDir, isFlutter: true));
    final RepositoryPackage packageBar = RepositoryPackage(
        createFakePackage('bar', packagesDir, isFlutter: true));
    _addDependencies(packageBar, <String>['foo']);
    final String originalPubspecContents =
        packageBar.pubspecFile.readAsStringSync();

    final List<String> output =
        await runCapturingPrint(runner, <String>['make-deps-path-based']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('No target dependencies'),
      ]),
    );
    // The 'foo' reference should not have been modified.
    expect(packageBar.pubspecFile.readAsStringSync(), originalPubspecContents);
  });

  test('rewrites references', () async {
    final RepositoryPackage simplePackage = RepositoryPackage(
        createFakePackage('foo', packagesDir, isFlutter: true));
    final Directory pluginGroup = packagesDir.childDirectory('bar');

    RepositoryPackage(createFakePackage('bar_platform_interface', pluginGroup,
        isFlutter: true));
    final RepositoryPackage pluginImplementation =
        RepositoryPackage(createFakePlugin('bar_android', pluginGroup));
    final RepositoryPackage pluginAppFacing =
        RepositoryPackage(createFakePlugin('bar', pluginGroup));

    _addDependencies(simplePackage, <String>[
      'bar',
      'bar_android',
      'bar_platform_interface',
    ]);
    _addDependencies(pluginAppFacing, <String>[
      'bar_platform_interface',
      'bar_android',
    ]);
    _addDependencies(pluginImplementation, <String>[
      'bar_platform_interface',
    ]);

    final List<String> output = await runCapturingPrint(runner, <String>[
      'make-deps-path-based',
      '--target-dependencies=bar,bar_platform_interface'
    ]);

    expect(
        output,
        containsAll(<String>[
          'Rewriting references to: bar, bar_platform_interface...',
          '  Modified packages/bar/bar/pubspec.yaml',
          '  Modified packages/bar/bar_android/pubspec.yaml',
          '  Modified packages/foo/pubspec.yaml',
        ]));
    expect(
        output,
        isNot(contains(
            '  Modified packages/bar/bar_platform_interface/pubspec.yaml')));

    expect(
        simplePackage.pubspecFile.readAsLinesSync(),
        containsAllInOrder(<String>[
          '# FOR TESTING ONLY. DO NOT MERGE.',
          'dependency_overrides:',
          '  bar:',
          '    path: ../bar/bar',
          '  bar_platform_interface:',
          '    path: ../bar/bar_platform_interface',
        ]));
    expect(
        pluginAppFacing.pubspecFile.readAsLinesSync(),
        containsAllInOrder(<String>[
          'dependency_overrides:',
          '  bar_platform_interface:',
          '    path: ../../bar/bar_platform_interface',
        ]));
  });

  group('target-dependencies-with-non-breaking-updates', () {
    test('no-ops for no published changes', () async {
      final Directory package = createFakePackage('foo', packagesDir);

      final String changedFileOutput = <File>[
        package.childFile('pubspec.yaml'),
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      // Simulate no change to the version in the interface's pubspec.yaml.
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(
            stdout: RepositoryPackage(package).pubspecFile.readAsStringSync()),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'make-deps-path-based',
        '--target-dependencies-with-non-breaking-updates'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No target dependencies'),
        ]),
      );
    });

    test('no-ops for no deleted packages', () async {
      final String changedFileOutput = <File>[
        // A change for a file that's not on disk simulates a deletion.
        packagesDir.childDirectory('foo').childFile('pubspec.yaml'),
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'make-deps-path-based',
        '--target-dependencies-with-non-breaking-updates'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Skipping foo; deleted.'),
          contains('No target dependencies'),
        ]),
      );
    });

    test('includes bugfix version changes as targets', () async {
      const String newVersion = '1.0.1';
      final Directory package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = RepositoryPackage(package).pubspecFile;
      final String changedFileOutput = <File>[
        pubspecFile,
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      final String gitPubspecContents =
          pubspecFile.readAsStringSync().replaceAll(newVersion, '1.0.0');
      // Simulate no change to the version in the interface's pubspec.yaml.
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: gitPubspecContents),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'make-deps-path-based',
        '--target-dependencies-with-non-breaking-updates'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Rewriting references to: foo...'),
        ]),
      );
    });

    test('includes minor version changes to 1.0+ as targets', () async {
      const String newVersion = '1.1.0';
      final Directory package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = RepositoryPackage(package).pubspecFile;
      final String changedFileOutput = <File>[
        pubspecFile,
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      final String gitPubspecContents =
          pubspecFile.readAsStringSync().replaceAll(newVersion, '1.0.0');
      // Simulate no change to the version in the interface's pubspec.yaml.
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: gitPubspecContents),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'make-deps-path-based',
        '--target-dependencies-with-non-breaking-updates'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Rewriting references to: foo...'),
        ]),
      );
    });

    test('does not include major version changes as targets', () async {
      const String newVersion = '2.0.0';
      final Directory package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = RepositoryPackage(package).pubspecFile;
      final String changedFileOutput = <File>[
        pubspecFile,
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      final String gitPubspecContents =
          pubspecFile.readAsStringSync().replaceAll(newVersion, '1.0.0');
      // Simulate no change to the version in the interface's pubspec.yaml.
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: gitPubspecContents),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'make-deps-path-based',
        '--target-dependencies-with-non-breaking-updates'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No target dependencies'),
        ]),
      );
    });

    test('does not include minor version changes to 0.x as targets', () async {
      const String newVersion = '0.8.0';
      final Directory package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = RepositoryPackage(package).pubspecFile;
      final String changedFileOutput = <File>[
        pubspecFile,
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      final String gitPubspecContents =
          pubspecFile.readAsStringSync().replaceAll(newVersion, '0.7.0');
      // Simulate no change to the version in the interface's pubspec.yaml.
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: gitPubspecContents),
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'make-deps-path-based',
        '--target-dependencies-with-non-breaking-updates'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No target dependencies'),
        ]),
      );
    });
  });
}
