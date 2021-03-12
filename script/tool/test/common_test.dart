// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  RecordingProcessRunner processRunner;
  CommandRunner runner;
  List<String> plugins;

  setUp(() {
    initializeFakePackages();
    processRunner = RecordingProcessRunner();
    plugins = [];
    final SamplePluginCommand samplePluginCommand = SamplePluginCommand(
      plugins,
      mockPackagesDir,
      mockFileSystem,
      processRunner: processRunner,
    );
    runner =
        CommandRunner<Null>('common_command', 'Test for common functionality');
    runner.addCommand(samplePluginCommand);
  });

  tearDown(() {
    mockPackagesDir.deleteSync(recursive: true);
  });

  test('all plugins from file system', () async {
    final Directory plugin1 = createFakePlugin('plugin1');
    final Directory plugin2 = createFakePlugin('plugin2');
    await runner.run(<String>['sample']);
    expect(plugins, unorderedEquals(<String>[plugin1.path, plugin2.path]));
  });

  test('exclude plugins when plugins flag is specified', () async {
    createFakePlugin('plugin1');
    final Directory plugin2 = createFakePlugin('plugin2');
    await runner.run(
        <String>['sample', '--plugins=plugin1,plugin2', '--exclude=plugin1']);
    expect(plugins, unorderedEquals(<String>[plugin2.path]));
  });

  test('exclude plugins when plugins flag isn\'t specified', () async {
    createFakePlugin('plugin1');
    createFakePlugin('plugin2');
    await runner.run(<String>['sample', '--exclude=plugin1,plugin2']);
    expect(plugins, unorderedEquals(<String>[]));
  });

  test('exclude federated plugins when plugins flag is specified', () async {
    createFakePlugin('plugin1', parentDirectoryName: 'federated');
    final Directory plugin2 = createFakePlugin('plugin2');
    await runner.run(<String>[
      'sample',
      '--plugins=federated/plugin1,plugin2',
      '--exclude=federated/plugin1'
    ]);
    expect(plugins, unorderedEquals(<String>[plugin2.path]));
  });

  test('exclude entire federated plugins when plugins flag is specified',
      () async {
    createFakePlugin('plugin1', parentDirectoryName: 'federated');
    final Directory plugin2 = createFakePlugin('plugin2');
    await runner.run(<String>[
      'sample',
      '--plugins=federated/plugin1,plugin2',
      '--exclude=federated'
    ]);
    expect(plugins, unorderedEquals(<String>[plugin2.path]));
  });
}

class SamplePluginCommand extends PluginCommand {
  SamplePluginCommand(
    this.plugins_,
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner);

  List<String> plugins_;

  @override
  final String name = 'sample';

  @override
  final String description = 'sample command';

  @override
  Future<Null> run() async {
    await for (Directory package in getPlugins()) {
      this.plugins_.add(package.path);
    }
  }
}
