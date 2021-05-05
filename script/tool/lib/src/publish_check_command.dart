// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'common.dart';

/// A command to check that packages are publishable via 'dart publish'.
class PublishCheckCommand extends PluginCommand {
  /// Creates an instance of the publish command.
  PublishCheckCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
    this.httpClient,
  })  : _pubVersionFinder =
            PubVersionFinder(httpClient: httpClient ?? http.Client()),
        super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addFlag(
      _allowPrereleaseFlag,
      help: 'Allows the pre-release SDK warning to pass.\n'
          'When enabled, a pub warning, which asks to publish the package as a pre-release version when '
          'the SDK constraint is a pre-release version, is ignored.',
      defaultsTo: false,
    );
    argParser.addFlag(_machineFlag,
        help: 'Only prints a final status as a defined string.\n'
            'The possible values are:\n'
            '    $_machineMessageNeedsPublish: There is at least one package need to be published. They also passed all publish checks.\n'
            '    $_machineMessageNoPublish: There are no packages needs to be published. Either no pubspec change detected or all versions have already been published.\n'
            '    $_machineMessageError: Some error has occurred.',
        defaultsTo: false,
        negatable: true);
  }

  static const String _allowPrereleaseFlag = 'allow-pre-release';
  static const String _machineFlag = 'machine';
  static const String _machineMessageNeedsPublish = 'needs-publish';
  static const String _machineMessageNoPublish = 'no-publish';
  static const String _machineMessageError = 'error';

  final List<String> _validStatus = <String>[
    _machineMessageNeedsPublish,
    _machineMessageNoPublish,
    _machineMessageError
  ];

  @override
  final String name = 'publish-check';

  @override
  final String description =
      'Checks to make sure that a plugin *could* be published.';

  /// The custom http client used to query versions on pub.
  final http.Client httpClient;

  final PubVersionFinder _pubVersionFinder;

  @override
  Future<void> run() async {
    final ZoneSpecification logSwitchSpecification = ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String message) {
      final bool logMachineMessage = argResults[_machineFlag] as bool;
      final bool isMachineMessage = _validStatus.contains(message);
      if (logMachineMessage == isMachineMessage) {
        parent.print(zone, message);
      }
    });

    await runZoned(_runCommand, zoneSpecification: logSwitchSpecification);
  }

  Future<void> _runCommand() async {
    final List<Directory> failedPackages = <Directory>[];

    String resultToLog = _machineMessageNoPublish;
    await for (final Directory plugin in getPlugins()) {
      final _PublishCheckResult result = await _passesPublishCheck(plugin);
      switch (result) {
        case _PublishCheckResult._needsPublish:
          if (failedPackages.isEmpty) {
            resultToLog = _machineMessageNeedsPublish;
          }
          break;
        case _PublishCheckResult._noPublish:
          break;
        case _PublishCheckResult._error:
          failedPackages.add(plugin);
          resultToLog = _machineMessageError;
          break;
      }
    }
    _pubVersionFinder.httpClient.close();

    if (failedPackages.isNotEmpty) {
      final String error =
          'FAIL: The following ${failedPackages.length} package(s) failed the '
          'publishing check:';
      final String joinedFailedPackages = failedPackages.join('\n');

      final Colorize colorizedError = Colorize('$error\n$joinedFailedPackages')
        ..red();
      print(colorizedError);
    } else {
      final Colorize passedMessage =
          Colorize('All packages passed publish check!')..green();
      print(passedMessage);
    }

    if (argResults[_machineFlag] as bool) {
      print(resultToLog);
    }
    if (failedPackages.isNotEmpty) {
      throw ToolExit(1);
    }
  }

  Pubspec _tryParsePubspec(Directory package) {
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

  Future<bool> _hasValidPublishCheckRun(Directory package) async {
    final io.Process process = await processRunner.start(
      'flutter',
      <String>['pub', 'publish', '--', '--dry-run'],
      workingDirectory: package,
    );

    final StringBuffer outputBuffer = StringBuffer();

    final Completer<void> stdOutCompleter = Completer<void>();
    process.stdout.listen(
      (List<int> event) {
        final String output = String.fromCharCodes(event);
        if (output.isNotEmpty) {
          print(output);
          outputBuffer.write(output);
        }
      },
      onDone: () => stdOutCompleter.complete(),
    );

    final Completer<void> stdInCompleter = Completer<void>();
    process.stderr.listen(
      (List<int> event) {
        final String output = String.fromCharCodes(event);
        if (output.isNotEmpty) {
          print(Colorize(output)..red());
          outputBuffer.write(output);
        }
      },
      onDone: () => stdInCompleter.complete(),
    );

    if (await process.exitCode == 0) {
      return true;
    }

    if (!(argResults[_allowPrereleaseFlag] as bool)) {
      return false;
    }

    await stdOutCompleter.future;
    await stdInCompleter.future;

    final String output = outputBuffer.toString();
    return output.contains('Package has 1 warning') &&
        output.contains(
            'Packages with an SDK constraint on a pre-release of the Dart SDK should themselves be published as a pre-release version.');
  }

  Future<_PublishCheckResult> _passesPublishCheck(Directory package) async {
    final String packageName = package.basename;
    print('Checking that $packageName can be published.');

    final Pubspec pubspec = _tryParsePubspec(package);
    if (pubspec == null) {
      print('no pubspec');
      return _PublishCheckResult._error;
    } else if (pubspec.publishTo == 'none') {
      print('Package $packageName is marked as unpublishable. Skipping.');
      return _PublishCheckResult._noPublish;
    }

    final Version version = pubspec.version;
    final bool alreadyPublished = await _checkIfAlreadyPublished(
        packageName: packageName, version: version);
    if (alreadyPublished) {
      print(
          'Package $packageName version: $version has already be published on pub.');
      return _PublishCheckResult._noPublish;
    }

    if (await _hasValidPublishCheckRun(package)) {
      print('Package $packageName is able to be published.');
      return _PublishCheckResult._needsPublish;
    } else {
      print('Unable to publish $packageName');
      return _PublishCheckResult._error;
    }
  }

  // Check if `packageName` already has `version` published on pub.
  Future<bool> _checkIfAlreadyPublished(
      {String packageName, Version version}) async {
    final PubVersionFinderResponse pubVersionFinderResponse =
        await _pubVersionFinder.getPackageVersion(package: packageName);
    bool published;
    switch (pubVersionFinderResponse.result) {
      case PubVersionFinderResult.success:
        published = pubVersionFinderResponse.versions.contains(version);
        break;
      case PubVersionFinderResult.fail:
        print(_machineMessageError);
        printErrorAndExit(errorMessage: '''
Error fetching version on pub for $packageName.
HTTP Status ${pubVersionFinderResponse.httpResponse.statusCode}
HTTP response: ${pubVersionFinderResponse.httpResponse.body}
''');
        break;
      case PubVersionFinderResult.noPackageFound:
        published = false;
        break;
    }
    return published;
  }
}

enum _PublishCheckResult {
  _needsPublish,

  _noPublish,

  _error,
}
