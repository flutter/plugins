// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/format_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late FormatCommand analyzeCommand;
  late CommandRunner<void> runner;
  late String javaFormatPath;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockPlatform = MockPlatform();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    processRunner = RecordingProcessRunner();
    analyzeCommand = FormatCommand(
      packagesDir,
      processRunner: processRunner,
      platform: mockPlatform,
    );

    // Create the java formatter file that the command checks for, to avoid
    // a download.
    final p.Context path = analyzeCommand.path;
    javaFormatPath = path.join(path.dirname(path.fromUri(mockPlatform.script)),
        'google-java-format-1.3-all-deps.jar');
    fileSystem.file(javaFormatPath).createSync(recursive: true);

    runner = CommandRunner<void>('format_command', 'Test for format_command');
    runner.addCommand(analyzeCommand);
  });

  /// Returns a modified version of a list of [relativePaths] that are relative
  /// to [package] to instead be relative to [packagesDir].
  List<String> _getPackagesDirRelativePaths(
      Directory packageDir, List<String> relativePaths) {
    final p.Context path = analyzeCommand.path;
    final String relativeBase =
        path.relative(packageDir.path, from: packagesDir.path);
    return relativePaths
        .map((String relativePath) => path.join(relativeBase, relativePath))
        .toList();
  }

  /// Returns a list of [count] relative paths to pass to [createFakePlugin]
  /// with name [pluginName] such that each path will be 99 characters long
  /// relative to [packagesDir].
  ///
  /// This is for each of testing batching, since it means each file will
  /// consume 100 characters of the batch length.
  List<String> _get99CharacterPathExtraFiles(String pluginName, int count) {
    final int padding = 99 -
        pluginName.length -
        1 - // the path separator after the plugin name
        1 - // the path separator after the padding
        10; // the file name
    const int filenameBase = 10000;

    final p.Context path = analyzeCommand.path;
    return <String>[
      for (int i = filenameBase; i < filenameBase + count; ++i)
        path.join('a' * padding, '$i.dart'),
    ];
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
              getFlutterCommand(mockPlatform),
              <String>[
                'format',
                ..._getPackagesDirRelativePaths(pluginDir, files)
              ],
              packagesDir.path),
        ]));
  });

  test('does not format .dart files with pragma', () async {
    const List<String> formattedFiles = <String>[
      'lib/a.dart',
      'lib/src/b.dart',
      'lib/src/c.dart',
    ];
    const String unformattedFile = 'lib/src/d.dart';
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: <String>[
        ...formattedFiles,
        unformattedFile,
      ],
    );

    final p.Context posixContext = p.posix;
    childFileWithSubcomponents(pluginDir, posixContext.split(unformattedFile))
        .writeAsStringSync(
            '// copyright bla bla\n// This file is hand-formatted.\ncode...');

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              getFlutterCommand(mockPlatform),
              <String>[
                'format',
                ..._getPackagesDirRelativePaths(pluginDir, formattedFiles)
              ],
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

    processRunner.mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
        <io.Process>[MockProcess(exitCode: 1)];
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
          const ProcessCall('java', <String>['-version'], null),
          ProcessCall(
              'java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ..._getPackagesDirRelativePaths(pluginDir, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails with a clear message if Java is not in the path', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['java'] = <io.Process>[
      MockProcess(exitCode: 1)
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
              'Unable to run \'java\'. Make sure that it is in your path, or '
              'provide a full path with --java.'),
        ]));
  });

  test('fails if Java formatter fails', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['java'] = <io.Process>[
      MockProcess(), // check for working java
      MockProcess(exitCode: 1), // format
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

  test('honors --java flag', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );

    await runCapturingPrint(runner, <String>['format', '--java=/path/to/java']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall('/path/to/java', <String>['--version'], null),
          ProcessCall(
              '/path/to/java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ..._getPackagesDirRelativePaths(pluginDir, files)
              ],
              packagesDir.path),
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
          const ProcessCall('clang-format', <String>['--version'], null),
          ProcessCall(
              'clang-format',
              <String>[
                '-i',
                '--style=Google',
                ..._getPackagesDirRelativePaths(pluginDir, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails with a clear message if clang-format is not in the path',
      () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    createFakePlugin('a_plugin', packagesDir, extraFiles: files);

    processRunner.mockProcessesForExecutable['clang-format'] = <io.Process>[
      MockProcess(exitCode: 1)
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
              'Unable to run \'clang-format\'. Make sure that it is in your '
              'path, or provide a full path with --clang-format.'),
        ]));
  });

  test('honors --clang-format flag', () async {
    const List<String> files = <String>[
      'windows/foo_plugin.cpp',
    ];
    final Directory pluginDir = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );

    await runCapturingPrint(
        runner, <String>['format', '--clang-format=/path/to/clang-format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall(
              '/path/to/clang-format', <String>['--version'], null),
          ProcessCall(
              '/path/to/clang-format',
              <String>[
                '-i',
                '--style=Google',
                ..._getPackagesDirRelativePaths(pluginDir, files)
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
      MockProcess(), // check for working clang-format
      MockProcess(exitCode: 1), // format
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
                ..._getPackagesDirRelativePaths(pluginDir, clangFiles)
              ],
              packagesDir.path),
          ProcessCall(
              getFlutterCommand(mockPlatform),
              <String>[
                'format',
                ..._getPackagesDirRelativePaths(pluginDir, dartFiles)
              ],
              packagesDir.path),
          ProcessCall(
              'java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ..._getPackagesDirRelativePaths(pluginDir, javaFiles)
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

    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess(stdout: changedFilePath),
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
      MockProcess(exitCode: 1)
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

    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.mockProcessesForExecutable['git'] = <io.Process>[
      MockProcess(stdout: changedFilePath), // ls-files
      MockProcess(exitCode: 1), // diff
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
          contains('These files are not formatted correctly'),
          contains(changedFilePath),
          contains('Unable to determine diff.'),
        ]));
  });

  test('Batches moderately long file lists on Windows', () async {
    mockPlatform.isWindows = true;

    const String pluginName = 'a_plugin';
    // -1 since the command itself takes some length.
    const int batchSize = (windowsCommandLineMax ~/ 100) - 1;

    // Make the file list one file longer than would fit in the batch.
    final List<String> batch1 =
        _get99CharacterPathExtraFiles(pluginName, batchSize + 1);
    final String extraFile = batch1.removeLast();

    createFakePlugin(
      pluginName,
      packagesDir,
      extraFiles: <String>[...batch1, extraFile],
    );

    await runCapturingPrint(runner, <String>['format']);

    // Ensure that it was batched...
    expect(processRunner.recordedCalls.length, 2);
    // ... and that the spillover into the second batch was only one file.
    expect(
        processRunner.recordedCalls,
        contains(
          ProcessCall(
              getFlutterCommand(mockPlatform),
              <String>[
                'format',
                '$pluginName\\$extraFile',
              ],
              packagesDir.path),
        ));
  });

  // Validates that the Windows limit--which is much lower than the limit on
  // other platforms--isn't being used on all platforms, as that would make
  // formatting slower on Linux and macOS.
  test('Does not batch moderately long file lists on non-Windows', () async {
    const String pluginName = 'a_plugin';
    // -1 since the command itself takes some length.
    const int batchSize = (windowsCommandLineMax ~/ 100) - 1;

    // Make the file list one file longer than would fit in a Windows batch.
    final List<String> batch =
        _get99CharacterPathExtraFiles(pluginName, batchSize + 1);

    createFakePlugin(
      pluginName,
      packagesDir,
      extraFiles: batch,
    );

    await runCapturingPrint(runner, <String>['format']);

    expect(processRunner.recordedCalls.length, 1);
  });

  test('Batches extremely long file lists on non-Windows', () async {
    const String pluginName = 'a_plugin';
    // -1 since the command itself takes some length.
    const int batchSize = (nonWindowsCommandLineMax ~/ 100) - 1;

    // Make the file list one file longer than would fit in the batch.
    final List<String> batch1 =
        _get99CharacterPathExtraFiles(pluginName, batchSize + 1);
    final String extraFile = batch1.removeLast();

    createFakePlugin(
      pluginName,
      packagesDir,
      extraFiles: <String>[...batch1, extraFile],
    );

    await runCapturingPrint(runner, <String>['format']);

    // Ensure that it was batched...
    expect(processRunner.recordedCalls.length, 2);
    // ... and that the spillover into the second batch was only one file.
    expect(
        processRunner.recordedCalls,
        contains(
          ProcessCall(
              getFlutterCommand(mockPlatform),
              <String>[
                'format',
                '$pluginName/$extraFile',
              ],
              packagesDir.path),
        ));
  });
}
