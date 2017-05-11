// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

void main(List<String> args) {
  Directory packagesDir = new Directory(
      p.join(p.dirname(p.dirname(p.fromUri(Platform.script))), 'packages'));

  new CommandRunner('cli', 'Various productivity utils.')
    ..addCommand(new TestCommand(packagesDir))
    ..addCommand(new AnalyzeCommand(packagesDir))
    ..addCommand(new FormatCommand(packagesDir))
    ..addCommand(new BuildCommand(packagesDir))
    ..run(args);
}

class TestCommand extends Command {
  TestCommand(this.packagesDir);

  final Directory packagesDir;

  final name = 'test';
  final description = 'Runs the tests for all packages.';

  Future run() async {
    List<String> failingPackages = <String>[];
    for (Directory packageDir in _listAllPackages(packagesDir)) {
      String packageName = p.relative(packageDir.path, from: packagesDir.path);
      if (!new Directory(p.join(packageDir.path, 'test')).existsSync()) {
        print('\nSKIPPING $packageName - no test subdirectory');
        continue;
      }

      print('\nRUNNING $packageName tests...');
      Process process = await Process.start('flutter', ['test', '--color'],
          workingDirectory: packageDir.path);
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);
      if (await process.exitCode != 0) {
        failingPackages.add(packageName);
      }
    }

    print('\n\n');
    if (failingPackages.isNotEmpty) {
      print('Tests for the following packages are failing (see above):');
      failingPackages.forEach((String package) {
        print(' * $package');
      });
    } else {
      print('All tests are passing!');
    }
    exit(failingPackages.length);
  }

  Iterable<Directory> _listAllPackages(Directory root) => root
      .listSync(recursive: true)
      .where((FileSystemEntity entity) =>
          entity is File && p.basename(entity.path) == 'pubspec.yaml')
      .map((FileSystemEntity entity) => entity.parent);
}

class AnalyzeCommand extends Command {
  AnalyzeCommand(this.packagesDir);

  final Directory packagesDir;

  final name = 'analyze';
  final description = 'Analyzes all packages.';

  Future run() async {
    print('TODO(goderbauer): Implement command when '
        'https://github.com/flutter/flutter/issues/10015 is resolved.');
    exit(1);
  }
}

class FormatCommand extends Command {
  FormatCommand(this.packagesDir) {
    argParser.addFlag('travis', hide: true);
    argParser.addOption('clang-format', defaultsTo: 'clang-format');
  }

  final Directory packagesDir;

  final name = 'format';
  final description = 'Formats the code of all packages.';

  Future run() async {
    String javaFormatterPath = p.join(p.dirname(p.fromUri(Platform.script)),
        'google-java-format-1.3-all-deps.jar');
    File javaFormatterFile = new File(javaFormatterPath);

    if (!javaFormatterFile.existsSync()) {
      print('Downloading Google Java Format...');
      http.Response response = await http.get(
          'https://github.com/google/google-java-format/releases/download/google-java-format-1.3/google-java-format-1.3-all-deps.jar');
      javaFormatterFile.writeAsBytesSync(response.bodyBytes);
    }

    print('Formatting all .dart files...');
    Process.runSync('flutter', ['format'], workingDirectory: packagesDir.path);

    print('Formatting all .java files...');
    Iterable<String> javaFiles = _getFilesWithExtension(packagesDir, '.java');
    Process.runSync(
        'java', ['-jar', javaFormatterPath, '--replace']..addAll(javaFiles),
        workingDirectory: packagesDir.path);

    print('Formatting all .m and .h files...');
    Iterable<String> hFiles = _getFilesWithExtension(packagesDir, '.h');
    Iterable<String> mFiles = _getFilesWithExtension(packagesDir, '.m');
    Process.runSync(argResults['clang-format'],
        ['-i', '--style=Google']..addAll(hFiles)..addAll(mFiles),
        workingDirectory: packagesDir.path);

    if (argResults['travis']) {
      ProcessResult modifiedFiles = Process.runSync(
          'git', ['ls-files', '--modified'],
          workingDirectory: packagesDir.path);
      print('\n\n');
      if (modifiedFiles.stdout.isNotEmpty) {
        ProcessResult diff = Process.runSync('git', ['diff', '--color'],
            workingDirectory: packagesDir.path);
        print(diff.stdout);

        print('These files are not formatted correctly (see diff above):');
        LineSplitter
            .split(modifiedFiles.stdout)
            .map((String line) => '  $line')
            .forEach(print);
        print('\nTo fix run "pub get && dart cli.dart format" inside scripts/');
        exit(1);
      } else {
        print('All files formatted correctly.');
        exit(0);
      }
    }
  }

  Iterable<String> _getFilesWithExtension(Directory dir, String extension) =>
      dir
          .listSync(recursive: true)
          .where((FileSystemEntity entity) =>
              entity is File && p.extension(entity.path) == extension)
          .map((FileSystemEntity entity) => entity.path);
}

class BuildCommand extends Command {
  BuildCommand(this.packagesDir) {
    argParser.addFlag('ipa', defaultsTo: Platform.isMacOS);
    argParser.addFlag('apk');
  }

  final Directory packagesDir;

  final name = 'build';
  final description = 'Builds all example apps.';

  Future run() async {
    List<String> failingPackages = <String>[];
    for (Directory example in _getExamplePackages(packagesDir)) {
      String packageName = p.relative(example.path, from: packagesDir.path);

      if (argResults['ipa']) {
        print('\nBUILDING IPA for $packageName');
        Process process = await Process.start(
            'flutter', ['build', 'ios', '--no-codesign'],
            workingDirectory: example.path);
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
        if (await process.exitCode != 0) {
          failingPackages.add('$packageName (ipa)');
        }
      }

      if (argResults['apk']) {
        print('\nBUILDING APK for $packageName');
        Process process = await Process.start('flutter', ['build', 'apk'],
            workingDirectory: example.path);
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
        if (await process.exitCode != 0) {
          failingPackages.add('$packageName (apk)');
        }
      }
    }

    print('\n\n');
    if (failingPackages.isNotEmpty) {
      print('The following build are failing (see above for details):');
      failingPackages.forEach((String package) {
        print(' * $package');
      });
    } else {
      print('All builds successful!');
    }
    exit(failingPackages.length);
  }

  Iterable<Directory> _getExamplePackages(Directory dir) => dir
      .listSync(recursive: true)
      .where((FileSystemEntity entity) =>
          entity is Directory && p.basename(entity.path) == 'example')
      .where((Directory dir) => dir.listSync().any((FileSystemEntity entity) =>
          entity is File && p.basename(entity.path) == 'pubspec.yaml'));
}
