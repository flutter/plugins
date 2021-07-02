// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/process_runner.dart';

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

    await for (final Directory package in getPlugins()) {
      print('Formatting files for ${package.basename}...');
      final Iterable<String> files =
          await _getFilteredFilePaths(getFilesForPackage(package));
      await _formatDart(files);
      await _formatJava(files, googleFormatterPath);
      await _formatCppAndObjectiveC(files);
    }

    if (getBoolArg('fail-on-change')) {
      final bool modified = await _didModifyAnything();
      if (modified) {
        throw ToolExit(1);
      }
    }
  }

  Future<bool> _didModifyAnything() async {
    final io.ProcessResult modifiedFiles = await processRunner.run(
      'git',
      <String>['ls-files', '--modified'],
      workingDir: packagesDir,
      exitOnError: true,
      logOnError: true,
    );

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

    print('patch -p1 <<DONE');
    final io.ProcessResult diff = await processRunner.run(
      'git',
      <String>['diff'],
      workingDir: packagesDir,
      exitOnError: true,
      logOnError: true,
    );
    print(diff.stdout);
    print('DONE');
    return true;
  }

  Future<void> _formatCppAndObjectiveC(Iterable<String> files) async {
    final Iterable<String> clangFiles = _getPathsWithExtensions(
        files, <String>{'.h', '.m', '.mm', '.cc', '.cpp'});
    if (clangFiles.isNotEmpty) {
      print('Formatting .cc, .cpp, .h, .m, and .mm files...');
      await processRunner.runAndStream(getStringArg('clang-format'),
          <String>['-i', '--style=Google', ...clangFiles],
          workingDir: packagesDir, exitOnError: true);
    }
  }

  Future<void> _formatJava(
      Iterable<String> files, String googleFormatterPath) async {
    final Iterable<String> javaFiles =
        _getPathsWithExtensions(files, <String>{'.java'});
    if (javaFiles.isNotEmpty) {
      print('Formatting .java files...');
      await processRunner.runAndStream('java',
          <String>['-jar', googleFormatterPath, '--replace', ...javaFiles],
          workingDir: packagesDir, exitOnError: true);
    }
  }

  Future<void> _formatDart(Iterable<String> files) async {
    final Iterable<String> dartFiles =
        _getPathsWithExtensions(files, <String>{'.dart'});
    if (dartFiles.isNotEmpty) {
      print('Formatting .dart files...');
      // `flutter format` doesn't require the project to actually be a Flutter
      // project.
      await processRunner.runAndStream(
          'flutter', <String>['format', ...dartFiles],
          workingDir: packagesDir, exitOnError: true);
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
            !path.contains(pathFragmentForDirectories(<String>['Pods'])))
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
