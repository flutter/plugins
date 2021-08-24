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
import 'package:flutter_plugin_tools/src/common/process_runner.dart';
import 'package:flutter_plugin_tools/src/publish_plugin_command.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'common/plugin_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  const String testPluginName = 'foo';

  late Directory packagesDir;
  late Directory pluginDir;
  late MockGitDir gitDir;
  late TestProcessRunner processRunner;
  late RecordingProcessRunner gitProcessRunner;
  late CommandRunner<void> commandRunner;
  late MockStdin mockStdin;
  late FileSystem fileSystem;

  void _createMockCredentialFile() {
    final String credentialPath = PublishPluginCommand.getCredentialPath();
    fileSystem.file(credentialPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('some credential');
  }

  setUp(() async {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    // TODO(stuartmorgan): Move this from setup to individual tests.
    pluginDir =
        createFakePlugin(testPluginName, packagesDir, examples: <String>[]);
    assert(pluginDir != null && pluginDir.existsSync());

    gitProcessRunner = RecordingProcessRunner();
    gitDir = MockGitDir();
    when(gitDir.path).thenReturn(packagesDir.parent.path);
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      final List<String> arguments =
          invocation.positionalArguments[0]! as List<String>;
      // Attach the first argument to the command to make targeting the mock
      // results easier.
      final String gitCommand = arguments.removeAt(0);
      return gitProcessRunner.run('git-$gitCommand', arguments);
    });

    processRunner = TestProcessRunner();
    mockStdin = MockStdin();
    commandRunner = CommandRunner<void>('tester', '')
      ..addCommand(PublishPluginCommand(packagesDir,
          processRunner: processRunner, stdinput: mockStdin, gitDir: gitDir));
  });

  group('Initial validation', () {
    test('requires a package flag', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          commandRunner, <String>['publish-plugin'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Must specify a package to publish.'),
          ]));
    });

    test('requires an existing flag', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--package', 'iamerror', '--no-push-tags'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(output,
          containsAllInOrder(<Matcher>[contains('iamerror does not exist')]));
    });

    test('refuses to proceed with dirty files', () async {
      gitProcessRunner.mockProcessesForExecutable['git-status'] = <io.Process>[
        MockProcess(stdout: '?? ${pluginDir.childFile('tmp').path}\n')
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags'
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('There are files in the package directory that haven\'t '
                'been saved in git. Refusing to publish these files:\n\n'
                '?? /packages/foo/tmp\n\n'
                'If the directory should be clean, you can run `git clean -xdf && '
                'git reset --hard HEAD` to wipe all local changes.'),
            contains('Failed, see above for details.'),
          ]));
    });

    test('fails immediately if the remote doesn\'t exist', () async {
      gitProcessRunner.mockProcessesForExecutable['git-remote'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--package', testPluginName],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Unable to find URL for remote upstream; cannot push tags'),
          ]));
    });

    test("doesn't validate the remote if it's not pushing tags", () async {
      // Checking the remote should fail.
      gitProcessRunner.mockProcessesForExecutable['git-remote'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release'
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running `pub publish ` in /packages/$testPluginName...'),
            contains('Package published!'),
            contains('Released [$testPluginName] successfully.'),
          ]));
    });

    test('can publish non-flutter package', () async {
      const String packageName = 'a_package';
      createFakePackage(packageName, packagesDir);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;

      final List<String> output = await runCapturingPrint(
          commandRunner, <String>[
        'publish-plugin',
        '--package',
        packageName,
        '--no-push-tags',
        '--no-tag-release'
      ]);

      expect(
        output,
        containsAllInOrder(
          <Matcher>[
            contains('Running `pub publish ` in /packages/a_package...'),
            contains('Package published!'),
          ],
        ),
      );
    });
  });

  group('Publishes package', () {
    test('while showing all output from pub publish to the user', () async {
      processRunner.mockPublishStdout = 'Foo';
      processRunner.mockPublishStderr = 'Bar';
      processRunner.mockPublishCompleteCode = 0;

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release'
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Foo'),
            contains('Bar'),
          ]));
    });

    test('forwards input from the user to `pub publish`', () async {
      mockStdin.mockUserInputs.add(utf8.encode('user input'));
      processRunner.mockPublishCompleteCode = 0;

      await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release'
      ]);

      expect(processRunner.mockPublishProcess.stdinMock.lines,
          contains('user input'));
    });

    test('forwards --pub-publish-flags to pub publish', () async {
      processRunner.mockPublishCompleteCode = 0;

      await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release',
        '--pub-publish-flags',
        '--dry-run,--server=foo'
      ]);

      expect(processRunner.mockPublishArgs.length, 4);
      expect(processRunner.mockPublishArgs[0], 'pub');
      expect(processRunner.mockPublishArgs[1], 'publish');
      expect(processRunner.mockPublishArgs[2], '--dry-run');
      expect(processRunner.mockPublishArgs[3], '--server=foo');
    });

    test(
        '--skip-confirmation flag automatically adds --force to --pub-publish-flags',
        () async {
      processRunner.mockPublishCompleteCode = 0;
      _createMockCredentialFile();

      await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release',
        '--skip-confirmation',
        '--pub-publish-flags',
        '--server=foo'
      ]);

      expect(processRunner.mockPublishArgs.length, 4);
      expect(processRunner.mockPublishArgs[0], 'pub');
      expect(processRunner.mockPublishArgs[1], 'publish');
      expect(processRunner.mockPublishArgs[2], '--server=foo');
      expect(processRunner.mockPublishArgs[3], '--force');
    });

    test('throws if pub publish fails', () async {
      processRunner.mockPublishCompleteCode = 128;

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Publish foo failed.'),
          ]));
    });

    test('publish, dry run', () async {
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--dry-run',
        '--no-push-tags',
        '--no-tag-release',
      ]);

      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
      expect(
          output,
          containsAllInOrder(<String>[
            '===============  DRY RUN ===============',
            'Running `pub publish ` in ${pluginDir.path}...\n',
            'Done!'
          ]));
    });
  });

  group('Tags release', () {
    test('with the version and name from the pubspec.yaml', () async {
      processRunner.mockPublishCompleteCode = 0;

      await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
      ]);

      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-tag', <String>['$testPluginName-v0.0.1'], null)));
    });

    test('only if publishing succeeded', () async {
      processRunner.mockPublishCompleteCode = 128;

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Publish foo failed.'),
          ]));
      expect(
          gitProcessRunner.recordedCalls,
          isNot(contains(
              const ProcessCall('git-tag', <String>['foo-v0.0.1'], null))));
    });
  });

  group('Pushes tags', () {
    test('requires user confirmation', () async {
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'help';

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(output, contains('Tag push canceled.'));
    });

    test('to upstream by default', () async {
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
      ]);

      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall('git-push',
              <String>['upstream', '$testPluginName-v0.0.1'], null)));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Released [$testPluginName] successfully.'),
          ]));
    });

    test('does not ask for user input if the --skip-confirmation flag is on',
        () async {
      processRunner.mockPublishCompleteCode = 0;
      _createMockCredentialFile();

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--skip-confirmation',
        '--package',
        testPluginName,
      ]);

      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall('git-push',
              <String>['upstream', '$testPluginName-v0.0.1'], null)));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Released [$testPluginName] successfully.'),
          ]));
    });

    test('to upstream by default, dry run', () async {
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishCompleteCode = 1;
      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--package', testPluginName, '--dry-run']);

      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
      expect(
          output,
          containsAllInOrder(<String>[
            '===============  DRY RUN ===============',
            'Running `pub publish ` in ${pluginDir.path}...\n',
            'Tagging release $testPluginName-v0.0.1...',
            'Pushing tag to upstream...',
            'Done!'
          ]));
    });

    test('to different remotes based on a flag', () async {
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--remote',
        'origin',
      ]);

      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['origin', '$testPluginName-v0.0.1'], null)));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Released [$testPluginName] successfully.'),
          ]));
    });

    test('only if tagging and pushing to remotes are both enabled', () async {
      processRunner.mockPublishCompleteCode = 0;

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-tag-release',
      ]);

      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running `pub publish ` in /packages/$testPluginName...'),
            contains('Package published!'),
            contains('Released [$testPluginName] successfully.'),
          ]));
    });
  });

  group('Auto release (all-changed flag)', () {
    test('can release newly created plugins', () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>[],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>[],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1', packagesDir);
      // federated
      final Directory pluginDir2 = createFakePlugin(
        'plugin2',
        packagesDir.childDirectory('plugin2'),
      );
      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.1'], null)));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin2-v0.0.1'], null)));
    });

    test('can release newly created plugins, while there are existing plugins',
        () async {
      const Map<String, dynamic> httpResponsePlugin0 = <String, dynamic>{
        'name': 'plugin0',
        'versions': <String>['0.0.1'],
      };

      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>[],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>[],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin0.json') {
          return http.Response(json.encode(httpResponsePlugin0), 200);
        } else if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // The existing plugin.
      createFakePlugin('plugin0', packagesDir);
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1', packagesDir);
      // federated
      final Directory pluginDir2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      // Git results for plugin0 having been released already, and plugin1 and
      // plugin2 being new.
      gitProcessRunner.mockProcessesForExecutable['git-tag'] = <io.Process>[
        MockProcess(stdout: 'plugin0-v0.0.1\n')
      ];
      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.1'], null)));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin2-v0.0.1'], null)));
    });

    test('can release newly created plugins, dry run', () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>[],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>[],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1', packagesDir);
      // federated
      final Directory pluginDir2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];
      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(
          commandRunner, <String>[
        'publish-plugin',
        '--all-changed',
        '--base-sha=HEAD~',
        '--dry-run'
      ]);

      expect(
          output,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            '===============  DRY RUN ===============',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Tagging release plugin1-v0.0.1...',
            'Pushing tag to upstream...',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Tagging release plugin2-v0.0.1...',
            'Pushing tag to upstream...',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test('version change triggers releases.', () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.1'],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.1'],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      final Directory pluginDir1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final Directory pluginDir2 = createFakePlugin(
          'plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');

      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';

      final List<String> output2 = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          output2,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.2'], null)));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin2-v0.0.2'], null)));
    });

    test(
        'delete package will not trigger publish but exit the command successfully.',
        () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.1'],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.1'],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      final Directory pluginDir1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final Directory pluginDir2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));
      pluginDir2.deleteSync(recursive: true);

      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';

      final List<String> output2 = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          output2,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'The file at The pubspec file at ${pluginDir2.childFile('pubspec.yaml').path} does not exist. Publishing will not happen for plugin2.\nSafe to ignore if the package is deleted in this commit.\n',
            'Packages released: plugin1',
            'Done!'
          ]));
      expect(
          gitProcessRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.2'], null)));
    });

    test('Existing versions do not trigger release, also prints out message.',
        () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.2'],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.2'],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      final Directory pluginDir1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final Directory pluginDir2 = createFakePlugin(
          'plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');

      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];
      gitProcessRunner.mockProcessesForExecutable['git-tag'] = <io.Process>[
        MockProcess(
            stdout: 'plugin1-v0.0.2\n'
                'plugin2-v0.0.2\n')
      ];

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'The version 0.0.2 of plugin1 has already been published',
            'skip.',
            'The version 0.0.2 of plugin2 has already been published',
            'skip.',
            'Done!'
          ]));

      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test(
        'Existing versions do not trigger release, but fail if the tags do not exist.',
        () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.2'],
      };

      const Map<String, dynamic> httpResponsePlugin2 = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.2'],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'plugin1.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        } else if (request.url.pathSegments.last == 'plugin2.json') {
          return http.Response(json.encode(httpResponsePlugin2), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      final Directory pluginDir1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final Directory pluginDir2 = createFakePlugin(
          'plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');

      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('pubspec.yaml').path}\n'
                '${pluginDir2.childFile('pubspec.yaml').path}\n')
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The version 0.0.2 of plugin1 has already been published'),
            contains(
                'However, the git release tag for this version (plugin1-v0.0.2) is not found.'),
            contains('The version 0.0.2 of plugin2 has already been published'),
            contains(
                'However, the git release tag for this version (plugin2-v0.0.2) is not found.'),
          ]));
      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test('No version change does not release any plugins', () async {
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1', packagesDir);
      // federated
      final Directory pluginDir2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(
            stdout: '${pluginDir1.childFile('plugin1.dart').path}\n'
                '${pluginDir2.childFile('plugin2.dart').path}\n')
      ];

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'No version updates in this commit.',
            'Done!'
          ]));
      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test('Do not release flutter_plugin_tools', () async {
      const Map<String, dynamic> httpResponsePlugin1 = <String, dynamic>{
        'name': 'flutter_plugin_tools',
        'versions': <String>[],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'flutter_plugin_tools.json') {
          return http.Response(json.encode(httpResponsePlugin1), 200);
        }
        return http.Response('', 500);
      });
      final PublishPluginCommand command = PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      final Directory flutterPluginTools =
          createFakePlugin('flutter_plugin_tools', packagesDir);
      gitProcessRunner.mockProcessesForExecutable['git-diff'] = <io.Process>[
        MockProcess(stdout: flutterPluginTools.childFile('pubspec.yaml').path)
      ];

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Done!'
          ]));
      expect(
          output.contains(
            'Running `pub publish ` in ${flutterPluginTools.path}...\n',
          ),
          isFalse);
      expect(
          gitProcessRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });
  });
}

class TestProcessRunner extends ProcessRunner {
  // Most recent returned publish process.
  late MockProcess mockPublishProcess;
  final List<String> mockPublishArgs = <String>[];

  String? mockPublishStdout;
  String? mockPublishStderr;
  int mockPublishCompleteCode = 0;

  @override
  Future<io.ProcessResult> run(
    String executable,
    List<String> args, {
    Directory? workingDir,
    bool exitOnError = false,
    bool logOnError = false,
    Encoding stdoutEncoding = io.systemEncoding,
    Encoding stderrEncoding = io.systemEncoding,
  }) async {
    final io.ProcessResult result = io.Process.runSync(executable, args,
        workingDirectory: workingDir?.path);
    if (result.exitCode != 0) {
      throw ToolExit(result.exitCode);
    }
    return result;
  }

  @override
  Future<io.Process> start(String executable, List<String> args,
      {Directory? workingDirectory}) async {
    /// Never actually publish anything. Start is always and only used for this
    /// since it returns something we can route stdin through.
    assert(executable == getFlutterCommand(const LocalPlatform()) &&
        args.isNotEmpty &&
        args[0] == 'pub' &&
        args[1] == 'publish');
    mockPublishArgs.addAll(args);

    mockPublishProcess = MockProcess(
      exitCode: mockPublishCompleteCode,
      stdout: mockPublishStdout,
      stderr: mockPublishStderr,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    return mockPublishProcess;
  }
}

class MockStdin extends Mock implements io.Stdin {
  List<List<int>> mockUserInputs = <List<int>>[];
  late StreamController<List<int>> _controller;
  String? readLineOutput;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    // In the test context, only one `PublishPluginCommand` object is created for a single test case.
    // However, sometimes, we need to run multiple commands in a single test case.
    // In such situation, this `MockStdin`'s StreamController might be listened to more than once, which is not allowed.
    //
    // Create a new controller every time so this Stdin could be listened to multiple times.
    _controller = StreamController<List<int>>();
    mockUserInputs.forEach(_addUserInputsToSteam);
    return _controller.stream.transform(streamTransformer);
  }

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  String? readLineSync(
          {Encoding encoding = io.systemEncoding,
          bool retainNewlines = false}) =>
      readLineOutput;

  void _addUserInputsToSteam(List<int> input) => _controller.add(input);
}

class MockProcessResult extends Mock implements io.ProcessResult {
  MockProcessResult({int exitCode = 0}) : _exitCode = exitCode;

  final int _exitCode;

  @override
  int get exitCode => _exitCode;
}
