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

  /// Called during [run] before any calls to [runForPackage]. This provides an
  /// opportunity to fail early if the command can't be run (e.g., because the
  /// arguments are invalid), and to set up any run-level state.
  Future<void> initializeRun() async {}

  /// Runs the command for [package], returning a list of errors.
  ///
  /// Errors may either be an empty string if there is no context that should
  /// be included in the final error summary (e.g., a command that only has a
  /// single failure mode), or strings that should be listed for that package
  /// in the final summary. An empty list indicates success.
  Future<List<String>> runForPackage(Directory package);

  /// Called during [run] after all calls to [runForPackage]. This provides an
  /// opportunity to do any cleanup of run-level state.
  Future<void> completeRun() async {}

  /// Whether or not the output (if any) of [runForPackage] is long, or short.
  ///
  /// This changes the logging that happens at the start of each package's
  /// run; long output gets a banner-style message to make it easier to find,
  /// while short output gets a single-line entry.
  ///
  /// When this is false, runForPackage output should be indented if possible,
  /// to make the output structure easier to follow.
  bool get hasLongOutput => true;

  /// Whether to loop over all packages (e.g., including example/), rather than
  /// only top-level packages.
  bool get includeSubpackages => false;

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
  static const List<String> success = <String>[];

  /// A convenience constant for [runForPackage] failure without additional
  /// context that's more self-documenting than the value.
  static const List<String> failure = <String>[''];

  /// Prints a message using a standard format indicating that the package was
  /// skipped, with an explanation of why.
  void printSkip(String reason) {
    print(Colorize('SKIPPING: $reason')..darkGray());
  }

  /// Returns the identifying name to use for [package].
  ///
  /// Implementations should not expect a specific format for this string, since
  /// it uses heuristics to try to be precise without being overly verbose. If
  /// an exact format (e.g., published name, or basename) is required, that
  /// should be used instead.
  String getPackageDescription(Directory package) {
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

  /// The suggested indentation for printed output.
  String get indentation => hasLongOutput ? '' : '  ';

  // ----------------------------------------

  @override
  Future<void> run() async {
    await initializeRun();

    final List<Directory> packages = includeSubpackages
        ? await getPackages().toList()
        : await getPlugins().toList();

    final Map<Directory, List<String>> results = <Directory, List<String>>{};
    for (final Directory package in packages) {
      _printPackageHeading(package);
      results[package] = await runForPackage(package);
    }

    completeRun();

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
          printError(
              '$indentation${getPackageDescription(package)}$errorDetails');
        }
      }
      printError(failureListFooter);
      throw ToolExit(exitCommandFoundErrors);
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
    String heading = 'Running for ${getPackageDescription(package)}';
    if (hasLongOutput) {
      heading = '''

============================================================
|| $heading
============================================================
''';
    } else {
      heading = '$heading...';
    }
    print(Colorize(heading)..cyan());
  }
}
