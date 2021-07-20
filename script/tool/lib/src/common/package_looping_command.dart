// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'core.dart';
import 'plugin_command.dart';
import 'process_runner.dart';

/// Possible outcomes of a command run for a package.
enum RunState {
  /// The command succeeded for the package.
  succeeded,

  /// The command was skipped for the package.
  skipped,

  /// The command failed for the package.
  failed,
}

/// The result of a [runForPackage] call.
class PackageResult {
  /// A successful result.
  PackageResult.success() : this._(RunState.succeeded);

  /// A run that was skipped as explained in [reason].
  PackageResult.skip(String reason)
      : this._(RunState.skipped, <String>[reason]);

  /// A run that failed.
  ///
  /// If [errors] are provided, they will be listed in the summary, otherwise
  /// the summary will simply show that the package failed.
  PackageResult.fail([List<String> errors = const <String>[]])
      : this._(RunState.failed, errors);

  const PackageResult._(this.state, [this.details = const <String>[]]);

  /// The state the package run completed with.
  final RunState state;

  /// Information about the result:
  /// - For `succeeded`, this is empty.
  /// - For `skipped`, it contains a single entry describing why the run was
  ///   skipped.
  /// - For `failed`, it contains zero or more specific error details to be
  ///   shown in the summary.
  final List<String> details;
}

/// An abstract base class for a command that iterates over a set of packages
/// controlled by a standard set of flags, running some actions on each package,
/// and collecting and reporting the success/failure of those actions.
abstract class PackageLoopingCommand extends PluginCommand {
  /// Creates a command to operate on [packagesDir] with the given environment.
  PackageLoopingCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
    GitDir? gitDir,
  }) : super(packagesDir,
            processRunner: processRunner, platform: platform, gitDir: gitDir);

  /// Packages that had at least one [logWarning] call.
  final Set<Directory> _packagesWithWarnings = <Directory>{};

  /// Number of warnings that happened outside of a [runForPackage] call.
  int _otherWarningCount = 0;

  /// The package currently being run by [runForPackage].
  Directory? _currentPackage;

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
  Future<PackageResult> runForPackage(Directory package);

  /// Called during [run] after all calls to [runForPackage]. This provides an
  /// opportunity to do any cleanup of run-level state.
  Future<void> completeRun() async {}

  /// If [captureOutput], this is called just before exiting with all captured
  /// [output].
  Future<void> handleCapturedOutput(List<String> output) async {}

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

  /// If true, all printing (including the summary) will be redirected to a
  /// buffer, and provided in a call to [handleCapturedOutput] at the end of
  /// the run.
  ///
  /// Capturing output will disable any colorizing of output from this base
  /// class.
  bool get captureOutput => false;

  // ----------------------------------------

  /// Logs that a warning occurred, and prints `warningMessage` in yellow.
  ///
  /// Warnings are not surfaced in CI summaries, so this is only useful for
  /// highlighting something when someone is already looking though the log
  /// messages. DO NOT RELY on someone noticing a warning; instead, use it for
  /// things that might be useful to someone debugging an unexpected result.
  void logWarning(String warningMessage) {
    print(Colorize(warningMessage)..yellow());
    if (_currentPackage != null) {
      _packagesWithWarnings.add(_currentPackage!);
    } else {
      ++_otherWarningCount;
    }
  }

  /// Returns the identifying name to use for [package].
  ///
  /// Implementations should not expect a specific format for this string, since
  /// it uses heuristics to try to be precise without being overly verbose. If
  /// an exact format (e.g., published name, or basename) is required, that
  /// should be used instead.
  String getPackageDescription(Directory package) {
    String packageName = getRelativePosixPath(package, from: packagesDir);
    final List<String> components = p.posix.split(packageName);
    // For the common federated plugin pattern of `foo/foo_subpackage`, drop
    // the first part since it's not useful.
    if (components.length == 2 &&
        components[1].startsWith('${components[0]}_')) {
      packageName = components[1];
    }
    return packageName;
  }

  /// Returns the relative path from [from] to [entity] in Posix style.
  ///
  /// This should be used when, for example, printing package-relative paths in
  /// status or error messages.
  String getRelativePosixPath(
    FileSystemEntity entity, {
    required Directory from,
  }) =>
      p.posix.joinAll(path.split(path.relative(entity.path, from: from.path)));

  /// The suggested indentation for printed output.
  String get indentation => hasLongOutput ? '' : '  ';

  // ----------------------------------------

  @override
  Future<void> run() async {
    bool succeeded;
    if (captureOutput) {
      final List<String> output = <String>[];
      final ZoneSpecification logSwitchSpecification = ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String message) {
        output.add(message);
      });
      succeeded = await runZoned<Future<bool>>(_runInternal,
          zoneSpecification: logSwitchSpecification);
      await handleCapturedOutput(output);
    } else {
      succeeded = await _runInternal();
    }

    if (!succeeded) {
      throw ToolExit(exitCommandFoundErrors);
    }
  }

  Future<bool> _runInternal() async {
    _packagesWithWarnings.clear();
    _otherWarningCount = 0;
    _currentPackage = null;

    await initializeRun();

    final List<Directory> packages = includeSubpackages
        ? await getPackages().toList()
        : await getPlugins().toList();

    final Map<Directory, PackageResult> results = <Directory, PackageResult>{};
    for (final Directory package in packages) {
      _currentPackage = package;
      _printPackageHeading(package);
      final PackageResult result = await runForPackage(package);
      if (result.state == RunState.skipped) {
        final String message =
            '${indentation}SKIPPING: ${result.details.first}';
        captureOutput ? print(message) : print(Colorize(message)..darkGray());
      }
      results[package] = result;
    }
    _currentPackage = null;

    completeRun();

    print('\n');
    // If there were any errors reported, summarize them and exit.
    if (results.values
        .any((PackageResult result) => result.state == RunState.failed)) {
      _printFailureSummary(packages, results);
      return false;
    }

    // Otherwise, print a summary of what ran for ease of auditing that all the
    // expected tests ran.
    _printRunSummary(packages, results);

    print('\n');
    _printSuccess('No issues found!');
    return true;
  }

  void _printSuccess(String message) {
    captureOutput ? print(message) : printSuccess(message);
  }

  void _printError(String message) {
    captureOutput ? print(message) : printError(message);
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
    captureOutput ? print(heading) : print(Colorize(heading)..cyan());
  }

  /// Prints a summary of packges run, packages skipped, and warnings.
  void _printRunSummary(
      List<Directory> packages, Map<Directory, PackageResult> results) {
    final Set<Directory> skippedPackages = results.entries
        .where((MapEntry<Directory, PackageResult> entry) =>
            entry.value.state == RunState.skipped)
        .map((MapEntry<Directory, PackageResult> entry) => entry.key)
        .toSet();
    final int skipCount = skippedPackages.length;
    // Split the warnings into those from packages that ran, and those that
    // were skipped.
    final Set<Directory> _skippedPackagesWithWarnings =
        _packagesWithWarnings.intersection(skippedPackages);
    final int skippedWarningCount = _skippedPackagesWithWarnings.length;
    final int runWarningCount =
        _packagesWithWarnings.length - skippedWarningCount;

    final String runWarningSummary =
        runWarningCount > 0 ? ' ($runWarningCount with warnings)' : '';
    final String skippedWarningSummary =
        runWarningCount > 0 ? ' ($skippedWarningCount with warnings)' : '';
    print('------------------------------------------------------------');
    if (hasLongOutput) {
      _printPerPackageRunOverview(packages, skipped: skippedPackages);
    }
    print(
        'Ran for ${packages.length - skipCount} package(s)$runWarningSummary');
    if (skipCount > 0) {
      print('Skipped $skipCount package(s)$skippedWarningSummary');
    }
    if (_otherWarningCount > 0) {
      print('$_otherWarningCount warnings not associated with a package');
    }
  }

  /// Prints a one-line-per-package overview of the run results for each
  /// package.
  void _printPerPackageRunOverview(List<Directory> packages,
      {required Set<Directory> skipped}) {
    print('Run overview:');
    for (final Directory package in packages) {
      final bool hadWarning = _packagesWithWarnings.contains(package);
      Styles style;
      String summary;
      if (skipped.contains(package)) {
        summary = 'skipped';
        style = hadWarning ? Styles.LIGHT_YELLOW : Styles.DARK_GRAY;
      } else {
        summary = 'ran';
        style = hadWarning ? Styles.YELLOW : Styles.GREEN;
      }
      if (hadWarning) {
        summary += ' (with warning)';
      }

      if (!captureOutput) {
        summary = (Colorize(summary)..apply(style)).toString();
      }
      print('  ${getPackageDescription(package)} - $summary');
    }
    print('');
  }

  /// Prints a summary of all of the failures from [results].
  void _printFailureSummary(
      List<Directory> packages, Map<Directory, PackageResult> results) {
    const String indentation = '  ';
    _printError(failureListHeader);
    for (final Directory package in packages) {
      final PackageResult result = results[package]!;
      if (result.state == RunState.failed) {
        final String errorIndentation = indentation * 2;
        String errorDetails = '';
        if (result.details.isNotEmpty) {
          errorDetails =
              ':\n$errorIndentation${result.details.join('\n$errorIndentation')}';
        }
        _printError(
            '$indentation${getPackageDescription(package)}$errorDetails');
      }
    }
    _printError(failureListFooter);
  }
}
