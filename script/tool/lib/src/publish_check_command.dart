// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
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
        help: 'Switch outputs to a machine readable JSON. \n'
            'The JSON contains a "status" field indicating the final status of the command, the possible values are:\n'
            '    $_statusNeedsPublish: There is at least one package need to be published. They also passed all publish checks.\n'
            '    $_statusMessageNoPublish: There are no packages needs to be published. Either no pubspec change detected or all versions have already been published.\n'
            '    $_statusMessageError: Some error has occurred.',
        defaultsTo: false,
        negatable: true);
  }

  static const String _allowPrereleaseFlag = 'allow-pre-release';
  static const String _machineFlag = 'machine';
  static const String _statusNeedsPublish = 'needs-publish';
  static const String _statusMessageNoPublish = 'no-publish';
  static const String _statusMessageError = 'error';
  static const String _statusKey = 'status';
  static const String _humanMessageKey = 'humanMessage';

  final List<String> _validStatus = <String>[
    _statusNeedsPublish,
    _statusMessageNoPublish,
    _statusMessageError
  ];

  @override
  final String name = 'publish-check';

  @override
  final String description =
      'Checks to make sure that a plugin *could* be published.';

  /// The custom http client used to query versions on pub.
  final http.Client httpClient;

  final PubVersionFinder _pubVersionFinder;

  // The output JSON when the _machineFlag is on.
  final Map<String, dynamic> _machineOutput = <String, dynamic>{};

  final List<String> _humanMessages = <String>[];

  @override
  Future<void> run() async {
    final ZoneSpecification logSwitchSpecification = ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String message) {
      final bool logMachineMessage = getBoolArg(_machineFlag);
      if (logMachineMessage && message != _prettyJson(_machineOutput)) {
        _humanMessages.add(message);
      } else {
        parent.print(zone, message);
      }
    });

    await runZoned(_runCommand, zoneSpecification: logSwitchSpecification);
  }

  Future<void> _runCommand() async {
    final List<Directory> failedPackages = <Directory>[];

    String status = _statusMessageNoPublish;
    await for (final Directory plugin in getPlugins()) {
      final _PublishCheckResult result = await _passesPublishCheck(plugin);
      switch (result) {
        case _PublishCheckResult._notPublished:
          if (failedPackages.isEmpty) {
            status = _statusNeedsPublish;
          }
          break;
        case _PublishCheckResult._published:
          break;
        case _PublishCheckResult._error:
          failedPackages.add(plugin);
          status = _statusMessageError;
          break;
      }
    }
    _pubVersionFinder.httpClient.close();

    if (failedPackages.isNotEmpty) {
      final String error =
          'The following ${failedPackages.length} package(s) failed the '
          'publishing check:';
      final String joinedFailedPackages = failedPackages.join('\n');
      _printImportantStatusMessage('$error\n$joinedFailedPackages',
          isError: true);
    } else {
      _printImportantStatusMessage('All packages passed publish check!',
          isError: false);
    }

    if (getBoolArg(_machineFlag)) {
      _setStatus(status);
      _machineOutput[_humanMessageKey] = _humanMessages;
      print(_prettyJson(_machineOutput));
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
          _printImportantStatusMessage(output, isError: true);
          outputBuffer.write(output);
        }
      },
      onDone: () => stdInCompleter.complete(),
    );

    if (await process.exitCode == 0) {
      return true;
    }

    if (!getBoolArg(_allowPrereleaseFlag)) {
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
      return _PublishCheckResult._published;
    }

    final Version version = pubspec.version;
    final _PublishCheckResult alreadyPublishedResult =
        await _checkIfAlreadyPublished(
            packageName: packageName, version: version);
    if (alreadyPublishedResult == _PublishCheckResult._published) {
      print(
          'Package $packageName version: $version has already be published on pub.');
      return alreadyPublishedResult;
    } else if (alreadyPublishedResult == _PublishCheckResult._error) {
      print('Check pub version failed $packageName');
      return _PublishCheckResult._error;
    }

    if (await _hasValidPublishCheckRun(package)) {
      print('Package $packageName is able to be published.');
      return _PublishCheckResult._notPublished;
    } else {
      print('Unable to publish $packageName');
      return _PublishCheckResult._error;
    }
  }

  // Check if `packageName` already has `version` published on pub.
  Future<_PublishCheckResult> _checkIfAlreadyPublished(
      {String packageName, Version version}) async {
    final PubVersionFinderResponse pubVersionFinderResponse =
        await _pubVersionFinder.getPackageVersion(package: packageName);
    _PublishCheckResult result;
    switch (pubVersionFinderResponse.result) {
      case PubVersionFinderResult.success:
        result = pubVersionFinderResponse.versions.contains(version)
            ? _PublishCheckResult._published
            : _PublishCheckResult._notPublished;
        break;
      case PubVersionFinderResult.fail:
        print('''
Error fetching version on pub for $packageName.
HTTP Status ${pubVersionFinderResponse.httpResponse.statusCode}
HTTP response: ${pubVersionFinderResponse.httpResponse.body}
''');
        result = _PublishCheckResult._error;
        break;
      case PubVersionFinderResult.noPackageFound:
        result = _PublishCheckResult._notPublished;
        break;
    }
    return result;
  }

  void _setStatus(String status) {
    assert(_validStatus.contains(status));
    _machineOutput[_statusKey] = status;
  }

  String _prettyJson(Map<String, dynamic> map) {
    return const JsonEncoder.withIndent('  ').convert(_machineOutput);
  }

  void _printImportantStatusMessage(String message, {@required bool isError}) {
    final String statusMessage = '${isError ? 'ERROR' : 'SUCCESS'}: $message';
    if (getBoolArg(_machineFlag)) {
      print(statusMessage);
    } else {
      final Colorize colorizedMessage = Colorize(statusMessage);
      if (isError) {
        colorizedMessage.red();
      } else {
        colorizedMessage.green();
      }
      print(colorizedMessage);
    }
  }
}

enum _PublishCheckResult {
  _notPublished,

  _published,

  _error,
}
