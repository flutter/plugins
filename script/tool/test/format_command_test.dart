// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/format_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;
  late String javaFormatPath;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    processRunner = RecordingProcessRunner();
    final FormatCommand analyzeCommand =
        FormatCommand(packagesDir, processRunner: processRunner);

    // Create the java formatter file that the command checks for, to avoid
    // a download.
    javaFormatPath = p.join(p.dirname(p.fromUri(io.Platform.script)),
        'google-java-format-1.3-all-deps.jar');
    fileSystem.file(javaFormatPath).createSync(recursive: true);

    runner = CommandRunner<void>('format_command', 'Test for format_command');
    runner.addCommand(analyzeCommand);
  });

  List<String> _getAbsolutePaths(
      Directory package, List<String> relativePaths) {
    return relativePaths
        .map((String path) => p.join(package.path, path))
        .toList();
  }

  test('formats .dart files', () async {
    const List<String> files = <String>[
      'lib/a.dart',
      'lib/src/b.dart',
      'lib/src/c.dart',
    ];
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              <String>['format', ..._getAbsolutePaths(pluginDir, files)],
              packagesDir.path),
        ]));
  });

  test('fails if flutter format fails', () async {
    const List<String> files = <String>[
      'lib/a.dart',
      'lib/src/b.dart',
      'lib/src/c.dart',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['flutter'] = <io.Process>[
      MockProcess.failing()
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Failed to format Dart files: exit code 1.'),
        ]));
  });

  test('formats .java files', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ..._getAbsolutePaths(pluginDir, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails if Java formatter fails', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['java'] = <io.Process>[
      MockProcess.failing()
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Failed to format Java files: exit code 1.'),
        ]));
  });

  test('formats c-ish files', () async {
    const List<String> files = <String>[
      'ios/Classes/Foo.h',
      'ios/Classes/Foo.m',
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
      'macos/Classes/Foo.mm',
      'windows/foo_plugin.cpp',
    ];
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'clang-format',
              <String>[
                '-i',
                '--style=Google',
                ..._getAbsolutePaths(pluginDir, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails if clang-format fails', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['clang-format'] = <io.Process>[
      MockProcess.failing()
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Failed to format C, C++, and Objective-C files: exit code 1.'),
        ]));
  });

  test('skips known non-repo files', () async {
    const List<String> skipFiles = <String>[
      '/example/build/SomeFramework.framework/Headers/SomeFramework.h',
      '/example/Pods/APod.framework/Headers/APod.h',
      '.dart_tool/internals/foo.cc',
      '.dart_tool/internals/Bar.java',
      '.dart_tool/internals/baz.dart',
    ];
    const List<String> clangFiles = <String>['ios/Classes/Foo.h'];
    const List<String> dartFiles = <String>['lib/a.dart'];
    const List<String> javaFiles = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java'
    ];
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: <String>[
        ...skipFiles,
        // Include some files that should be formatted to validate that it's
        // correctly filtering even when running the commands.
        ...clangFiles,
        ...dartFiles,
        ...javaFiles,
      ],
    );

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          ProcessCall(
              'clang-format',
              <String>[
                '-i',
                '--style=Google',
                ..._getAbsolutePaths(pluginDir, clangFiles)
              ],
              packagesDir.path),
          ProcessCall(
              'flutter',
              <String>['format', ..._getAbsolutePaths(pluginDir, dartFiles)],
              packagesDir.path),
          ProcessCall(
              'java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ..._getAbsolutePaths(pluginDir, javaFiles)
              ],
              packagesDir.path),
        ]));
  });

  test('fails if files are changed with --file-on-change', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess.succeeding(),
    ];
    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.resultStdout = changedFilePath;
    Error? commandError;
    final List<String> output =
        await runCapturingPrint(runner, <String>['format', '--fail-on-change'],
            errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('These files are not formatted correctly'),
          contains(changedFilePath),
          contains('patch -p1 <<DONE'),
        ]));
  });

  test('fails if git ls-files fails', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess.failing()
    ];
    Error? commandError;
    final List<String> output =
        await runCapturingPrint(runner, <String>['format', '--fail-on-change'],
            errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to determine changed files.'),
        ]));
  });

  test('reports git diff failures', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess.succeeding(), // ls-files
      MockProcess.failing(), // diff
    ];
    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.resultStdout = changedFilePath;
    Error? commandError;
    final List<String> output =
        await runCapturingPrint(runner, <String>['format', '--fail-on-change'],
            errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('These files are not formatted correctly'),
          contains(changedFilePath),
          contains('Unable to determine diff.'),
        ]));
  });
}
