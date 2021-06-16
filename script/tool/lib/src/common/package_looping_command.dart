// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;

import 'core.dart';
import 'plugin_command.dart';
import 'process_runner.dart';

/// An abstract base class for a command that iterates over a set of packages
/// controlled by a standard set of flags, running some actions on each package,
/// and collecting and reporting the success/failure of those actions.
abstract class PackageLoopingCommand extends PluginCommand {
  /// Creates a command to operate on [packagesDir] with the given environment.
  PackageLoopingCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    GitDir? gitDir,
  }) : super(packagesDir, processRunner: processRunner, gitDir: gitDir);

  /// Runs the command for [package], returning a list of errors.
  ///
  /// Errors may either be an empty string if there is no context that should
  /// be included in the final error summary (e.g., a command that only has a
  /// single failure mode), or strings that should be listed for that plugin
  /// in the final summary. An empty list indicates success.
  Future<List<String>> runForPackage(Directory package);

  /// Whether or not the output (if any) of [runForPackage] is long, or short.
  ///
  /// This changes the logging that happens at the start of each package's
  /// run.
  bool get hasLongOutput => true;

  /// The text to output at the start when reporting one or more failures.
  /// This will be followed by a list of packages that reported errors, with
  /// the per-package details if any.
  ///
  /// This only needs to be overridden if the summary should provide extra
  /// context.
  String get failureListHeader => 'The following packages had errors:';

  /// The text to output at the end when reporting one or more failures. This
  /// will be printed immediately after the a list of packages that reported
  /// errors.
  ///
  /// This only needs to be overridden if the summary should provide extra
  /// context.
  String get failureListFooter => 'See above for full details.';

  // ----------------------------------------

  /// A convenience constant for [runForPackage] success that's more
  /// self-documenting than the value.
  static const List<String> kSuccess = <String>[];

  /// A convenience constant for [runForPackage] failure without additional
  /// context that's more self-documenting than the value.
  static const List<String> kFailure = <String>[];

  /// Returns the identifying name to use for [package].
  ///
  /// Implementations should not expect a specific format for this string, since
  /// it uses heuristics to try to be precise without being overly verbose. If
  /// an exact format (e.g., published name, or basename) is required, that
  /// should be used instead.
  String packageDescription(Directory package) {
    String packageName = p.relative(package.path, from: packagesDir.path);
    final List<String> components = p.split(packageName);
    // For the common federated plugin pattern of `foo/foo_subpackage`, drop
    // the first part since it's not useful.
    if (components.length == 2 &&
        components[1].startsWith('${components[0]}_')) {
      packageName = components[1];
    }
    return packageName;
  }

  // ----------------------------------------

  @override
  Future<void> run() async {
    final List<Directory> packages = await getPackages().toList();

    final Map<Directory, List<String>> results = <Directory, List<String>>{};
    for (final Directory package in packages) {
      _printPackageHeading(package);
      results[package] = await runForPackage(package);
    }

    // If there were any errors reported, summarize them and exit.
    if (results.values.any((List<String> failures) => failures.isNotEmpty)) {
      const String indentation = '  ';
      printError(failureListHeader);
      for (final Directory package in packages) {
        final List<String> errors = results[package]!;
        if (errors.isNotEmpty) {
          final String errorIndentation = indentation * 2;
          String errorDetails = errors.join('\n$errorIndentation');
          if (errorDetails.isNotEmpty) {
            errorDetails = ':\n$errorIndentation$errorDetails';
          }
          printError('$indentation${packageDescription(package)}$errorDetails');
        }
      }
      printError(failureListFooter);
      throw ToolExit(1);
    }

    printSuccess('\n\nNo issues found!');
  }

  /// Prints the status message indicating that the command is being run for
  /// [package].
  ///
  /// Something is always printed to make it easier to distinguish between
  /// a command running for a package and producing no output, and a command
  /// not having been run for a package.
  void _printPackageHeading(Directory package) {
    String heading = 'Running for ${packageDescription(package)}';
    if (hasLongOutput) {
      heading = '''

============================================================
|| $heading
============================================================
''';
    }
    print(Colorize('$heading...')..cyan());
  }
}
