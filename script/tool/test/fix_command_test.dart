// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/fix_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockPlatform = MockPlatform();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    processRunner = RecordingProcessRunner();
    final FixCommand command = FixCommand(
      packagesDir,
      processRunner: processRunner,
      platform: mockPlatform,
    );

    runner = CommandRunner<void>('fix_command', 'Test for fix_command');
    runner.addCommand(command);
  });

  test('runs fix in top-level packages and subpackages', () async {
    final RepositoryPackage package = createFakePackage('a', packagesDir);
    final RepositoryPackage plugin = createFakePlugin('b', packagesDir);

    await runCapturingPrint(runner, <String>['fix']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('dart', const <String>['fix', '--apply'], package.path),
          ProcessCall('dart', const <String>['fix', '--apply'],
              package.getExamples().first.path),
          ProcessCall('dart', const <String>['fix', '--apply'], plugin.path),
          ProcessCall('dart', const <String>['fix', '--apply'],
              plugin.getExamples().first.path),
        ]));
  });

  test('fails if "dart fix" fails', () async {
    createFakePlugin('foo', packagesDir);

    processRunner.mockProcessesForExecutable['dart'] = <io.Process>[
      MockProcess(exitCode: 1),
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(runner, <String>['fix'],
        errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Unable to automatically fix package.'),
      ]),
    );
  });
}
