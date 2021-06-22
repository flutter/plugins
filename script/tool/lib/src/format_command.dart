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

    await _formatDart();
    await _formatJava(googleFormatterPath);
    await _formatCppAndObjectiveC();

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

  Future<void> _formatCppAndObjectiveC() async {
    print('Formatting all .cc, .cpp, .mm, .m, and .h files...');
    final Iterable<String> allFiles = <String>[
      ...await _getFilesWithExtension('.h'),
      ...await _getFilesWithExtension('.m'),
      ...await _getFilesWithExtension('.mm'),
      ...await _getFilesWithExtension('.cc'),
      ...await _getFilesWithExtension('.cpp'),
    ];
    // Split this into multiple invocations to avoid a
    // 'ProcessException: Argument list too long'.
    final Iterable<List<String>> batches = partition(allFiles, 100);
    for (final List<String> batch in batches) {
      await processRunner.runAndStream(getStringArg('clang-format'),
          <String>['-i', '--style=Google', ...batch],
          workingDir: packagesDir, exitOnError: true);
    }
  }

  Future<void> _formatJava(String googleFormatterPath) async {
    print('Formatting all .java files...');
    final Iterable<String> javaFiles = await _getFilesWithExtension('.java');
    await processRunner.runAndStream('java',
        <String>['-jar', googleFormatterPath, '--replace', ...javaFiles],
        workingDir: packagesDir, exitOnError: true);
  }

  Future<void> _formatDart() async {
    // This actually should be fine for non-Flutter Dart projects, no need to
    // specifically shell out to dartfmt -w in that case.
    print('Formatting all .dart files...');
    final Iterable<String> dartFiles = await _getFilesWithExtension('.dart');
    if (dartFiles.isEmpty) {
      print(
          'No .dart files to format. If you set the `--exclude` flag, most likey they were skipped');
    } else {
      await processRunner.runAndStream(
          'flutter', <String>['format', ...dartFiles],
          workingDir: packagesDir, exitOnError: true);
    }
  }

  Future<List<String>> _getFilesWithExtension(String extension) async =>
      getFiles()
          .where((File file) => p.extension(file.path) == extension)
          .map((File file) => file.path)
          .toList();

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
