// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';

import 'core.dart';

/// A class used to run processes.
///
/// We use this instead of directly running the process so it can be overridden
/// in tests.
class ProcessRunner {
  /// Creates a new process runner.
  const ProcessRunner();

  /// Run the [executable] with [args] and stream output to stderr and stdout.
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// If [exitOnError] is set to `true`, then this will throw an error if
  /// the [executable] terminates with a non-zero exit code.
  ///
  /// Returns the exit code of the [executable].
  Future<int> runAndStream(
    String executable,
    List<String> args, {
    Directory? workingDir,
    bool exitOnError = false,
  }) async {
    print(
        'Running command: "$executable ${args.join(' ')}" in ${workingDir?.path ?? io.Directory.current.path}');
    final io.Process process = await io.Process.start(executable, args,
        workingDirectory: workingDir?.path);
    await io.stdout.addStream(process.stdout);
    await io.stderr.addStream(process.stderr);
    if (exitOnError && await process.exitCode != 0) {
      final String error =
          _getErrorString(executable, args, workingDir: workingDir);
      print('$error See above for details.');
      throw ToolExit(await process.exitCode);
    }
    return process.exitCode;
  }

  /// Run the [executable] with [args].
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// If [exitOnError] is set to `true`, then this will throw an error if
  /// the [executable] terminates with a non-zero exit code.
  /// Defaults to `false`.
  ///
  /// If [logOnError] is set to `true`, it will print a formatted message about the error.
  /// Defaults to `false`
  ///
  /// Returns the [io.ProcessResult] of the [executable].
  Future<io.ProcessResult> run(String executable, List<String> args,
      {Directory? workingDir,
      bool exitOnError = false,
      bool logOnError = false,
      Encoding stdoutEncoding = io.systemEncoding,
      Encoding stderrEncoding = io.systemEncoding}) async {
    final io.ProcessResult result = await io.Process.run(executable, args,
        workingDirectory: workingDir?.path,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding);
    if (result.exitCode != 0) {
      if (logOnError) {
        final String error =
            _getErrorString(executable, args, workingDir: workingDir);
        print('$error Stderr:\n${result.stdout}');
      }
      if (exitOnError) {
        throw ToolExit(result.exitCode);
      }
    }
    return result;
  }

  /// Starts the [executable] with [args].
  ///
  /// The current working directory of [executable] can be overridden by
  /// passing [workingDir].
  ///
  /// Returns the started [io.Process].
  Future<io.Process> start(String executable, List<String> args,
      {Directory? workingDirectory}) async {
    final io.Process process = await io.Process.start(executable, args,
        workingDirectory: workingDirectory?.path);
    return process;
  }

  String _getErrorString(String executable, List<String> args,
      {Directory? workingDir}) {
    final String workdir = workingDir == null ? '' : ' in ${workingDir.path}';
    return 'ERROR: Unable to execute "$executable ${args.join(' ')}"$workdir.';
  }
}
