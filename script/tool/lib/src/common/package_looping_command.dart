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
import 'repository_package.dart';

/// Possible outcomes of a command run for a package.
enum RunState {
  /// The command succeeded for the package.
  succeeded,

  /// The command was skipped for the package.
  skipped,

  /// The command was skipped for the package because it was explicitly excluded
  /// in the command arguments.
  excluded,

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

  /// A run that was excluded by the command invocation.
  PackageResult.exclude() : this._(RunState.excluded);

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
  final Set<PackageEnumerationEntry> _packagesWithWarnings =
      <PackageEnumerationEntry>{};

  /// Number of warnings that happened outside of a [runForPackage] call.
  int _otherWarningCount = 0;

  /// The package currently being run by [runForPackage].
  PackageEnumerationEntry? _currentPackageEntry;

  /// Called during [run] before any calls to [runForPackage]. This provides an
  /// opportunity to fail early if the command can't be run (e.g., because the
  /// arguments are invalid), and to set up any run-level state.
  Future<void> initializeRun() async {}

  /// Returns the packages to process. By default, this returns the packages
  /// defined by the standard tooling flags and the [inculdeSubpackages] option,
  /// but can be overridden for custom package enumeration.
  ///
  /// Note: Consistent behavior across commands whenever possibel is a goal for
  /// this tool, so this should be overridden only in rare cases.
  Stream<PackageEnumerationEntry> getPackagesToProcess() async* {
    yield* includeSubpackages
        ? getTargetPackagesAndSubpackages(filterExcluded: false)
        : getTargetPackages(filterExcluded: false);
  }

  /// Runs the command for [package], returning a list of errors.
  ///
  /// Errors may either be an empty string if there is no context that should
  /// be included in the final error summary (e.g., a command that only has a
  /// single failure mode), or strings that should be listed for that package
  /// in the final summary. An empty list indicates success.
  Future<PackageResult> runForPackage(RepositoryPackage package);

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

  /// The summary string used for a successful run in the final overview output.
  String get successSummaryMessage => 'ran';

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
    if (_currentPackageEntry != null) {
      _packagesWithWarnings.add(_currentPackageEntry!);
    } else {
      ++_otherWarningCount;
    }
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
    _currentPackageEntry = null;

    await initializeRun();

    final List<PackageEnumerationEntry> targetPackages =
        await getPackagesToProcess().toList();

    final Map<PackageEnumerationEntry, PackageResult> results =
        <PackageEnumerationEntry, PackageResult>{};
    for (final PackageEnumerationEntry entry in targetPackages) {
      _currentPackageEntry = entry;
      _printPackageHeading(entry);

      // Command implementations should never see excluded packages; they are
      // included at this level only for logging.
      if (entry.excluded) {
        results[entry] = PackageResult.exclude();
        continue;
      }

      PackageResult result;
      try {
        result = await runForPackage(entry.package);
      } catch (e, stack) {
        printError(e.toString());
        printError(stack.toString());
        result = PackageResult.fail(<String>['Unhandled exception']);
      }
      if (result.state == RunState.skipped) {
        final String message =
            '${indentation}SKIPPING: ${result.details.first}';
        captureOutput ? print(message) : print(Colorize(message)..darkGray());
      }
      results[entry] = result;
    }
    _currentPackageEntry = null;

    completeRun();

    print('\n');
    // If there were any errors reported, summarize them and exit.
    if (results.values
        .any((PackageResult result) => result.state == RunState.failed)) {
      _printFailureSummary(targetPackages, results);
      return false;
    }

    // Otherwise, print a summary of what ran for ease of auditing that all the
    // expected tests ran.
    _printRunSummary(targetPackages, results);

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
  void _printPackageHeading(PackageEnumerationEntry entry) {
    final String packageDisplayName = entry.package.displayName;
    String heading = entry.excluded
        ? 'Not running for $packageDisplayName; excluded'
        : 'Running for $packageDisplayName';
    if (hasLongOutput) {
      heading = '''

============================================================
|| $heading
============================================================
''';
    } else if (!entry.excluded) {
      heading = '$heading...';
    }
    if (captureOutput) {
      print(heading);
    } else {
      final Colorize colorizeHeading = Colorize(heading);
      print(
          entry.excluded ? colorizeHeading.darkGray() : colorizeHeading.cyan());
    }
  }

  /// Prints a summary of packges run, packages skipped, and warnings.
  void _printRunSummary(List<PackageEnumerationEntry> packages,
      Map<PackageEnumerationEntry, PackageResult> results) {
    final Set<PackageEnumerationEntry> skippedPackages = results.entries
        .where((MapEntry<PackageEnumerationEntry, PackageResult> entry) =>
            entry.value.state == RunState.skipped)
        .map((MapEntry<PackageEnumerationEntry, PackageResult> entry) =>
            entry.key)
        .toSet();
    final int skipCount = skippedPackages.length +
        packages
            .where((PackageEnumerationEntry package) => package.excluded)
            .length;
    // Split the warnings into those from packages that ran, and those that
    // were skipped.
    final Set<PackageEnumerationEntry> _skippedPackagesWithWarnings =
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
  void _printPerPackageRunOverview(
      List<PackageEnumerationEntry> packageEnumeration,
      {required Set<PackageEnumerationEntry> skipped}) {
    print('Run overview:');
    for (final PackageEnumerationEntry entry in packageEnumeration) {
      final bool hadWarning = _packagesWithWarnings.contains(entry);
      Styles style;
      String summary;
      if (entry.excluded) {
        summary = 'excluded';
        style = Styles.DARK_GRAY;
      } else if (skipped.contains(entry)) {
        summary = 'skipped';
        style = hadWarning ? Styles.LIGHT_YELLOW : Styles.DARK_GRAY;
      } else {
        summary = successSummaryMessage;
        style = hadWarning ? Styles.YELLOW : Styles.GREEN;
      }
      if (hadWarning) {
        summary += ' (with warning)';
      }

      if (!captureOutput) {
        summary = (Colorize(summary)..apply(style)).toString();
      }
      print('  ${entry.package.displayName} - $summary');
    }
    print('');
  }

  /// Prints a summary of all of the failures from [results].
  void _printFailureSummary(List<PackageEnumerationEntry> packageEnumeration,
      Map<PackageEnumerationEntry, PackageResult> results) {
    const String indentation = '  ';
    _printError(failureListHeader);
    for (final PackageEnumerationEntry entry in packageEnumeration) {
      final PackageResult result = results[entry]!;
      if (result.state == RunState.failed) {
        final String errorIndentation = indentation * 2;
        String errorDetails = '';
        if (result.details.isNotEmpty) {
          errorDetails =
              ':\n$errorIndentation${result.details.join('\n$errorIndentation')}';
        }
        _printError('$indentation${entry.package.displayName}$errorDetails');
      }
    }
    _printError(failureListFooter);
  }
}
