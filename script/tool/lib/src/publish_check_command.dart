// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'common.dart';

class PublishCheckCommand extends PluginCommand {
  PublishCheckCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner);

  @override
  final String name = 'publish-check';

  @override
  final String description =
      'Checks to make sure that a plugin *could* be published.';

  @override
  Future<void> run() async {
    checkSharding();
    final List<Directory> failedPackages = <Directory>[];

    await for (final Directory plugin in getPlugins()) {
      if (!(await passesPublishCheck(plugin))) failedPackages.add(plugin);
    }

    if (failedPackages.isNotEmpty) {
      final String error =
          'FAIL: The following ${failedPackages.length} package(s) failed the '
          'publishing check:';
      final String joinedFailedPackages = failedPackages.join('\n');

      final Colorize colorizedError = Colorize('$error\n$joinedFailedPackages')
        ..red();
      print(colorizedError);
      throw ToolExit(1);
    }

    final Colorize passedMessage =
        Colorize('All packages passed publish check!')..green();
    print(passedMessage);
  }

  Pubspec tryParsePubspec(Directory package) {
    final File pubspecFile = package.childFile('pubspec.yaml');

    try {
      return Pubspec.parse(pubspecFile.readAsStringSync());
    } on Exception catch (exception) {
      print(
        'Failed to parse `pubspec.yaml` at ${pubspecFile.path}: $exception}',
      );
      return null;
    }
  }

  Future<bool> hasValidPublishCheckRun(Directory package) async {
    final io.Process process = await processRunner.start(
      'flutter',
      <String>['pub', 'publish', '--', '--dry-run'],
      workingDirectory: package,
    );

    final StringBuffer outputBuffer = StringBuffer();

    final Completer<void> stdOutCompleter = Completer<void>();
    process.stdout.listen(
      (List<int> event) {
        io.stdout.add(event);
        outputBuffer.write(String.fromCharCodes(event));
      },
      onDone: () => stdOutCompleter.complete(),
    );

    final Completer<void> stdInCompleter = Completer<void>();
    process.stderr.listen(
      (List<int> event) {
        io.stderr.add(event);
        outputBuffer.write(String.fromCharCodes(event));
      },
      onDone: () => stdInCompleter.complete(),
    );

    if (await process.exitCode == 0) return true;

    await stdOutCompleter.future;
    await stdInCompleter.future;

    final String output = outputBuffer.toString();
    return output.contains('Package has 1 warning') &&
        output.contains(
            'Packages with an SDK constraint on a pre-release of the Dart SDK should themselves be published as a pre-release version.');
  }

  Future<bool> passesPublishCheck(Directory package) async {
    final String packageName = package.basename;
    print('Checking that $packageName can be published.');

    final Pubspec pubspec = tryParsePubspec(package);
    if (pubspec == null) {
      return false;
    } else if (pubspec.publishTo == 'none') {
      print('Package $packageName is marked as unpublishable. Skipping.');
      return true;
    }

    if (await hasValidPublishCheckRun(package)) {
      print('Package $packageName is able to be published.');
      return true;
    } else {
      print('Unable to publish $packageName');
      return false;
    }
  }
}
