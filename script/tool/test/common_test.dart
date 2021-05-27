// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'common_test.mocks.dart';
import 'util.dart';

@GenerateMocks(<Type>[GitDir])
void main() {
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;
  late FileSystem fileSystem;
  late Directory packagesDir;
  late Directory thirdPartyPackagesDir;
  late List<String> plugins;
  late List<List<String>?> gitDirCommands;
  late String gitDiffResponse;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = fileSystem.currentDirectory.childDirectory('packages');
    thirdPartyPackagesDir = packagesDir.parent
        .childDirectory('third_party')
        .childDirectory('packages');

    gitDirCommands = <List<String>?>[];
    gitDiffResponse = '';
    final MockGitDir gitDir = MockGitDir();
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      gitDirCommands.add(invocation.positionalArguments[0] as List<String>?);
      final MockProcessResult mockProcessResult = MockProcessResult();
      if (invocation.positionalArguments[0][0] == 'diff') {
        when<String?>(mockProcessResult.stdout as String?)
            .thenReturn(gitDiffResponse);
      }
      return Future<ProcessResult>.value(mockProcessResult);
    });
    initializeFakePackages(parentDir: packagesDir.parent);
    processRunner = RecordingProcessRunner();
    plugins = <String>[];
    final SamplePluginCommand samplePluginCommand = SamplePluginCommand(
      plugins,
      packagesDir,
      fileSystem,
      processRunner: processRunner,
      gitDir: gitDir,
    );
    runner =
        CommandRunner<void>('common_command', 'Test for common functionality');
    runner.addCommand(samplePluginCommand);
  });

  test('all plugins from file system', () async {
    final Directory plugin1 =
        createFakePlugin('plugin1', packagesDirectory: packagesDir);
    final Directory plugin2 =
        createFakePlugin('plugin2', packagesDirectory: packagesDir);
    await runner.run(<String>['sample']);
    expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
  });

  test('all plugins includes third_party/packages', () async {
    final Directory plugin1 =
        createFakePlugin('plugin1', packagesDirectory: packagesDir);
    final Directory plugin2 =
        createFakePlugin('plugin2', packagesDirectory: packagesDir);
    final Directory plugin3 =
        createFakePlugin('plugin3', packagesDirectory: thirdPartyPackagesDir);
    await runner.run(<String>['sample']);
    expect(plugins,
        unorderedEquals(<String>[plugin1.path, plugin2.path, plugin3.path]));
  });

  test('exclude plugins when plugins flag is specified', () async {
    createFakePlugin('plugin1', packagesDirectory: packagesDir);
    final Directory plugin2 =
        createFakePlugin('plugin2', packagesDirectory: packagesDir);
    await runner.run(
        <String>['sample', '--plugins=plugin1,plugin2', '--exclude=plugin1']);
    expect(plugins, unorderedEquals(<String>[plugin2.path]));
  });

  test('exclude plugins when plugins flag isn\'t specified', () async {
    createFakePlugin('plugin1', packagesDirectory: packagesDir);
    createFakePlugin('plugin2', packagesDirectory: packagesDir);
    await runner.run(<String>['sample', '--exclude=plugin1,plugin2']);
    expect(plugins, unorderedEquals(<String>[]));
  });

  test('exclude federated plugins when plugins flag is specified', () async {
    createFakePlugin('plugin1',
        parentDirectoryName: 'federated', packagesDirectory: packagesDir);
    final Directory plugin2 =
        createFakePlugin('plugin2', packagesDirectory: packagesDir);
    await runner.run(<String>[
      'sample',
      '--plugins=federated/plugin1,plugin2',
      '--exclude=federated/plugin1'
    ]);
    expect(plugins, unorderedEquals(<String>[plugin2.path]));
  });

  test('exclude entire federated plugins when plugins flag is specified',
      () async {
    createFakePlugin('plugin1',
        parentDirectoryName: 'federated', packagesDirectory: packagesDir);
    final Directory plugin2 =
        createFakePlugin('plugin2', packagesDirectory: packagesDir);
    await runner.run(<String>[
      'sample',
      '--plugins=federated/plugin1,plugin2',
      '--exclude=federated'
    ]);
    expect(plugins, unorderedEquals(<String>[plugin2.path]));
  });

  group('test run-on-changed-packages', () {
    test('all plugins should be tested if there are no changes.', () async {
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if there are no plugin related changes.',
        () async {
      gitDiffResponse = 'AUTHORS';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if .cirrus.yml changes.',
        () async {
      gitDiffResponse = '''
.cirrus.yml
packages/plugin1/CHANGELOG
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if .ci.yaml changes',
        () async {
      gitDiffResponse = '''
.ci.yaml
packages/plugin1/CHANGELOG
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if anything in .ci/ changes',
        () async {
      gitDiffResponse = '''
.ci/Dockerfile
packages/plugin1/CHANGELOG
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if anything in script changes.',
        () async {
      gitDiffResponse = '''
script/tool_runner.sh
packages/plugin1/CHANGELOG
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if the root analysis options change.',
        () async {
      gitDiffResponse = '''
analysis_options.yaml
packages/plugin1/CHANGELOG
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('all plugins should be tested if formatting options change.',
        () async {
      gitDiffResponse = '''
.clang-format
packages/plugin1/CHANGELOG
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('Only changed plugin should be tested.', () async {
      gitDiffResponse = 'packages/plugin1/plugin1.dart';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path]));
    });

    test('multiple files in one plugin should also test the plugin', () async {
      gitDiffResponse = '''
packages/plugin1/plugin1.dart
packages/plugin1/ios/plugin1.m
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      createFakePlugin('plugin2', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path]));
    });

    test('multiple plugins changed should test all the changed plugins',
        () async {
      gitDiffResponse = '''
packages/plugin1/plugin1.dart
packages/plugin2/ios/plugin2.m
''';
      final Directory plugin1 =
          createFakePlugin('plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      createFakePlugin('plugin3', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test(
        'multiple plugins inside the same plugin group changed should output the plugin group name',
        () async {
      gitDiffResponse = '''
packages/plugin1/plugin1/plugin1.dart
packages/plugin1/plugin1_platform_interface/plugin1_platform_interface.dart
packages/plugin1/plugin1_web/plugin1_web.dart
''';
      final Directory plugin1 = createFakePlugin('plugin1',
          parentDirectoryName: 'plugin1', packagesDirectory: packagesDir);
      createFakePlugin('plugin2', packagesDirectory: packagesDir);
      createFakePlugin('plugin3', packagesDirectory: packagesDir);
      await runner.run(
          <String>['sample', '--base-sha=master', '--run-on-changed-packages']);

      expect(plugins, unorderedEquals(<String>[plugin1.path]));
    });

    test('--plugins flag overrides the behavior of --run-on-changed-packages',
        () async {
      gitDiffResponse = '''
packages/plugin1/plugin1.dart
packages/plugin2/ios/plugin2.m
packages/plugin3/plugin3.dart
''';
      final Directory plugin1 = createFakePlugin('plugin1',
          parentDirectoryName: 'plugin1', packagesDirectory: packagesDir);
      final Directory plugin2 =
          createFakePlugin('plugin2', packagesDirectory: packagesDir);
      createFakePlugin('plugin3', packagesDirectory: packagesDir);
      await runner.run(<String>[
        'sample',
        '--plugins=plugin1,plugin2',
        '--base-sha=master',
        '--run-on-changed-packages'
      ]);

      expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
    });

    test('--exclude flag works with --run-on-changed-packages', () async {
      gitDiffResponse = '''
packages/plugin1/plugin1.dart
packages/plugin2/ios/plugin2.m
packages/plugin3/plugin3.dart
''';
      final Directory plugin1 = createFakePlugin('plugin1',
          parentDirectoryName: 'plugin1', packagesDirectory: packagesDir);
      createFakePlugin('plugin2', packagesDirectory: packagesDir);
      createFakePlugin('plugin3', packagesDirectory: packagesDir);
      await runner.run(<String>[
        'sample',
        '--exclude=plugin2,plugin3',
        '--base-sha=master',
        '--run-on-changed-packages'
      ]);

      expect(plugins, unorderedEquals(<String>[plugin1.path]));
    });
  });

  group('$GitVersionFinder', () {
    late List<List<String>?> gitDirCommands;
    late String gitDiffResponse;
    String? mergeBaseResponse;
    late MockGitDir gitDir;

    setUp(() {
      gitDirCommands = <List<String>?>[];
      gitDiffResponse = '';
      gitDir = MockGitDir();
      when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
          .thenAnswer((Invocation invocation) {
        gitDirCommands.add(invocation.positionalArguments[0] as List<String>?);
        final MockProcessResult mockProcessResult = MockProcessResult();
        if (invocation.positionalArguments[0][0] == 'diff') {
          when<String?>(mockProcessResult.stdout as String?)
              .thenReturn(gitDiffResponse);
        } else if (invocation.positionalArguments[0][0] == 'merge-base') {
          when<String?>(mockProcessResult.stdout as String?)
              .thenReturn(mergeBaseResponse);
        }
        return Future<ProcessResult>.value(mockProcessResult);
      });
      initializeFakePackages();
      processRunner = RecordingProcessRunner();
    });

    tearDown(() {
      cleanupPackages();
    });

    test('No git diff should result no files changed', () async {
      final GitVersionFinder finder = GitVersionFinder(gitDir, 'some base sha');
      final List<String> changedFiles = await finder.getChangedFiles();

      expect(changedFiles, isEmpty);
    });

    test('get correct files changed based on git diff', () async {
      gitDiffResponse = '''
file1/file1.cc
file2/file2.cc
''';
      final GitVersionFinder finder = GitVersionFinder(gitDir, 'some base sha');
      final List<String> changedFiles = await finder.getChangedFiles();

      expect(
          changedFiles, equals(<String>['file1/file1.cc', 'file2/file2.cc']));
    });

    test('get correct pubspec change based on git diff', () async {
      gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';
      final GitVersionFinder finder = GitVersionFinder(gitDir, 'some base sha');
      final List<String> changedFiles = await finder.getChangedPubSpecs();

      expect(changedFiles, equals(<String>['file1/pubspec.yaml']));
    });

    test('use correct base sha if not specified', () async {
      mergeBaseResponse = 'shaqwiueroaaidf12312jnadf123nd';
      gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';

      final GitVersionFinder finder = GitVersionFinder(gitDir, null);
      await finder.getChangedFiles();
      verify(gitDir.runCommand(
          <String>['diff', '--name-only', mergeBaseResponse!, 'HEAD']));
    });

    test('use correct base sha if specified', () async {
      const String customBaseSha = 'aklsjdcaskf12312';
      gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';
      final GitVersionFinder finder = GitVersionFinder(gitDir, customBaseSha);
      await finder.getChangedFiles();
      verify(gitDir
          .runCommand(<String>['diff', '--name-only', customBaseSha, 'HEAD']));
    });
  });

  group('$PubVersionFinder', () {
    test('Package does not exist.', () async {
      final MockClient mockClient = MockClient((http.Request request) async {
        return http.Response('', 404);
      });
      final PubVersionFinder finder = PubVersionFinder(httpClient: mockClient);
      final PubVersionFinderResponse response =
          await finder.getPackageVersion(package: 'some_package');

      expect(response.versions, isNull);
      expect(response.result, PubVersionFinderResult.noPackageFound);
      expect(response.httpResponse!.statusCode, 404);
      expect(response.httpResponse!.body, '');
    });

    test('HTTP error when getting versions from pub', () async {
      final MockClient mockClient = MockClient((http.Request request) async {
        return http.Response('', 400);
      });
      final PubVersionFinder finder = PubVersionFinder(httpClient: mockClient);
      final PubVersionFinderResponse response =
          await finder.getPackageVersion(package: 'some_package');

      expect(response.versions, isNull);
      expect(response.result, PubVersionFinderResult.fail);
      expect(response.httpResponse!.statusCode, 400);
      expect(response.httpResponse!.body, '');
    });

    test('Get a correct list of versions when http response is OK.', () async {
      const Map<String, dynamic> httpResponse = <String, dynamic>{
        'name': 'some_package',
        'versions': <String>[
          '0.0.1',
          '0.0.2',
          '0.0.2+2',
          '0.1.1',
          '0.0.1+1',
          '0.1.0',
          '0.2.0',
          '0.1.0+1',
          '0.0.2+1',
          '2.0.0',
          '1.2.0',
          '1.0.0',
        ],
      };
      final MockClient mockClient = MockClient((http.Request request) async {
        return http.Response(json.encode(httpResponse), 200);
      });
      final PubVersionFinder finder = PubVersionFinder(httpClient: mockClient);
      final PubVersionFinderResponse response =
          await finder.getPackageVersion(package: 'some_package');

      expect(response.versions, <Version>[
        Version.parse('2.0.0'),
        Version.parse('1.2.0'),
        Version.parse('1.0.0'),
        Version.parse('0.2.0'),
        Version.parse('0.1.1'),
        Version.parse('0.1.0+1'),
        Version.parse('0.1.0'),
        Version.parse('0.0.2+2'),
        Version.parse('0.0.2+1'),
        Version.parse('0.0.2'),
        Version.parse('0.0.1+1'),
        Version.parse('0.0.1'),
      ]);
      expect(response.result, PubVersionFinderResult.success);
      expect(response.httpResponse!.statusCode, 200);
      expect(response.httpResponse!.body, json.encode(httpResponse));
    });
  });
}

class SamplePluginCommand extends PluginCommand {
  SamplePluginCommand(
    this._plugins,
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
    GitDir? gitDir,
  }) : super(packagesDir, fileSystem,
            processRunner: processRunner, gitDir: gitDir);

  final List<String> _plugins;

  @override
  final String name = 'sample';

  @override
  final String description = 'sample command';

  @override
  Future<void> run() async {
    await for (final Directory package in getPlugins()) {
      _plugins.add(package.path);
    }
  }
}

class MockProcessResult extends Mock implements ProcessResult {}
