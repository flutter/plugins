// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:platform/platform.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:quiver/collection.dart';

FileSystem mockFileSystem = MemoryFileSystem(
    style: LocalPlatform().isWindows
        ? FileSystemStyle.windows
        : FileSystemStyle.posix);
Directory mockPackagesDir;

/// Creates a mock packages directory in the mock file system.
///
/// If [parentDir] is set the mock packages dir will be creates as a child of
/// it. If not [mockFileSystem] will be used instead.
void initializeFakePackages({Directory parentDir}) {
  mockPackagesDir =
      (parentDir ?? mockFileSystem.currentDirectory).childDirectory('packages');
  mockPackagesDir.createSync();
}

/// Creates a plugin package with the given [name] in [mockPackagesDir].
Directory createFakePlugin(
  String name, {
  bool withSingleExample = false,
  List<String> withExamples = const <String>[],
  List<List<String>> withExtraFiles = const <List<String>>[],
  bool isFlutter = true,
  bool isAndroidPlugin = false,
  bool isIosPlugin = false,
  bool isWebPlugin = false,
  bool isLinuxPlugin = false,
  bool isMacOsPlugin = false,
  bool isWindowsPlugin = false,
  bool includeChangeLog = false,
  bool includeVersion = false,
  String parentDirectoryName = '',
}) {
  assert(!(withSingleExample && withExamples.isNotEmpty),
      'cannot pass withSingleExample and withExamples simultaneously');

  final Directory pluginDirectory = (parentDirectoryName != '')
      ? mockPackagesDir.childDirectory(parentDirectoryName).childDirectory(name)
      : mockPackagesDir.childDirectory(name);
  pluginDirectory.createSync(recursive: true);

  createFakePubspec(
    pluginDirectory,
    name: name,
    isFlutter: isFlutter,
    isAndroidPlugin: isAndroidPlugin,
    isIosPlugin: isIosPlugin,
    isWebPlugin: isWebPlugin,
    isLinuxPlugin: isLinuxPlugin,
    isMacOsPlugin: isMacOsPlugin,
    isWindowsPlugin: isWindowsPlugin,
    includeVersion: includeVersion,
  );
  if (includeChangeLog) {
    createFakeCHANGELOG(pluginDirectory, '''
## 0.0.1
  * Some changes.
  ''');
  }

  if (withSingleExample) {
    final Directory exampleDir = pluginDirectory.childDirectory('example')
      ..createSync();
    createFakePubspec(exampleDir,
        name: "${name}_example", isFlutter: isFlutter);
  } else if (withExamples.isNotEmpty) {
    final Directory exampleDir = pluginDirectory.childDirectory('example')
      ..createSync();
    for (String example in withExamples) {
      final Directory currentExample = exampleDir.childDirectory(example)
        ..createSync();
      createFakePubspec(currentExample, name: example, isFlutter: isFlutter);
    }
  }

  for (List<String> file in withExtraFiles) {
    final List<String> newFilePath = <String>[pluginDirectory.path]
      ..addAll(file);
    final File newFile =
        mockFileSystem.file(mockFileSystem.path.joinAll(newFilePath));
    newFile.createSync(recursive: true);
  }

  return pluginDirectory;
}

void createFakeCHANGELOG(Directory parent, String texts) {
  parent.childFile('CHANGELOG.md').createSync();
  parent.childFile('CHANGELOG.md').writeAsStringSync(texts);
}

/// Creates a `pubspec.yaml` file with a flutter dependency.
void createFakePubspec(
  Directory parent, {
  String name = 'fake_package',
  bool isFlutter = true,
  bool includeVersion = false,
  bool isAndroidPlugin = false,
  bool isIosPlugin = false,
  bool isWebPlugin = false,
  bool isLinuxPlugin = false,
  bool isMacOsPlugin = false,
  bool isWindowsPlugin = false,
  String version = '0.0.1',
}) {
  parent.childFile('pubspec.yaml').createSync();
  String yaml = '''
name: $name
flutter:
  plugin:
    platforms:
''';
  if (isAndroidPlugin) {
    yaml += '''
      android:
        package: io.flutter.plugins.fake
        pluginClass: FakePlugin
''';
  }
  if (isIosPlugin) {
    yaml += '''
      ios:
        pluginClass: FLTFakePlugin
''';
  }
  if (isWebPlugin) {
    yaml += '''
      web:
        pluginClass: FakePlugin
        fileName: ${name}_web.dart
''';
  }
  if (isLinuxPlugin) {
    yaml += '''
      linux:
        pluginClass: FakePlugin
''';
  }
  if (isMacOsPlugin) {
    yaml += '''
      macos:
        pluginClass: FakePlugin
''';
  }
  if (isWindowsPlugin) {
    yaml += '''
      windows:
        pluginClass: FakePlugin
''';
  }
  if (isFlutter) {
    yaml += '''
dependencies:
  flutter:
    sdk: flutter
''';
  }
  if (includeVersion) {
    yaml += '''
version: $version
publish_to: http://no_pub_server.com # Hardcoded safeguard to prevent this from somehow being published by a broken test.
''';
  }
  parent.childFile('pubspec.yaml').writeAsStringSync(yaml);
}

/// Cleans up the mock packages directory, making it an empty directory again.
void cleanupPackages() {
  mockPackagesDir.listSync().forEach((FileSystemEntity entity) {
    entity.deleteSync(recursive: true);
  });
}

/// Run the command [runner] with the given [args] and return
/// what was printed.
Future<List<String>> runCapturingPrint(
    CommandRunner<PluginCommand> runner, List<String> args) async {
  final List<String> prints = <String>[];
  final ZoneSpecification spec = ZoneSpecification(
    print: (_, __, ___, String message) {
      prints.add(message);
    },
  );
  await Zone.current
      .fork(specification: spec)
      .run<Future<void>>(() => runner.run(args));

  return prints;
}

/// A mock [ProcessRunner] which records process calls.
class RecordingProcessRunner extends ProcessRunner {
  io.Process processToReturn;
  final List<ProcessCall> recordedCalls = <ProcessCall>[];

  /// Populate for [io.ProcessResult] to use a String [stdout] instead of a [List] of [int].
  String resultStdout;

  /// Populate for [io.ProcessResult] to use a String [stderr] instead of a [List] of [int].
  String resultStderr;

  @override
  Future<int> runAndStream(
    String executable,
    List<String> args, {
    Directory workingDir,
    bool exitOnError = false,
  }) async {
    recordedCalls.add(ProcessCall(executable, args, workingDir?.path));
    return Future<int>.value(
        processToReturn == null ? 0 : await processToReturn.exitCode);
  }

  /// Returns [io.ProcessResult] created from [processToReturn], [resultStdout], and [resultStderr].
  @override
  Future<io.ProcessResult> run(String executable, List<String> args,
      {Directory workingDir,
      bool exitOnError = false,
      stdoutEncoding = io.systemEncoding,
      stderrEncoding = io.systemEncoding}) async {
    recordedCalls.add(ProcessCall(executable, args, workingDir?.path));
    io.ProcessResult result;

    if (processToReturn != null) {
      result = io.ProcessResult(
          processToReturn.pid,
          await processToReturn.exitCode,
          resultStdout ?? processToReturn.stdout,
          resultStderr ?? processToReturn.stderr);
    }
    return Future<io.ProcessResult>.value(result);
  }

  @override
  Future<io.ProcessResult> runAndExitOnError(
    String executable,
    List<String> args, {
    Directory workingDir,
  }) async {
    recordedCalls.add(ProcessCall(executable, args, workingDir?.path));
    io.ProcessResult result;
    if (processToReturn != null) {
      result = io.ProcessResult(
          processToReturn.pid,
          await processToReturn.exitCode,
          resultStdout ?? processToReturn.stdout,
          resultStderr ?? processToReturn.stderr);
    }
    return Future<io.ProcessResult>.value(result);
  }

  @override
  Future<io.Process> start(String executable, List<String> args,
      {Directory workingDirectory}) async {
    recordedCalls.add(ProcessCall(executable, args, workingDirectory?.path));
    return Future<io.Process>.value(processToReturn);
  }
}

/// A recorded process call.
class ProcessCall {
  const ProcessCall(this.executable, this.args, this.workingDir);

  /// The executable that was called.
  final String executable;

  /// The arguments passed to [executable] in the call.
  final List<String> args;

  /// The working directory this process was called from.
  final String workingDir;

  @override
  bool operator ==(dynamic other) {
    if (other is! ProcessCall) {
      return false;
    }
    final ProcessCall otherCall = other;
    return executable == otherCall.executable &&
        listsEqual(args, otherCall.args) &&
        workingDir == otherCall.workingDir;
  }

  @override
  int get hashCode =>
      executable?.hashCode ??
      0 ^ args?.hashCode ??
      0 ^ workingDir?.hashCode ??
      0;

  @override
  String toString() {
    final List<String> command = <String>[executable]..addAll(args);
    return '"${command.join(' ')}" in $workingDir';
  }
}
