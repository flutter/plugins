// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_tools/src/publish_plugin_command.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:git/git.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  const String testPluginName = 'foo';
  final List<String> printedMessages = <String>[];

  Directory parentDir;
  Directory pluginDir;
  GitDir gitDir;
  TestProcessRunner processRunner;
  CommandRunner<void> commandRunner;
  MockStdin mockStdin;

  setUp(() async {
    // This test uses a local file system instead of an in memory one throughout
    // so that git actually works. In setup we initialize a mono repo of plugins
    // with one package and commit everything to Git.
    parentDir = const LocalFileSystem()
        .systemTempDirectory
        .createTempSync('publish_plugin_command_test-');
    initializeFakePackages(parentDir: parentDir);
    pluginDir = createFakePlugin(testPluginName, withSingleExample: false);
    assert(pluginDir != null && pluginDir.existsSync());
    createFakePubspec(pluginDir, includeVersion: true);
    io.Process.runSync('git', <String>['init'],
        workingDirectory: mockPackagesDir.path);
    gitDir = await GitDir.fromExisting(mockPackagesDir.path);
    await gitDir.runCommand(<String>['add', '-A']);
    await gitDir.runCommand(<String>['commit', '-m', 'Initial commit']);
    processRunner = TestProcessRunner();
    mockStdin = MockStdin();
    commandRunner = CommandRunner<void>('tester', '')
      ..addCommand(PublishPluginCommand(
          mockPackagesDir, mockPackagesDir.fileSystem,
          processRunner: processRunner,
          print: (Object message) => printedMessages.add(message.toString()),
          stdinput: mockStdin,
          gitDir: await GitDir.fromExisting(mockPackagesDir.path)));
  });

  tearDown(() {
    parentDir.deleteSync(recursive: true);
    printedMessages.clear();
  });

  group('Initial validation', () {
    test('requires a package flag', () async {
      await expectLater(() => commandRunner.run(<String>['publish-plugin']),
          throwsA(const TypeMatcher<ToolExit>()));
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
          throwsA(const TypeMatcher<ToolExit>()));

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
          throwsA(const TypeMatcher<ToolExit>()));

      expect(
          printedMessages.last,
          contains(
              "There are files in the package directory that haven't been saved in git."));
    });

    test('fails immediately if the remote doesn\'t exist', () async {
      await expectLater(
          () => commandRunner
              .run(<String>['publish-plugin', '--package', testPluginName]),
          throwsA(const TypeMatcher<ToolExit>()));
      expect(processRunner.results.last.stderr, contains('No such remote'));
    });

    test("doesn't validate the remote if it's not pushing tags", () async {
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);

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
      createFakePubspec(pluginDir, includeVersion: true, isFlutter: false);
      io.Process.runSync('git', <String>['init'],
          workingDirectory: mockPackagesDir.path);
      gitDir = await GitDir.fromExisting(mockPackagesDir.path);
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Initial commit']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
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
      processRunner.mockPublishProcess.stdoutController.add(utf8.encode('Foo'));
      processRunner.mockPublishProcess.stderrController.add(utf8.encode('Bar'));
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);

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
      mockStdin.controller.add(utf8.encode('user input'));
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);

      await publishCommand;

      expect(processRunner.mockPublishProcess.stdinMock.lines,
          contains('user input'));
    });

    test('forwards --pub-publish-flags to pub publish', () async {
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
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

    test('throws if pub publish fails', () async {
      processRunner.mockPublishProcess.exitCodeCompleter.complete(128);
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
                '--no-push-tags',
                '--no-tag-release',
              ]),
          throwsA(const TypeMatcher<ToolExit>()));

      expect(printedMessages, contains('Publish failed. Exiting.'));
    });

    test('publish, dry run', () async {
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(1);
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
            'DRY RUN: Running `pub publish ` in ${pluginDir.path}...\n',
            'Done!'
          ]));
    });
  });

  group('Tags release', () {
    test('with the version and name from the pubspec.yaml', () async {
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
        '--no-push-tags',
      ]);

      final String tag =
          (await gitDir.runCommand(<String>['show-ref', 'fake_package-v0.0.1']))
              .stdout as String;
      expect(tag, isNotEmpty);
    });

    test('only if publishing succeeded', () async {
      processRunner.mockPublishProcess.exitCodeCompleter.complete(128);
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
                '--no-push-tags',
              ]),
          throwsA(const TypeMatcher<ToolExit>()));

      expect(printedMessages, contains('Publish failed. Exiting.'));
      final String tag = (await gitDir.runCommand(
              <String>['show-ref', 'fake_package-v0.0.1'],
              throwOnError: false))
          .stdout as String;
      expect(tag, isEmpty);
    });
  });

  group('Pushes tags', () {
    setUp(() async {
      await gitDir.runCommand(
          <String>['remote', 'add', 'upstream', 'http://localhost:8000']);
    });

    test('requires user confirmation', () async {
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      mockStdin.readLineOutput = 'help';
      await expectLater(
          () => commandRunner.run(<String>[
                'publish-plugin',
                '--package',
                testPluginName,
              ]),
          throwsA(const TypeMatcher<ToolExit>()));

      expect(printedMessages, contains('Tag push canceled.'));
    });

    test('to upstream by default', () async {
      await gitDir.runCommand(<String>['tag', 'garbage']);
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(<String>[
        'publish-plugin',
        '--package',
        testPluginName,
      ]);

      expect(processRunner.pushTagsArgs.isNotEmpty, isTrue);
      expect(processRunner.pushTagsArgs[1], 'upstream');
      expect(processRunner.pushTagsArgs[2], 'fake_package-v0.0.1');
      expect(printedMessages.last, 'Done!');
    });

    test('to upstream by default, dry run', () async {
      await gitDir.runCommand(<String>['tag', 'garbage']);
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(1);
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(
          <String>['publish-plugin', '--package', testPluginName, '--dry-run']);

      expect(processRunner.pushTagsArgs, isEmpty);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'DRY RUN: Running `pub publish ` in ${pluginDir.path}...\n',
            'DRY RUN: Tagging release fake_package-v0.0.1...',
            'DRY RUN: Pushing tag to upstream...',
            'Done!'
          ]));
    });

    test('to different remotes based on a flag', () async {
      await gitDir.runCommand(
          <String>['remote', 'add', 'origin', 'http://localhost:8001']);
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
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
      expect(processRunner.pushTagsArgs[2], 'fake_package-v0.0.1');
      expect(printedMessages.last, 'Done!');
    });

    test('only if tagging and pushing to remotes are both enabled', () async {
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
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

  group('Auto release (all flag)', () {
    setUp(() async {
      io.Process.runSync('git', <String>['init'],
          workingDirectory: mockPackagesDir.path);
      gitDir = await GitDir.fromExisting(mockPackagesDir.path);
      await gitDir.runCommand(
          <String>['remote', 'add', 'upstream', 'http://localhost:8000']);
    });

    test('can release newly created plugins', () async {
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1',
          withSingleExample: true, packagesDirectory: mockPackagesDir);
      // federated
      final Directory pluginDir2 = createFakePlugin('plugin2',
          withSingleExample: true,
          parentDirectoryName: 'plugin2',
          packagesDirectory: mockPackagesDir);
      createFakePubspec(pluginDir1,
          name: 'plugin1',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      createFakePubspec(pluginDir2,
          name: 'plugin2',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Getting existing tags...',
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
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1',
          withSingleExample: true, packagesDirectory: mockPackagesDir);
      // federated
      final Directory pluginDir2 = createFakePlugin('plugin2',
          withSingleExample: true,
          parentDirectoryName: 'plugin2',
          packagesDirectory: mockPackagesDir);
      createFakePubspec(pluginDir1,
          name: 'plugin1',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      createFakePubspec(pluginDir2,
          name: 'plugin2',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 1 when running `pub publish`. If dry-run does not work, test should throw.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(1);
      mockStdin.readLineOutput = 'y';
      await commandRunner.run(
          <String>['publish-plugin', '--all', '--base-sha=HEAD~', '--dry-run']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Getting existing tags...',
            'DRY RUN: Running `pub publish ` in ${pluginDir1.path}...\n',
            'DRY RUN: Tagging release plugin1-v0.0.1...',
            'DRY RUN: Pushing tag to upstream...',
            'DRY RUN: Running `pub publish ` in ${pluginDir2.path}...\n',
            'DRY RUN: Tagging release plugin2-v0.0.1...',
            'DRY RUN: Pushing tag to upstream...',
            'Packages released: plugin1, plugin2',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isEmpty);
    });

    test('version change triggers releases.', () async {
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1',
          withSingleExample: true, packagesDirectory: mockPackagesDir);
      // federated
      final Directory pluginDir2 = createFakePlugin('plugin2',
          withSingleExample: true,
          parentDirectoryName: 'plugin2',
          packagesDirectory: mockPackagesDir);
      createFakePubspec(pluginDir1,
          name: 'plugin1',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      createFakePubspec(pluginDir2,
          name: 'plugin2',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Getting existing tags...',
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
          (element) => element.contains('version:'))] = 'version: 0.0.2';
      pluginDir1
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin1Pubspec.join('\n'));
      final List<String> plugin2Pubspec =
          pluginDir2.childFile('pubspec.yaml').readAsLinesSync();
      plugin2Pubspec[plugin2Pubspec.indexWhere(
          (element) => element.contains('version:'))] = 'version: 0.0.2';
      pluginDir2
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin2Pubspec.join('\n'));
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir
          .runCommand(<String>['commit', '-m', 'Update versions to 0.0.2']);

      await commandRunner
          .run(<String>['publish-plugin', '--all', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Getting existing tags...',
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
        'versions revert do not trigger releases. Also prints out warning message.',
        () async {
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1',
          withSingleExample: true, packagesDirectory: mockPackagesDir);
      // federated
      final Directory pluginDir2 = createFakePlugin('plugin2',
          withSingleExample: true,
          parentDirectoryName: 'plugin2',
          packagesDirectory: mockPackagesDir);
      createFakePubspec(pluginDir1,
          name: 'plugin1',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.2');
      createFakePubspec(pluginDir2,
          name: 'plugin2',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.2');
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);
      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Getting existing tags...',
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

      processRunner.pushTagsArgs.clear();
      printedMessages.clear();

      final List<String> plugin1Pubspec =
          pluginDir1.childFile('pubspec.yaml').readAsLinesSync();
      plugin1Pubspec[plugin1Pubspec.indexWhere(
          (element) => element.contains('version:'))] = 'version: 0.0.1';
      pluginDir1
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin1Pubspec.join('\n'));
      final List<String> plugin2Pubspec =
          pluginDir2.childFile('pubspec.yaml').readAsLinesSync();
      plugin2Pubspec[plugin2Pubspec.indexWhere(
          (element) => element.contains('version:'))] = 'version: 0.0.1';
      pluginDir2
          .childFile('pubspec.yaml')
          .writeAsStringSync(plugin2Pubspec.join('\n'));
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir
          .runCommand(<String>['commit', '-m', 'Update versions to 0.0.1']);

      await commandRunner
          .run(<String>['publish-plugin', '--all', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'Getting existing tags...',
            'The new version (0.0.1) is lower than the current version (0.0.2) for plugin1.\nThis git commit is a revert, no release is tagged.',
            'The new version (0.0.1) is lower than the current version (0.0.2) for plugin2.\nThis git commit is a revert, no release is tagged.',
            'Done!'
          ]));

      expect(processRunner.pushTagsArgs, isEmpty);
    });

    test('No version change does not release any plugins', () async {
      // Non-federated
      final Directory pluginDir1 = createFakePlugin('plugin1',
          withSingleExample: true, packagesDirectory: mockPackagesDir);
      // federated
      final Directory pluginDir2 = createFakePlugin('plugin2',
          withSingleExample: true,
          parentDirectoryName: 'plugin2',
          packagesDirectory: mockPackagesDir);
      createFakePubspec(pluginDir1,
          name: 'plugin1',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');
      createFakePubspec(pluginDir2,
          name: 'plugin2',
          includeVersion: true,
          isFlutter: false,
          version: '0.0.1');

      io.Process.runSync('git', <String>['init'],
          workingDirectory: mockPackagesDir.path);
      gitDir = await GitDir.fromExisting(mockPackagesDir.path);
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add plugins']);

      pluginDir1.childFile('plugin1.dart').createSync();
      pluginDir2.childFile('plugin2.dart').createSync();
      await gitDir.runCommand(<String>['add', '-A']);
      await gitDir.runCommand(<String>['commit', '-m', 'Add dart files']);

      // Immediately return 0 when running `pub publish`.
      processRunner.mockPublishProcess.exitCodeCompleter.complete(0);
      mockStdin.readLineOutput = 'y';
      await commandRunner
          .run(<String>['publish-plugin', '--all', '--base-sha=HEAD~']);
      expect(
          printedMessages,
          containsAllInOrder(<String>[
            'Checking local repo...',
            'Local repo is ready!',
            'No version updates in this commit, exiting...',
            'Done!'
          ]));
      expect(processRunner.pushTagsArgs, isEmpty);
    });
  });
}

class TestProcessRunner extends ProcessRunner {
  final List<io.ProcessResult> results = <io.ProcessResult>[];
  final MockProcess mockPublishProcess = MockProcess();
  final List<String> mockPublishArgs = <String>[];
  final MockProcessResult mockPushTagsResult = MockProcessResult();
  final List<String> pushTagsArgs = <String>[];

  @override
  Future<io.ProcessResult> runAndExitOnError(
    String executable,
    List<String> args, {
    Directory workingDir,
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
      {Directory workingDirectory}) async {
    /// Never actually publish anything. Start is always and only used for this
    /// since it returns something we can route stdin through.
    assert(executable == 'flutter' &&
        args.isNotEmpty &&
        args[0] == 'pub' &&
        args[1] == 'publish');
    mockPublishArgs.addAll(args);
    return mockPublishProcess;
  }
}

class MockStdin extends Mock implements io.Stdin {
  final StreamController<List<int>> controller = StreamController<List<int>>();
  String readLineOutput;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return controller.stream.transform(streamTransformer);
  }

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  String readLineSync(
          {Encoding encoding = io.systemEncoding,
          bool retainNewlines = false}) =>
      readLineOutput;
}

class MockProcessResult extends Mock implements io.ProcessResult {}
