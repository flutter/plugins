// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/process_runner.dart';

/// In theory this should be 8191, but in practice that was still resulting in
/// "The input line is too long" errors. This was chosen as a value that worked
/// in practice in testing with flutter/plugins, but may need to be adjusted
/// based on further experience.
@visibleForTesting
const int windowsCommandLineMax = 8000;

/// This value is picked somewhat arbitrarily based on checking `ARG_MAX` on a
/// macOS and Linux machine. If anyone encounters a lower limit in pratice, it
/// can be lowered accordingly.
@visibleForTesting
const int nonWindowsCommandLineMax = 1000000;

const int _exitClangFormatFailed = 3;
const int _exitFlutterFormatFailed = 4;
const int _exitJavaFormatFailed = 5;
const int _exitGitFailed = 6;
const int _exitDependencyMissing = 7;

final Uri _googleFormatterUrl = Uri.https('github.com',
    '/google/google-java-format/releases/download/google-java-format-1.3/google-java-format-1.3-all-deps.jar');

/// A command to format all package code.
class FormatCommand extends PluginCommand {
  /// Creates an instance of the format command.
  FormatCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addFlag('fail-on-change', hide: true);
    argParser.addOption('clang-format',
        defaultsTo: 'clang-format', help: 'Path to "clang-format" executable.');
    argParser.addOption('java',
        defaultsTo: 'java', help: 'Path to "java" executable.');
  }

  @override
  final String name = 'format';

  @override
  final String description =
      'Formats the code of all packages (Java, Objective-C, C++, and Dart).\n\n'
      'This command requires "git", "flutter" and "clang-format" v5 to be in '
      'your path.';

  @override
  Future<void> run() async {
    final String googleFormatterPath = await _getGoogleFormatterPath();

    // This class is not based on PackageLoopingCommand because running the
    // formatters separately for each package is an order of magnitude slower,
    // due to the startup overhead of the formatters.
    final Iterable<String> files =
        await _getFilteredFilePaths(getFiles(), relativeTo: packagesDir);
    await _formatDart(files);
    await _formatJava(files, googleFormatterPath);
    await _formatCppAndObjectiveC(files);

    if (getBoolArg('fail-on-change')) {
      final bool modified = await _didModifyAnything();
      if (modified) {
        throw ToolExit(exitCommandFoundErrors);
      }
    }
  }

  Future<bool> _didModifyAnything() async {
    final io.ProcessResult modifiedFiles = await processRunner.run(
      'git',
      <String>['ls-files', '--modified'],
      workingDir: packagesDir,
      logOnError: true,
    );
    if (modifiedFiles.exitCode != 0) {
      printError('Unable to determine changed files.');
      throw ToolExit(_exitGitFailed);
    }

    print('\n\n');

    final String stdout = modifiedFiles.stdout as String;
    if (stdout.isEmpty) {
      print('All files formatted correctly.');
      return false;
    }

    print('These files are not formatted correctly (see diff below):');
    LineSplitter.split(stdout).map((String line) => '  $line').forEach(print);

    print('\nTo fix run "pub global activate flutter_plugin_tools && '
        'pub global run flutter_plugin_tools format" or copy-paste '
        'this command into your terminal:');

    final io.ProcessResult diff = await processRunner.run(
      'git',
      <String>['diff'],
      workingDir: packagesDir,
      logOnError: true,
    );
    if (diff.exitCode != 0) {
      printError('Unable to determine diff.');
      throw ToolExit(_exitGitFailed);
    }
    print('patch -p1 <<DONE');
    print(diff.stdout);
    print('DONE');
    return true;
  }

  Future<void> _formatCppAndObjectiveC(Iterable<String> files) async {
    final Iterable<String> clangFiles = _getPathsWithExtensions(
        files, <String>{'.h', '.m', '.mm', '.cc', '.cpp'});
    if (clangFiles.isNotEmpty) {
      final String clangFormat = getStringArg('clang-format');
      if (!await _hasDependency(clangFormat)) {
        printError('Unable to run "clang-format". Make sure that it is in your '
            'path, or provide a full path with --clang-format.');
        throw ToolExit(_exitDependencyMissing);
      }

      print('Formatting .cc, .cpp, .h, .m, and .mm files...');
      final int exitCode = await _runBatched(
          getStringArg('clang-format'), <String>['-i', '--style=file'],
          files: clangFiles);
      if (exitCode != 0) {
        printError(
            'Failed to format C, C++, and Objective-C files: exit code $exitCode.');
        throw ToolExit(_exitClangFormatFailed);
      }
    }
  }

  Future<void> _formatJava(
      Iterable<String> files, String googleFormatterPath) async {
    final Iterable<String> javaFiles =
        _getPathsWithExtensions(files, <String>{'.java'});
    if (javaFiles.isNotEmpty) {
      final String java = getStringArg('java');
      if (!await _hasDependency(java)) {
        printError(
            'Unable to run "java". Make sure that it is in your path, or '
            'provide a full path with --java.');
        throw ToolExit(_exitDependencyMissing);
      }

      print('Formatting .java files...');
      final int exitCode = await _runBatched(
          java, <String>['-jar', googleFormatterPath, '--replace'],
          files: javaFiles);
      if (exitCode != 0) {
        printError('Failed to format Java files: exit code $exitCode.');
        throw ToolExit(_exitJavaFormatFailed);
      }
    }
  }

  Future<void> _formatDart(Iterable<String> files) async {
    final Iterable<String> dartFiles =
        _getPathsWithExtensions(files, <String>{'.dart'});
    if (dartFiles.isNotEmpty) {
      print('Formatting .dart files...');
      // `flutter format` doesn't require the project to actually be a Flutter
      // project.
      final int exitCode = await _runBatched(flutterCommand, <String>['format'],
          files: dartFiles);
      if (exitCode != 0) {
        printError('Failed to format Dart files: exit code $exitCode.');
        throw ToolExit(_exitFlutterFormatFailed);
      }
    }
  }

  /// Given a stream of [files], returns the paths of any that are not in known
  /// locations to ignore, relative to [relativeTo].
  Future<Iterable<String>> _getFilteredFilePaths(
    Stream<File> files, {
    required Directory relativeTo,
  }) async {
    // Returns a pattern to check for [directories] as a subset of a file path.
    RegExp pathFragmentForDirectories(List<String> directories) {
      String s = path.separator;
      // Escape the separator for use in the regex.
      if (s == r'\') {
        s = r'\\';
      }
      return RegExp('(?:^|$s)${path.joinAll(directories)}$s');
    }

    final String fromPath = relativeTo.path;

    // Dart files are allowed to have a pragma to disable auto-formatting. This
    // was added because Hixie hurts when dealing with what dartfmt does to
    // artisanally-formatted Dart, while Stuart gets really frustrated when
    // dealing with PRs from newer contributors who don't know how to make Dart
    // readable. After much discussion, it was decided that files in the plugins
    // and packages repos that really benefit from hand-formatting (e.g. files
    // with large blobs of hex literals) could be opted-out of the requirement
    // that they be autoformatted, so long as the code's owner was willing to
    // bear the cost of this during code reviews.
    // In the event that code ownership moves to someone who does not hold the
    // same views as the original owner, the pragma can be removed and the file
    // auto-formatted.
    const String handFormattedExtension = '.dart';
    const String handFormattedPragma = '// This file is hand-formatted.';

    return files
        .where((File file) {
          // See comment above near [handFormattedPragma].
          return path.extension(file.path) != handFormattedExtension ||
              !file.readAsLinesSync().contains(handFormattedPragma);
        })
        .map((File file) => path.relative(file.path, from: fromPath))
        .where((String path) =>
            // Ignore files in build/ directories (e.g., headers of frameworks)
            // to avoid useless extra work in local repositories.
            !path.contains(
                pathFragmentForDirectories(<String>['example', 'build'])) &&
            // Ignore files in Pods, which are not part of the repository.
            !path.contains(pathFragmentForDirectories(<String>['Pods'])) &&
            // Ignore .dart_tool/, which can have various intermediate files.
            !path.contains(pathFragmentForDirectories(<String>['.dart_tool'])))
        .toList();
  }

  Iterable<String> _getPathsWithExtensions(
      Iterable<String> files, Set<String> extensions) {
    return files.where(
        (String filePath) => extensions.contains(path.extension(filePath)));
  }

  Future<String> _getGoogleFormatterPath() async {
    final String javaFormatterPath = path.join(
        path.dirname(path.fromUri(platform.script)),
        'google-java-format-1.3-all-deps.jar');
    final File javaFormatterFile =
        packagesDir.fileSystem.file(javaFormatterPath);

    if (!javaFormatterFile.existsSync()) {
      print('Downloading Google Java Format...');
      final http.Response response = await http.get(_googleFormatterUrl);
      javaFormatterFile.writeAsBytesSync(response.bodyBytes);
    }

    return javaFormatterPath;
  }

  /// Returns true if [command] can be run successfully.
  Future<bool> _hasDependency(String command) async {
    // Some versions of Java accept both -version and --version, but some only
    // accept -version.
    final String versionFlag = command == 'java' ? '-version' : '--version';
    try {
      final io.ProcessResult result =
          await processRunner.run(command, <String>[versionFlag]);
      if (result.exitCode != 0) {
        return false;
      }
    } on io.ProcessException {
      // Thrown when the binary is missing entirely.
      return false;
    }
    return true;
  }

  /// Runs [command] on [arguments] on all of the files in [files], batched as
  /// necessary to avoid OS command-line length limits.
  ///
  /// Returns the exit code of the first failure, which stops the run, or 0
  /// on success.
  Future<int> _runBatched(
    String command,
    List<String> arguments, {
    required Iterable<String> files,
  }) async {
    final int commandLineMax =
        platform.isWindows ? windowsCommandLineMax : nonWindowsCommandLineMax;

    // Compute the max length of the file argument portion of a batch.
    // Add one to each argument's length for the space before it.
    final int argumentTotalLength =
        arguments.fold(0, (int sum, String arg) => sum + arg.length + 1);
    final int batchMaxTotalLength =
        commandLineMax - command.length - argumentTotalLength;

    // Run the command in batches.
    final List<List<String>> batches =
        _partitionFileList(files, maxStringLength: batchMaxTotalLength);
    for (final List<String> batch in batches) {
      batch.sort(); // For ease of testing.
      final int exitCode = await processRunner.runAndStream(
          command, <String>[...arguments, ...batch],
          workingDir: packagesDir);
      if (exitCode != 0) {
        return exitCode;
      }
    }
    return 0;
  }

  /// Partitions [files] into batches whose max string length as parameters to
  /// a command (including the spaces between them, and between the list and
  /// the command itself) is no longer than [maxStringLength].
  List<List<String>> _partitionFileList(Iterable<String> files,
      {required int maxStringLength}) {
    final List<List<String>> batches = <List<String>>[<String>[]];
    int currentBatchTotalLength = 0;
    for (final String file in files) {
      final int length = file.length + 1 /* for the space */;
      if (currentBatchTotalLength + length > maxStringLength) {
        // Start a new batch.
        batches.add(<String>[]);
        currentBatchTotalLength = 0;
      }
      batches.last.add(file);
      currentBatchTotalLength += length;
    }
    return batches;
  }
}
