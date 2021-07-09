// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:quiver/iterables.dart';

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/process_runner.dart';

const int _exitClangFormatFailed = 3;
const int _exitFlutterFormatFailed = 4;
const int _exitJavaFormatFailed = 5;
const int _exitGitFailed = 6;

final Uri _googleFormatterUrl = Uri.https('github.com',
    '/google/google-java-format/releases/download/google-java-format-1.3/google-java-format-1.3-all-deps.jar');

/// A command to format all package code.
class FormatCommand extends PluginCommand {
  /// Creates an instance of the format command.
  FormatCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addFlag('fail-on-change', hide: true);
    argParser.addOption('clang-format',
        defaultsTo: 'clang-format',
        help: 'Path to executable of clang-format.');
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
    final Iterable<String> files = await _getFilteredFilePaths(getFiles());
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
      print('Formatting .cc, .cpp, .h, .m, and .mm files...');
      final Iterable<List<String>> batches = partition(clangFiles, 100);
      int exitCode = 0;
      for (final List<String> batch in batches) {
        batch.sort(); // For ease of testing; partition changes the order.
        exitCode = await processRunner.runAndStream(
            getStringArg('clang-format'),
            <String>['-i', '--style=Google', ...batch],
            workingDir: packagesDir);
        if (exitCode != 0) {
          break;
        }
      }
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
      print('Formatting .java files...');
      final int exitCode = await processRunner.runAndStream('java',
          <String>['-jar', googleFormatterPath, '--replace', ...javaFiles],
          workingDir: packagesDir);
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
      final int exitCode = await processRunner.runAndStream(
          'flutter', <String>['format', ...dartFiles],
          workingDir: packagesDir);
      if (exitCode != 0) {
        printError('Failed to format Dart files: exit code $exitCode.');
        throw ToolExit(_exitFlutterFormatFailed);
      }
    }
  }

  Future<Iterable<String>> _getFilteredFilePaths(Stream<File> files) async {
    // Returns a pattern to check for [directories] as a subset of a file path.
    RegExp pathFragmentForDirectories(List<String> directories) {
      final String s = p.separator;
      return RegExp('(?:^|$s)${p.joinAll(directories)}$s');
    }

    return files
        .map((File file) => file.path)
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
    return files.where((String path) => extensions.contains(p.extension(path)));
  }

  Future<String> _getGoogleFormatterPath() async {
    final String javaFormatterPath = p.join(
        p.dirname(p.fromUri(io.Platform.script)),
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
}
