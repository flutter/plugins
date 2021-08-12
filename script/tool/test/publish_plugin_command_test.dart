// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/process_runner.dart';
import 'package:flutter_plugin_tools/src/publish_plugin_command.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  const String testPluginName = 'foo';
  late List<String> printedMessages;

  late Directory testRoot;
  late Directory packagesDir;
  late Directory pluginDir;
  late GitDir gitDir;
  late TestProcessRunner processRunner;
  late CommandRunner<void> commandRunner;
  late MockStdin mockStdin;
  // This test uses a local file system instead of an in memory one throughout
  // so that git actually works. In setup we initialize a mono repo of plugins
  // with one package and commit everything to Git.
  const FileSystem fileSystem = LocalFileSystem();

  void _createMockCredentialFile() {
    final String credentialPath = PublishPluginCommand.getCredentialPath();
    fileSystem.file(credentialPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('some credential');
  }

  setUp(() async {
    testRoot = fileSystem.systemTempDirectory
        .createTempSync('publish_plugin_command_test-');
    // The temp directory can have symbolic links, which won't match git output;
    // use a fully resolved version to avoid potential path comparison issues.
    testRoot = fileSystem.directory(testRoot.resolveSymbolicLinksSync());
    packagesDir = createPackagesDirectory(parentDir: testRoot);
    pluginDir =
        createFakePlugin(testPluginName, packagesDir, examples: <String>[]);
    assert(pluginDir != null && pluginDir.existsSync());
    io.Process.runSync('git', <String>['init'],
        workingDirectory: testRoot.path);
    gitDir = await GitDir.fromExisting(testRoot.path);
    await gitDir.runCommand(<String>['add', '-A']);
    await gitDir.runCommand(<String>['commit', '-m', 'Initial commit']);
    processRunner = TestProcessRunner();
    mockStdin = MockStdin();
    printedMessages = <String>[];
    commandRunner = CommandRunner<void>('tester', '')
      ..addCommand(PublishPluginCommand(packagesDir,
          processRunner: processRunner,
          print: (Object? message) => printedMessages.add(message.toString()),
          stdinput: mockStdin,
          gitDir: gitDir));
  });

  tearDown(() {
    testRoot.deleteSync(recursive: true);
  });

  group('Initial validation', () {
    test('requires a package flag', () async {
      await expectLater(() => commandRunner.run(<String>['publish-plugin']),
          throwsA(isA<ToolExit>()));
      expect(
          printedMessages.last, contains('Must specify a package to publish.'));
    });

    test('requires an existing flag', () async {
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                'iamerror',
                '--no-push-tags'
              ]),
          throwsA(isA<ToolExit>()));

      expect(printedMessages.last, contains('iamerror does not exist'));
    });

    test('refuses to proceed with dirty files', () async {
      pluginDir.childFile('tmp').createSync();

      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
                '--no-push-tags'
              ]),
          throwsA(isA<ToolExit>()));

      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'There are files in the package directory that haven\'t been saved in git. Refusing to publish these files:\n\n?? packages/foo/tmp\n\nIf the directory should be clean, you can run `git clean -xdf && git reset --hard HEAD` to wipe all local changes.',
            'Failed, see above for details.',
          ]));
    });

    test('fails immediately if the remote doesn\'t exist', () async {
      await expectLater(
          () => commandRunner
              .run(<String>['publish-plugin', '--package', testPluginName]),
          throwsA(isA<ToolExit>()));
      expect(processRunner.results.last.stderr, contains('No such remote'));
    });

    test("doesn't validate the remote if it's not pushing tags", () async {
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;

      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release'
      ]);

      expect(printedMessages.last, 'Done!');
    });

    test('can publish non-flutter package', () async {
      const String packageName = 'a_package';
      createFakePackage(packageName, packagesDir);
      io.Process.runSync('git', <String>['init'],
          workingDirectory: testRoot.path);
      gitDir = await GitDir.fromExisting(testRoot.path);
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Initial commit']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        packageName,
        '--no-push-tags',
        '--no-tag-release'
      ]);
      expect(printedMessages.last, 'Done!');
    });
  });

  group('Publishes package', () {
    test('while showing all output from pub publish to the user', () async {
      final Future<void> publishCommand = commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release'
      ]);

      processRunner.mockPublishStdout = 'Foo';
      processRunner.mockPublishStderr = 'Bar';
      processRunner.mockPublishCompleteCode = 0;

      await publishCommand;

      expect(printedMessages, contains('Foo'));
      expect(printedMessages, contains('Bar'));
    });

    test('forwards input from the user to `pub publish`', () async {
      final Future<void> publishCommand = commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
        '--no-tag-release'
      ]);
      mockStdin.mockUserInputs.add(utf8.encode('user input'));
      processRunner.mockPublishCompleteCode = 0;

      await publishCommand;

      expect(processRunner.mockPublishProcess.stdinMock.lines,
          contains('user input'));
    });

    test('forwards --pub-publish-flags to pub publish', () async {
      processRunner.mockPublishCompleteCode = 0;
      await commandRunner.run(<String>[
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
      await commandRunner.run(<String>[
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
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
                '--no-push-tags',
                '--no-tag-release',
              ]),
          throwsA(isA<ToolExit>()));

      expect(printedMessages, contains('Publish foo failed.'));
    });

    test('publish, dry run', () async {
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishCompleteCode = 1;
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--dry-run',
        '--no-push-tags',
        '--no-tag-release',
      ]);

      expect(processRunner.pushTagsArgs, isEmpty);
      expect(
          printedMessages,
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
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
      ]);

      final String? tag = (await gitDir
              .runCommand(<String>['show-ref', '$testPluginName-v0.0.1']))
          .stdout as String?;
      expect(tag, isNotEmpty);
    });

    test('only if publishing succeeded', () async {
      processRunner.mockPublishCompleteCode = 128;
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
                '--no-push-tags',
              ]),
          throwsA(isA<ToolExit>()));

      expect(printedMessages, contains('Publish foo failed.'));
      final String? tag = (await gitDir.runCommand(
              <String>['show-ref', '$testPluginName-v0.0.1'],
              throwOnError: false))
          .stdout as String?;
      expect(tag, isEmpty);
    });
  });

  group('Pushes tags', () {
    setUp(() async {
      await gitDir.runCommand(
          <String>['remote', 'add', 'upstream', 'http://localhost:8000']);
    });

    test('requires user confirmation', () async {
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'help';
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
              ]),
          throwsA(isA<ToolExit>()));

      expect(printedMessages, contains('Tag push canceled.'));
    });

    test('to upstream by default', () async {
      await gitDir.runCommand(<String>['tag', 'garbage']);
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
      ]);

      expect(processRunner.pushTagsArgs.isNotEmpty, isTrue);
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], '$testPluginName-v0.0.1');
      expect(printedMessages.last, 'Done!');
    });

    test('does not ask for user input if the --skip-confirmation flag is on',
        () async {
      await gitDir.runCommand(<String>['tag', 'garbage']);
      processRunner.mockPublishCompleteCode = 0;
      _createMockCredentialFile();
      await commandRunner.run(<String>[
        'publish-plugin',
        '--skip-confirmation',
        '--package',
        testPluginName,
      ]);

      expect(processRunner.pushTagsArgs.isNotEmpty, isTrue);
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], '$testPluginName-v0.0.1');
      expect(printedMessages.last, 'Done!');
    });

    test('to upstream by default, dry run', () async {
      await gitDir.runCommand(<String>['tag', 'garbage']);
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishCompleteCode = 1;
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(
          <String>['publish-plugin', '--package', testPluginName, '--dry-run']);

      expect(processRunner.pushTagsArgs, isEmpty);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            '===============  DRY RUN ===============',
            'Running `pub publish ` in ${pluginDir.path}...\n',
            'Tagging release $testPluginName-v0.0.1...',
            'Pushing tag to upstream...',
            'Done!'
          ]));
    });

    test('to different remotes based on a flag', () async {
      await gitDir.runCommand(
          <String>['remote', 'add', 'origin', 'http://localhost:8001']);
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--remote',
        'origin',
      ]);

      expect(processRunner.pushTagsArgs.isNotEmpty, isTrue);
      expect(processRunner.pushTagsArgs[1], 'origin');
      expect(processRunner.pushTagsArgs[2], '$testPluginName-v0.0.1');
      expect(printedMessages.last, 'Done!');
    });

    test('only if tagging and pushing to remotes are both enabled', () async {
      processRunner.mockPublishCompleteCode = 0;
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-tag-release',
      ]);

      expect(processRunner.pushTagsArgs.isEmpty, isTrue);
      expect(printedMessages.last, 'Done!');
    });
  });

  group('Auto release (all-changed flag)', () {
    setUp(() async {
      io.Process.runSync('git', <String>['init'],
          workingDirectory: testRoot.path);
      gitDir = await GitDir.fromExisting(testRoot.path);
      await gitDir.runCommand(
          <String>['remote', 'add', 'upstream', 'http://localhost:8000']);
    });

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
          print: (Object? message) => printedMessages.add(message.toString()),
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
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isNotEmpty);
      expect(processRunner.pushTagsArgs[0], 'push');
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'plugin1-v0.0.1');
      expect(processRunner.pushTagsArgs[3], 'push');
      expect(processRunner.pushTagsArgs[4], 'upstream');
      expect(processRunner.pushTagsArgs[5], 'plugin2-v0.0.1');
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
          print: (Object? message) => printedMessages.add(message.toString()),
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Prepare an exiting plugin and tag it
      createFakePlugin('plugin0', packagesDir);
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      await gitDir.runCommand(<String>['tag', 'plugin0-v0.0.1']);

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      processRunner.pushTagsArgs.clear();

      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1', packagesDir);
      // federated
      final Directory pluginDir2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isNotEmpty);
      expect(processRunner.pushTagsArgs[0], 'push');
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'plugin1-v0.0.1');
      expect(processRunner.pushTagsArgs[3], 'push');
      expect(processRunner.pushTagsArgs[4], 'upstream');
      expect(processRunner.pushTagsArgs[5], 'plugin2-v0.0.1');
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
          print: (Object? message) => printedMessages.add(message.toString()),
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
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishCompleteCode = 1;
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(<String>[
        'publish-plugin',
        '--all-changed',
        '--base-sha=HEAD~',
        '--dry-run'
      ]);
      expect(
          printedMessages,
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
      expect(processRunner.pushTagsArgs, isEmpty);
    });

    test('version change triggers releases.', () async {
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
          print: (Object? message) => printedMessages.add(message.toString()),
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
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isNotEmpty);
      expect(processRunner.pushTagsArgs[0], 'push');
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'plugin1-v0.0.1');
      expect(processRunner.pushTagsArgs[3], 'push');
      expect(processRunner.pushTagsArgs[4], 'upstream');
      expect(processRunner.pushTagsArgs[5], 'plugin2-v0.0.1');

      processRunner.pushTagsArgs.clear();
      printedMessages.clear();

      final List<String> plugin1Pubspec =
          pluginDir1.childFile('pubspec.yaml').readAsLinesSync();
      plugin1Pubspec[plugin1Pubspec.indexWhere(
          (String element) => element.contains('version:'))] = 'version: 0.0.2';
      pluginDir1
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin1Pubspec.join('\n'));
      final List<String> plugin2Pubspec =
          pluginDir2.childFile('pubspec.yaml').readAsLinesSync();
      plugin2Pubspec[plugin2Pubspec.indexWhere(
          (String element) => element.contains('version:'))] = 'version: 0.0.2';
      pluginDir2
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin2Pubspec.join('\n'));
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir
          .runCommand(<String>['commit', '-m', 'Update versions to 0.0.2']);

      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));

      expect(processRunner.pushTagsArgs, isNotEmpty);
      expect(processRunner.pushTagsArgs[0], 'push');
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'plugin1-v0.0.2');
      expect(processRunner.pushTagsArgs[3], 'push');
      expect(processRunner.pushTagsArgs[4], 'upstream');
      expect(processRunner.pushTagsArgs[5], 'plugin2-v0.0.2');
    });

    test(
        'delete package will not trigger publish but exit the command successfully.',
        () async {
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
          print: (Object? message) => printedMessages.add(message.toString()),
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
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'Running `pub publish ` in ${pluginDir2.path}...\n',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isNotEmpty);
      expect(processRunner.pushTagsArgs[0], 'push');
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'plugin1-v0.0.1');
      expect(processRunner.pushTagsArgs[3], 'push');
      expect(processRunner.pushTagsArgs[4], 'upstream');
      expect(processRunner.pushTagsArgs[5], 'plugin2-v0.0.1');

      processRunner.pushTagsArgs.clear();
      printedMessages.clear();

      final List<String> plugin1Pubspec =
          pluginDir1.childFile('pubspec.yaml').readAsLinesSync();
      plugin1Pubspec[plugin1Pubspec.indexWhere(
          (String element) => element.contains('version:'))] = 'version: 0.0.2';
      pluginDir1
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin1Pubspec.join('\n'));

      pluginDir2.deleteSync(recursive: true);

      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>[
        'commit',
        '-m',
        'Update plugin1 versions to 0.0.2, delete plugin2'
      ]);

      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Running `pub publish ` in ${pluginDir1.path}...\n',
            'The file at The pubspec file at ${pluginDir2.childFile('pubspec.yaml').path} does not exist. Publishing will not happen for plugin2.\nSafe to ignore if the package is deleted in this commit.\n',
            'Packages released: plugin1',
            'Done!'
          ]));

      expect(processRunner.pushTagsArgs, isNotEmpty);
      expect(processRunner.pushTagsArgs.length, 3);
      expect(processRunner.pushTagsArgs[0], 'push');
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'plugin1-v0.0.2');
    });

    test('Exiting versions do not trigger release, also prints out message.',
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
          print: (Object? message) => printedMessages.add(message.toString()),
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      await gitDir.runCommand(<String>['tag', 'plugin1-v0.0.2']);
      await gitDir.runCommand(<String>['tag', 'plugin2-v0.0.2']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'The version 0.0.2 of plugin1 has already been published',
            'skip.',
            'The version 0.0.2 of plugin2 has already been published',
            'skip.',
            'Done!'
          ]));

      expect(processRunner.pushTagsArgs, isEmpty);
    });

    test(
        'Exiting versions do not trigger release, but fail if the tags do not exist.',
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
          print: (Object? message) => printedMessages.add(message.toString()),
          stdinput: mockStdin,
          httpClient: mockClient,
          gitDir: gitDir);

      commandRunner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      commandRunner.addCommand(command);

      // Non-federated
      createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await expectLater(
          () => commandRunner.run(
              <String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']),
          throwsA(isA<ToolExit>()));
      expect(processRunner.pushTagsArgs, isEmpty);
    });

    test('No version change does not release any plugins', () async {
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1', packagesDir);
      // federated
      final Directory pluginDir2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      io.Process.runSync('git', <String>['init'],
          workingDirectory: testRoot.path);
      gitDir = await GitDir.fromExisting(testRoot.path);
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);

      pluginDir1.childFile('plugin1.dart').createSync();
      pluginDir2.childFile('plugin2.dart').createSync();
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add dart files']);

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'No version updates in this commit.',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isEmpty);
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
          print: (Object? message) => printedMessages.add(message.toString()),
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
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishCompleteCode = 0;
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all-changed', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Done!'
          ]));
      expect(
          printedMessages.contains(
            'Running `pub publish ` in ${flutterPluginTools.path}...\n',
          ),
          isFalse);
      expect(processRunner.pushTagsArgs, isEmpty);
      processRunner.pushTagsArgs.clear();
      printedMessages.clear();
    });
  });
}

class TestProcessRunner extends ProcessRunner {
  final List<io.ProcessResult> results = <io.ProcessResult>[];
  // Most recent returned publish process.
  late MockProcess mockPublishProcess;
  final List<String> mockPublishArgs = <String>[];
  final MockProcessResult mockPushTagsResult = MockProcessResult();
  final List<String> pushTagsArgs = <String>[];

  String? mockPublishStdout;
  String? mockPublishStderr;
  int? mockPublishCompleteCode;

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
    // Don't ever really push tags.
    if (executable == 'git' && args.isNotEmpty && args[0] == 'push') {
      pushTagsArgs.addAll(args);
      return mockPushTagsResult;
    }

    final io.ProcessResult result = io.Process.runSync(executable, args,
        workingDirectory: workingDir?.path);
    results.add(result);
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
    mockPublishProcess = MockProcess();
    if (mockPublishStdout != null) {
      mockPublishProcess.stdoutController.add(utf8.encode(mockPublishStdout!));
    }
    if (mockPublishStderr != null) {
      mockPublishProcess.stderrController.add(utf8.encode(mockPublishStderr!));
    }
    if (mockPublishCompleteCode != null) {
      mockPublishProcess.exitCodeCompleter.complete(mockPublishCompleteCode);
    }

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
