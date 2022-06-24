// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/trim_dev_dependencies.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;
  late CommandRunner<void> runner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);

    final TrimDevDependenciesCommand command = TrimDevDependenciesCommand(
      packagesDir,
    );
    runner = CommandRunner<void>('trim_dev_dependencies_command',
        'Test for trim_dev_dependencies_command');
    runner.addCommand(command);
  });

  void _addToPubspec(RepositoryPackage package, String addition) {
    final String originalContent = package.pubspecFile.readAsStringSync();
    package.pubspecFile.writeAsStringSync('''
$originalContent
$addition
''');
  }

  test('skips if nothing is removed', () async {
    createFakePackage('a_package', packagesDir, version: '1.0.0');

    final List<String> output =
        await runCapturingPrint(runner, <String>['trim-dev-dependencies']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('SKIPPING: Nothing to remove.'),
      ]),
    );
  });

  test('removes build_runner', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir, version: '1.0.0');

    _addToPubspec(package, '''
dev_dependencies:
  build_runner: ^2.1.8
  something_else: ^1.0.0
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['trim-dev-dependencies']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Removed build_runner'),
      ]),
    );
    expect(package.pubspecFile.readAsStringSync(), contains('something_else:'));
  });

  test('removes pigeon', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir, version: '1.0.0');

    _addToPubspec(package, '''
dev_dependencies:
  pigeon: ^3.2.0
  something_else: ^1.0.0
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['trim-dev-dependencies']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Removed pigeon'),
      ]),
    );
    expect(package.pubspecFile.readAsStringSync(), contains('something_else:'));
  });

  test('removes from examples', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir, version: '1.0.0');

    final RepositoryPackage example = package.getExamples().first;
    _addToPubspec(example, '''
dev_dependencies:
  pigeon: ^3.2.0
  something_else: ^1.0.0
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['trim-dev-dependencies']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Removed pigeon'),
      ]),
    );
    expect(example.pubspecFile.readAsStringSync(), contains('something_else:'));
  });
}
