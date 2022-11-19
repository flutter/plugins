// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/make_deps_path_based_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/package_command_test.mocks.dart';
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
  void addDependencies(
      RepositoryPackage package, Iterable<String> dependencies) {
    final List<String> lines = package.pubspecFile.readAsLinesSync();
    final int dependenciesStartIndex = lines.indexOf('dependencies:');
    assert(dependenciesStartIndex != -1);
    lines.insertAll(dependenciesStartIndex + 1, <String>[
      for (final String dependency in dependencies) '  $dependency: ^1.0.0',
    ]);
    package.pubspecFile.writeAsStringSync(lines.join('\n'));
  }

  /// Adds a 'dev_dependencies:' section with entries for each package in
  /// [dependencies] to [package].
  void addDevDependenciesSection(
      RepositoryPackage package, Iterable<String> devDependencies) {
    final String originalContent = package.pubspecFile.readAsStringSync();
    package.pubspecFile.writeAsStringSync('''
$originalContent

dev_dependencies:
${devDependencies.map((String dep) => '  $dep: ^1.0.0').join('\n')}
''');
  }

  test('no-ops for no plugins', () async {
    createFakePackage('foo', packagesDir, isFlutter: true);
    final RepositoryPackage packageBar =
        createFakePackage('bar', packagesDir, isFlutter: true);
    addDependencies(packageBar, <String>['foo']);
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

  test('rewrites "dependencies" references', () async {
    final RepositoryPackage simplePackage =
        createFakePackage('foo', packagesDir, isFlutter: true);
    final Directory pluginGroup = packagesDir.childDirectory('bar');

    createFakePackage('bar_platform_interface', pluginGroup, isFlutter: true);
    final RepositoryPackage pluginImplementation =
        createFakePlugin('bar_android', pluginGroup);
    final RepositoryPackage pluginAppFacing =
        createFakePlugin('bar', pluginGroup);

    addDependencies(simplePackage, <String>[
      'bar',
      'bar_android',
      'bar_platform_interface',
    ]);
    addDependencies(pluginAppFacing, <String>[
      'bar_platform_interface',
      'bar_android',
    ]);
    addDependencies(pluginImplementation, <String>[
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

  test('rewrites "dev_dependencies" references', () async {
    createFakePackage('foo', packagesDir);
    final RepositoryPackage builderPackage =
        createFakePackage('foo_builder', packagesDir);

    addDevDependenciesSection(builderPackage, <String>[
      'foo',
    ]);

    final List<String> output = await runCapturingPrint(
        runner, <String>['make-deps-path-based', '--target-dependencies=foo']);

    expect(
        output,
        containsAll(<String>[
          'Rewriting references to: foo...',
          '  Modified packages/foo_builder/pubspec.yaml',
        ]));

    expect(
        builderPackage.pubspecFile.readAsLinesSync(),
        containsAllInOrder(<String>[
          '# FOR TESTING ONLY. DO NOT MERGE.',
          'dependency_overrides:',
          '  foo:',
          '    path: ../foo',
        ]));
  });

  test(
      'alphabetizes overrides from different sectinos to avoid lint warnings in analysis',
      () async {
    createFakePackage('a', packagesDir);
    createFakePackage('b', packagesDir);
    createFakePackage('c', packagesDir);
    final RepositoryPackage targetPackage =
        createFakePackage('target', packagesDir);

    addDependencies(targetPackage, <String>['a', 'c']);
    addDevDependenciesSection(targetPackage, <String>['b']);

    final List<String> output = await runCapturingPrint(runner,
        <String>['make-deps-path-based', '--target-dependencies=c,a,b']);

    expect(
        output,
        containsAllInOrder(<String>[
          'Rewriting references to: c, a, b...',
          '  Modified packages/target/pubspec.yaml',
        ]));

    expect(
        targetPackage.pubspecFile.readAsLinesSync(),
        containsAllInOrder(<String>[
          '# FOR TESTING ONLY. DO NOT MERGE.',
          'dependency_overrides:',
          '  a:',
          '    path: ../a',
          '  b:',
          '    path: ../b',
          '  c:',
          '    path: ../c',
        ]));
  });

  // This test case ensures that running CI using this command on an interim
  // PR that itself used this command won't fail on the rewrite step.
  test('running a second time no-ops without failing', () async {
    final RepositoryPackage simplePackage =
        createFakePackage('foo', packagesDir, isFlutter: true);
    final Directory pluginGroup = packagesDir.childDirectory('bar');

    createFakePackage('bar_platform_interface', pluginGroup, isFlutter: true);
    final RepositoryPackage pluginImplementation =
        createFakePlugin('bar_android', pluginGroup);
    final RepositoryPackage pluginAppFacing =
        createFakePlugin('bar', pluginGroup);

    addDependencies(simplePackage, <String>[
      'bar',
      'bar_android',
      'bar_platform_interface',
    ]);
    addDependencies(pluginAppFacing, <String>[
      'bar_platform_interface',
      'bar_android',
    ]);
    addDependencies(pluginImplementation, <String>[
      'bar_platform_interface',
    ]);

    await runCapturingPrint(runner, <String>[
      'make-deps-path-based',
      '--target-dependencies=bar,bar_platform_interface'
    ]);
    final List<String> output = await runCapturingPrint(runner, <String>[
      'make-deps-path-based',
      '--target-dependencies=bar,bar_platform_interface'
    ]);

    expect(
        output,
        containsAll(<String>[
          'Rewriting references to: bar, bar_platform_interface...',
          '  Skipped packages/bar/bar/pubspec.yaml - Already rewritten',
          '  Skipped packages/bar/bar_android/pubspec.yaml - Already rewritten',
          '  Skipped packages/foo/pubspec.yaml - Already rewritten',
        ]));
  });

  group('target-dependencies-with-non-breaking-updates', () {
    test('no-ops for no published changes', () async {
      final RepositoryPackage package = createFakePackage('foo', packagesDir);

      final String changedFileOutput = <File>[
        package.pubspecFile,
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      // Simulate no change to the version in the interface's pubspec.yaml.
      processRunner.mockProcessesForExecutable['git-show'] = <io.Process>[
        MockProcess(stdout: package.pubspecFile.readAsStringSync()),
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
      final RepositoryPackage package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = package.pubspecFile;
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
      final RepositoryPackage package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = package.pubspecFile;
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
      final RepositoryPackage package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = package.pubspecFile;
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
      final RepositoryPackage package =
          createFakePackage('foo', packagesDir, version: newVersion);

      final File pubspecFile = package.pubspecFile;
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

    test('skips anything outside of the packages directory', () async {
      final Directory toolDir = packagesDir.parent.childDirectory('tool');
      const String newVersion = '1.1.0';
      final RepositoryPackage package = createFakePackage(
          'flutter_plugin_tools', toolDir,
          version: newVersion);

      // Simulate a minor version change so it would be a target.
      final File pubspecFile = package.pubspecFile;
      final String changedFileOutput = <File>[
        pubspecFile,
      ].map((File file) => file.path).join('\n');
      processRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: changedFileOutput),
      ];
      final String gitPubspecContents =
          pubspecFile.readAsStringSync().replaceAll(newVersion, '1.0.0');
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
          contains(
              'Skipping /tool/flutter_plugin_tools/pubspec.yaml; not in packages directory.'),
          contains('No target dependencies'),
        ]),
      );
    });
  });
}
