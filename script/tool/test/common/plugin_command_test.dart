// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_command.dart';
import 'package:flutter_plugin_tools/src/common/process_runner.dart';
import 'package:git/git.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../util.dart';
import 'plugin_command_test.mocks.dart';

@GenerateMocks(<Type>[GitDir])
void main() {
  late RecordingProcessRunner processRunner;
  late SamplePluginCommand command;
  late CommandRunner<void> runner;
  late FileSystem fileSystem;
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late Directory thirdPartyPackagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockPlatform = MockPlatform();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    thirdPartyPackagesDir = packagesDir.parent
        .childDirectory('third_party')
        .childDirectory('packages');

    final MockGitDir gitDir = MockGitDir();
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      final List<String> arguments =
          invocation.positionalArguments[0]! as List<String>;
      // Attach the first argument to the command to make targeting the mock
      // results easier.
      final String gitCommand = arguments.removeAt(0);
      return processRunner.run('git-$gitCommand', arguments);
    });
    processRunner = RecordingProcessRunner();
    command = SamplePluginCommand(
      packagesDir,
      processRunner: processRunner,
      platform: mockPlatform,
      gitDir: gitDir,
    );
    runner =
        CommandRunner<void>('common_command', 'Test for common functionality');
    runner.addCommand(command);
  });

  group('plugin iteration', () {
    test('all plugins from file system', () async {
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
      await runCapturingPrint(runner, <String>['sample']);
      expect(command.plugins,
          unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('includes both plugins and packages', () async {
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
      final Directory package3 = createFakePackage('package3', packagesDir);
      final Directory package4 = createFakePackage('package4', packagesDir);
      await runCapturingPrint(runner, <String>['sample']);
      expect(
          command.plugins,
          unorderedEquals(<String>[
            plugin1.path,
            plugin2.path,
            package3.path,
            package4.path,
          ]));
    });

    test('all plugins includes third_party/packages', () async {
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
      final Directory plugin3 =
          createFakePlugin('plugin3', thirdPartyPackagesDir);
      await runCapturingPrint(runner, <String>['sample']);
      expect(command.plugins,
          unorderedEquals(<String>[plugin1.path, plugin2.path, plugin3.path]));
    });

    test('--packages limits packages', () async {
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      createFakePlugin('plugin2', packagesDir);
      createFakePackage('package3', packagesDir);
      final Directory package4 = createFakePackage('package4', packagesDir);
      await runCapturingPrint(
          runner, <String>['sample', '--packages=plugin1,package4']);
      expect(
          command.plugins,
          unorderedEquals(<String>[
            plugin1.path,
            package4.path,
          ]));
    });

    test('--plugins acts as an alias to --packages', () async {
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      createFakePlugin('plugin2', packagesDir);
      createFakePackage('package3', packagesDir);
      final Directory package4 = createFakePackage('package4', packagesDir);
      await runCapturingPrint(
          runner, <String>['sample', '--plugins=plugin1,package4']);
      expect(
          command.plugins,
          unorderedEquals(<String>[
            plugin1.path,
            package4.path,
          ]));
    });

    test('exclude packages when packages flag is specified', () async {
      createFakePlugin('plugin1', packagesDir);
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
      await runCapturingPrint(runner, <String>[
        'sample',
        '--packages=plugin1,plugin2',
        '--exclude=plugin1'
      ]);
      expect(command.plugins, unorderedEquals(<String>[plugin2.path]));
    });

    test('exclude packages when packages flag isn\'t specified', () async {
      createFakePlugin('plugin1', packagesDir);
      createFakePlugin('plugin2', packagesDir);
      await runCapturingPrint(
          runner, <String>['sample', '--exclude=plugin1,plugin2']);
      expect(command.plugins, unorderedEquals(<String>[]));
    });

    test('exclude federated plugins when packages flag is specified', () async {
      createFakePlugin('plugin1', packagesDir.childDirectory('federated'));
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
      await runCapturingPrint(runner, <String>[
        'sample',
        '--packages=federated/plugin1,plugin2',
        '--exclude=federated/plugin1'
      ]);
      expect(command.plugins, unorderedEquals(<String>[plugin2.path]));
    });

    test('exclude entire federated plugins when packages flag is specified',
        () async {
      createFakePlugin('plugin1', packagesDir.childDirectory('federated'));
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
      await runCapturingPrint(runner, <String>[
        'sample',
        '--packages=federated/plugin1,plugin2',
        '--exclude=federated'
      ]);
      expect(command.plugins, unorderedEquals(<String>[plugin2.path]));
    });

    test('exclude accepts config files', () async {
      createFakePlugin('plugin1', packagesDir);
      final File configFile = packagesDir.childFile('exclude.yaml');
      configFile.writeAsStringSync('- plugin1');

      await runCapturingPrint(runner, <String>[
        'sample',
        '--packages=plugin1',
        '--exclude=${configFile.path}'
      ]);
      expect(command.plugins, unorderedEquals(<String>[]));
    });

    test(
        'explicitly specifying the plugin (group) name of a federated plugin '
        'should include all plugins in the group', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: '''
packages/plugin1/plugin1/plugin1.dart
'''),
      ];
      final Directory pluginGroup = packagesDir.childDirectory('plugin1');
      final Directory appFacingPackage =
          createFakePlugin('plugin1', pluginGroup);
      final Directory platformInterfacePackage =
          createFakePlugin('plugin1_platform_interface', pluginGroup);
      final Directory implementationPackage =
          createFakePlugin('plugin1_web', pluginGroup);

      await runCapturingPrint(
          runner, <String>['sample', '--base-sha=main', '--packages=plugin1']);

      expect(
          command.plugins,
          unorderedEquals(<String>[
            appFacingPackage.path,
            platformInterfacePackage.path,
            implementationPackage.path
          ]));
    });

    test(
        'specifying the app-facing package of a federated plugin using its '
        'fully qualified name should include only that package', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: '''
packages/plugin1/plugin1/plugin1.dart
'''),
      ];
      final Directory pluginGroup = packagesDir.childDirectory('plugin1');
      final Directory appFacingPackage =
          createFakePlugin('plugin1', pluginGroup);
      createFakePlugin('plugin1_platform_interface', pluginGroup);
      createFakePlugin('plugin1_web', pluginGroup);

      await runCapturingPrint(runner,
          <String>['sample', '--base-sha=main', '--packages=plugin1/plugin1']);

      expect(command.plugins, unorderedEquals(<String>[appFacingPackage.path]));
    });

    test(
        'specifying a package of a federated plugin by its name should '
        'include only that package', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: '''
packages/plugin1/plugin1/plugin1.dart
'''),
      ];
      final Directory pluginGroup = packagesDir.childDirectory('plugin1');

      createFakePlugin('plugin1', pluginGroup);
      final Directory platformInterfacePackage =
          createFakePlugin('plugin1_platform_interface', pluginGroup);
      createFakePlugin('plugin1_web', pluginGroup);

      await runCapturingPrint(runner, <String>[
        'sample',
        '--base-sha=main',
        '--packages=plugin1_platform_interface'
      ]);

      expect(command.plugins,
          unorderedEquals(<String>[platformInterfacePackage.path]));
    });

    test('returns subpackages after the enclosing package', () async {
      final SamplePluginCommand localCommand = SamplePluginCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: MockGitDir(),
        includeSubpackages: true,
      );
      final CommandRunner<void> localRunner =
          CommandRunner<void>('common_command', 'subpackage testing');
      localRunner.addCommand(localCommand);

      final Directory package = createFakePackage('apackage', packagesDir);

      await runCapturingPrint(localRunner, <String>['sample']);
      expect(
          localCommand.plugins,
          containsAllInOrder(<String>[
            package.path,
            package.childDirectory('example').path,
          ]));
    });

    group('conflicting package selection', () {
      test('does not allow --packages with --run-on-changed-packages',
          () async {
        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'sample',
          '--run-on-changed-packages',
          '--packages=plugin1',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Only one of --packages, --run-on-changed-packages, or '
                  '--packages-for-branch can be provided.')
            ]));
      });

      test('does not allow --packages with --packages-for-branch', () async {
        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'sample',
          '--packages-for-branch',
          '--packages=plugin1',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Only one of --packages, --run-on-changed-packages, or '
                  '--packages-for-branch can be provided.')
            ]));
      });

      test(
          'does not allow --run-on-changed-packages with --packages-for-branch',
          () async {
        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'sample',
          '--packages-for-branch',
          '--packages=plugin1',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Only one of --packages, --run-on-changed-packages, or '
                  '--packages-for-branch can be provided.')
            ]));
      });
    });

    group('test run-on-changed-packages', () {
      test('all plugins should be tested if there are no changes.', () async {
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test(
          'all plugins should be tested if there are no plugin related changes.',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: 'AUTHORS'),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('all plugins should be tested if .cirrus.yml changes.', () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
.cirrus.yml
packages/plugin1/CHANGELOG
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('all plugins should be tested if .ci.yaml changes', () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
.ci.yaml
packages/plugin1/CHANGELOG
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('all plugins should be tested if anything in .ci/ changes',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
.ci/Dockerfile
packages/plugin1/CHANGELOG
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('all plugins should be tested if anything in script changes.',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
script/tool_runner.sh
packages/plugin1/CHANGELOG
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('all plugins should be tested if the root analysis options change.',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
analysis_options.yaml
packages/plugin1/CHANGELOG
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('all plugins should be tested if formatting options change.',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
.clang-format
packages/plugin1/CHANGELOG
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test('Only changed plugin should be tested.', () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: 'packages/plugin1/plugin1.dart'),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        createFakePlugin('plugin2', packagesDir);
        final List<String> output = await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains(
                  'Running for all packages that have changed relative to "main"'),
            ]));

        expect(command.plugins, unorderedEquals(<String>[plugin1.path]));
      });

      test('multiple files in one plugin should also test the plugin',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/plugin1/plugin1.dart
packages/plugin1/ios/plugin1.m
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        createFakePlugin('plugin2', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins, unorderedEquals(<String>[plugin1.path]));
      });

      test('multiple plugins changed should test all the changed plugins',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/plugin1/plugin1.dart
packages/plugin2/ios/plugin2.m
'''),
        ];
        final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
        final Directory plugin2 = createFakePlugin('plugin2', packagesDir);
        createFakePlugin('plugin3', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[plugin1.path, plugin2.path]));
      });

      test(
          'multiple plugins inside the same plugin group changed should output the plugin group name',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/plugin1/plugin1/plugin1.dart
packages/plugin1/plugin1_platform_interface/plugin1_platform_interface.dart
packages/plugin1/plugin1_web/plugin1_web.dart
'''),
        ];
        final Directory plugin1 =
            createFakePlugin('plugin1', packagesDir.childDirectory('plugin1'));
        createFakePlugin('plugin2', packagesDir);
        createFakePlugin('plugin3', packagesDir);
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins, unorderedEquals(<String>[plugin1.path]));
      });

      test(
          'changing one plugin in a federated group should only include that plugin',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/plugin1/plugin1/plugin1.dart
'''),
        ];
        final Directory plugin1 =
            createFakePlugin('plugin1', packagesDir.childDirectory('plugin1'));
        createFakePlugin('plugin1_platform_interface',
            packagesDir.childDirectory('plugin1'));
        createFakePlugin('plugin1_web', packagesDir.childDirectory('plugin1'));
        await runCapturingPrint(runner,
            <String>['sample', '--base-sha=main', '--run-on-changed-packages']);

        expect(command.plugins, unorderedEquals(<String>[plugin1.path]));
      });

      test('--exclude flag works with --run-on-changed-packages', () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/plugin1/plugin1.dart
packages/plugin2/ios/plugin2.m
packages/plugin3/plugin3.dart
'''),
        ];
        final Directory plugin1 =
            createFakePlugin('plugin1', packagesDir.childDirectory('plugin1'));
        createFakePlugin('plugin2', packagesDir);
        createFakePlugin('plugin3', packagesDir);
        await runCapturingPrint(runner, <String>[
          'sample',
          '--exclude=plugin2,plugin3',
          '--base-sha=main',
          '--run-on-changed-packages'
        ]);

        expect(command.plugins, unorderedEquals(<String>[plugin1.path]));
      });
    });

    group('test run-on-dirty-packages', () {
      test('no packages should be tested if there are no changes.', () async {
        createFakePackage('a_package', packagesDir);
        await runCapturingPrint(
            runner, <String>['sample', '--run-on-dirty-packages']);

        expect(command.plugins, unorderedEquals(<String>[]));
      });

      test(
          'no packages should be tested if there are no plugin related changes.',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: 'AUTHORS'),
        ];
        createFakePackage('a_package', packagesDir);
        await runCapturingPrint(
            runner, <String>['sample', '--run-on-dirty-packages']);

        expect(command.plugins, unorderedEquals(<String>[]));
      });

      test('no packages should be tested even if special repo files change.',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
.cirrus.yml
.ci.yaml
.ci/Dockerfile
.clang-format
analysis_options.yaml
script/tool_runner.sh
'''),
        ];
        createFakePackage('a_package', packagesDir);
        await runCapturingPrint(
            runner, <String>['sample', '--run-on-dirty-packages']);

        expect(command.plugins, unorderedEquals(<String>[]));
      });

      test('Only changed packages should be tested.', () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: 'packages/a_package/lib/a_package.dart'),
        ];
        final Directory packageA = createFakePackage('a_package', packagesDir);
        createFakePlugin('b_package', packagesDir);
        final List<String> output = await runCapturingPrint(
            runner, <String>['sample', '--run-on-dirty-packages']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains(
                  'Running for all packages that have uncommitted changes'),
            ]));

        expect(command.plugins, unorderedEquals(<String>[packageA.path]));
      });

      test('multiple packages changed should test all the changed packages',
          () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/a_package/lib/a_package.dart
packages/b_package/lib/src/foo.dart
'''),
        ];
        final Directory packageA = createFakePackage('a_package', packagesDir);
        final Directory packageB = createFakePackage('b_package', packagesDir);
        createFakePackage('c_package', packagesDir);
        await runCapturingPrint(
            runner, <String>['sample', '--run-on-dirty-packages']);

        expect(command.plugins,
            unorderedEquals(<String>[packageA.path, packageB.path]));
      });

      test('honors --exclude flag', () async {
        processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
          MockProcess(stdout: '''
packages/a_package/lib/a_package.dart
packages/b_package/lib/src/foo.dart
'''),
        ];
        final Directory packageA = createFakePackage('a_package', packagesDir);
        createFakePackage('b_package', packagesDir);
        createFakePackage('c_package', packagesDir);
        await runCapturingPrint(runner, <String>[
          'sample',
          '--exclude=b_package',
          '--run-on-dirty-packages'
        ]);

        expect(command.plugins, unorderedEquals(<String>[packageA.path]));
      });
    });
  });

  group('--packages-for-branch', () {
    test('only tests changed packages on a branch', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: 'packages/plugin1/plugin1.dart'),
      ];
      processRunner.mockProcessesForExecutable['git-rev-parse'] = <Process>[
        MockProcess(stdout: 'a-branch'),
      ];
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      createFakePlugin('plugin2', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['sample', '--packages-for-branch']);

      expect(command.plugins, unorderedEquals(<String>[plugin1.path]));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('--packages-for-branch: running on changed packages'),
          ]));
    });

    test('tests all packages on main', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: 'packages/plugin1/plugin1.dart'),
      ];
      processRunner.mockProcessesForExecutable['git-rev-parse'] = <Process>[
        MockProcess(stdout: 'main'),
      ];
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['sample', '--packages-for-branch']);

      expect(command.plugins,
          unorderedEquals(<String>[plugin1.path, plugin2.path]));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('--packages-for-branch: running on all packages'),
          ]));
    });

    test('tests all packages on master', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: 'packages/plugin1/plugin1.dart'),
      ];
      processRunner.mockProcessesForExecutable['git-rev-parse'] = <Process>[
        MockProcess(stdout: 'master'),
      ];
      final Directory plugin1 = createFakePlugin('plugin1', packagesDir);
      final Directory plugin2 = createFakePlugin('plugin2', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['sample', '--packages-for-branch']);

      expect(command.plugins,
          unorderedEquals(<String>[plugin1.path, plugin2.path]));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('--packages-for-branch: running on all packages'),
          ]));
    });

    test('throws if getting the branch fails', () async {
      processRunner.mockProcessesForExecutable['git-diff'] = <Process>[
        MockProcess(stdout: 'packages/plugin1/plugin1.dart'),
      ];
      processRunner.mockProcessesForExecutable['git-rev-parse'] = <Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['sample', '--packages-for-branch'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unabled to determine branch'),
          ]));
    });
  });

  group('sharding', () {
    test('distributes evenly when evenly divisible', () async {
      final List<List<Directory>> expectedShards = <List<Directory>>[
        <Directory>[
          createFakePackage('package1', packagesDir),
          createFakePackage('package2', packagesDir),
          createFakePackage('package3', packagesDir),
        ],
        <Directory>[
          createFakePackage('package4', packagesDir),
          createFakePackage('package5', packagesDir),
          createFakePackage('package6', packagesDir),
        ],
        <Directory>[
          createFakePackage('package7', packagesDir),
          createFakePackage('package8', packagesDir),
          createFakePackage('package9', packagesDir),
        ],
      ];

      for (int i = 0; i < expectedShards.length; ++i) {
        final SamplePluginCommand localCommand = SamplePluginCommand(
          packagesDir,
          processRunner: processRunner,
          platform: mockPlatform,
          gitDir: MockGitDir(),
        );
        final CommandRunner<void> localRunner =
            CommandRunner<void>('common_command', 'Shard testing');
        localRunner.addCommand(localCommand);

        await runCapturingPrint(localRunner, <String>[
          'sample',
          '--shardIndex=$i',
          '--shardCount=3',
        ]);
        expect(
            localCommand.plugins,
            unorderedEquals(expectedShards[i]
                .map((Directory packageDir) => packageDir.path)
                .toList()));
      }
    });

    test('distributes as evenly as possible when not evenly divisible',
        () async {
      final List<List<Directory>> expectedShards = <List<Directory>>[
        <Directory>[
          createFakePackage('package1', packagesDir),
          createFakePackage('package2', packagesDir),
          createFakePackage('package3', packagesDir),
        ],
        <Directory>[
          createFakePackage('package4', packagesDir),
          createFakePackage('package5', packagesDir),
          createFakePackage('package6', packagesDir),
        ],
        <Directory>[
          createFakePackage('package7', packagesDir),
          createFakePackage('package8', packagesDir),
        ],
      ];

      for (int i = 0; i < expectedShards.length; ++i) {
        final SamplePluginCommand localCommand = SamplePluginCommand(
          packagesDir,
          processRunner: processRunner,
          platform: mockPlatform,
          gitDir: MockGitDir(),
        );
        final CommandRunner<void> localRunner =
            CommandRunner<void>('common_command', 'Shard testing');
        localRunner.addCommand(localCommand);

        await runCapturingPrint(localRunner, <String>[
          'sample',
          '--shardIndex=$i',
          '--shardCount=3',
        ]);
        expect(
            localCommand.plugins,
            unorderedEquals(expectedShards[i]
                .map((Directory packageDir) => packageDir.path)
                .toList()));
      }
    });

    // In CI (which is the use case for sharding) we often want to run muliple
    // commands on the same set of packages, but the exclusion lists for those
    // commands may be different. In those cases we still want all the commands
    // to operate on a consistent set of plugins.
    //
    // E.g., some commands require running build-examples in a previous step;
    // excluding some plugins from the later step shouldn't change what's tested
    // in each shard, as it may no longer align with what was built.
    test('counts excluded plugins when sharding', () async {
      final List<List<Directory>> expectedShards = <List<Directory>>[
        <Directory>[
          createFakePackage('package1', packagesDir),
          createFakePackage('package2', packagesDir),
          createFakePackage('package3', packagesDir),
        ],
        <Directory>[
          createFakePackage('package4', packagesDir),
          createFakePackage('package5', packagesDir),
          createFakePackage('package6', packagesDir),
        ],
        <Directory>[
          createFakePackage('package7', packagesDir),
        ],
      ];
      // These would be in the last shard, but are excluded.
      createFakePackage('package8', packagesDir);
      createFakePackage('package9', packagesDir);

      for (int i = 0; i < expectedShards.length; ++i) {
        final SamplePluginCommand localCommand = SamplePluginCommand(
          packagesDir,
          processRunner: processRunner,
          platform: mockPlatform,
          gitDir: MockGitDir(),
        );
        final CommandRunner<void> localRunner =
            CommandRunner<void>('common_command', 'Shard testing');
        localRunner.addCommand(localCommand);

        await runCapturingPrint(localRunner, <String>[
          'sample',
          '--shardIndex=$i',
          '--shardCount=3',
          '--exclude=package8,package9',
        ]);
        expect(
            localCommand.plugins,
            unorderedEquals(expectedShards[i]
                .map((Directory packageDir) => packageDir.path)
                .toList()));
      }
    });
  });
}

class SamplePluginCommand extends PluginCommand {
  SamplePluginCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
    GitDir? gitDir,
    this.includeSubpackages = false,
  }) : super(packagesDir,
            processRunner: processRunner, platform: platform, gitDir: gitDir);

  final List<String> plugins = <String>[];

  final bool includeSubpackages;

  @override
  final String name = 'sample';

  @override
  final String description = 'sample command';

  @override
  Future<void> run() async {
    final Stream<PackageEnumerationEntry> packages = includeSubpackages
        ? getTargetPackagesAndSubpackages()
        : getTargetPackages();
    await for (final PackageEnumerationEntry entry in packages) {
      plugins.add(entry.package.path);
    }
  }
}
