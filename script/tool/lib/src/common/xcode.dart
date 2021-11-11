// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';

import 'core.dart';
import 'process_runner.dart';

const String _xcodeBuildCommand = 'xcodebuild';
const String _xcRunCommand = 'xcrun';

/// A utility class for interacting with the installed version of Xcode.
class Xcode {
  /// Creates an instance that runs commands with the given [processRunner].
  ///
  /// If [log] is true, commands run by this instance will long various status
  /// messages.
  Xcode({
    this.processRunner = const ProcessRunner(),
    this.log = false,
  });

  /// The [ProcessRunner] used to run commands. Overridable for testing.
  final ProcessRunner processRunner;

  /// Whether or not to log when running commands.
  final bool log;

  /// Runs an `xcodebuild` in [directory] with the given parameters.
  Future<int> runXcodeBuild(
    Directory directory, {
    List<String> actions = const <String>['build'],
    required String workspace,
    required String scheme,
    String? configuration,
    List<String> extraFlags = const <String>[],
  }) {
    final List<String> args = <String>[
      _xcodeBuildCommand,
      ...actions,
      if (workspace != null) ...<String>['-workspace', workspace],
      if (scheme != null) ...<String>['-scheme', scheme],
      if (configuration != null) ...<String>['-configuration', configuration],
      ...extraFlags,
    ];
    final String completeTestCommand = '$_xcRunCommand ${args.join(' ')}';
    if (log) {
      print(completeTestCommand);
    }
    return processRunner.runAndStream(_xcRunCommand, args,
        workingDir: directory);
  }

  /// Returns true if [project], which should be an .xcodeproj directory,
  /// contains a target called [target], false if it does not, and null if the
  /// check fails (e.g., if [project] is not an Xcode project).
  Future<bool?> projectHasTarget(Directory project, String target) async {
    final io.ProcessResult result =
        await processRunner.run(_xcRunCommand, <String>[
      _xcodeBuildCommand,
      '-list',
      '-json',
      '-project',
      project.path,
    ]);
    if (result.exitCode != 0) {
      return null;
    }
    Map<String, dynamic>? projectInfo;
    try {
      projectInfo = (jsonDecode(result.stdout as String)
          as Map<String, dynamic>)['project'] as Map<String, dynamic>?;
    } on FormatException {
      return null;
    }
    if (projectInfo == null) {
      return null;
    }
    final List<String>? targets =
        (projectInfo['targets'] as List<dynamic>?)?.cast<String>();
    return targets?.contains(target) ?? false;
  }

  /// Returns the newest available simulator (highest OS version, with ties
  /// broken in favor of newest device), if any.
  Future<String?> findBestAvailableIphoneSimulator() async {
    final List<String> findSimulatorsArguments = <String>[
      'simctl',
      'list',
      'devices',
      'runtimes',
      'available',
      '--json',
    ];
    final String findSimulatorCompleteCommand =
        '$_xcRunCommand ${findSimulatorsArguments.join(' ')}';
    if (log) {
      print('Looking for available simulators...');
      print(findSimulatorCompleteCommand);
    }
    final io.ProcessResult findSimulatorsResult =
        await processRunner.run(_xcRunCommand, findSimulatorsArguments);
    if (findSimulatorsResult.exitCode != 0) {
      if (log) {
        printError(
            'Error occurred while running "$findSimulatorCompleteCommand":\n'
            '${findSimulatorsResult.stderr}');
      }
      return null;
    }
    final Map<String, dynamic> simulatorListJson =
        jsonDecode(findSimulatorsResult.stdout as String)
            as Map<String, dynamic>;
    final List<Map<String, dynamic>> runtimes =
        (simulatorListJson['runtimes'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final Map<String, Object> devices =
        (simulatorListJson['devices'] as Map<String, dynamic>)
            .cast<String, Object>();
    if (runtimes.isEmpty || devices.isEmpty) {
      return null;
    }
    String? id;
    // Looking for runtimes, trying to find one with highest OS version.
    for (final Map<String, dynamic> rawRuntimeMap in runtimes.reversed) {
      final Map<String, Object> runtimeMap =
          rawRuntimeMap.cast<String, Object>();
      if ((runtimeMap['name'] as String?)?.contains('iOS') != true) {
        continue;
      }
      final String? runtimeID = runtimeMap['identifier'] as String?;
      if (runtimeID == null) {
        continue;
      }
      final List<Map<String, dynamic>>? devicesForRuntime =
          (devices[runtimeID] as List<dynamic>?)?.cast<Map<String, dynamic>>();
      if (devicesForRuntime == null || devicesForRuntime.isEmpty) {
        continue;
      }
      // Looking for runtimes, trying to find latest version of device.
      for (final Map<String, dynamic> rawDevice in devicesForRuntime.reversed) {
        final Map<String, Object> device = rawDevice.cast<String, Object>();
        id = device['udid'] as String?;
        if (id == null) {
          continue;
        }
        if (log) {
          print('device selected: $device');
        }
        return id;
      }
    }
    return null;
  }
}
