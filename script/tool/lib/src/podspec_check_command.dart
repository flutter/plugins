// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

const int _exitUnsupportedPlatform = 2;
const int _exitPodNotInstalled = 3;

/// Lint the CocoaPod podspecs and run unit tests.
///
/// See https://guides.cocoapods.org/terminal/commands.html#pod_lib_lint.
class PodspecCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the linter command.
  PodspecCheckCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform);

  @override
  final String name = 'podspec-check';

  @override
  List<String> get aliases => <String>['podspec', 'podspecs'];

  @override
  final String description =
      'Runs "pod lib lint" on all iOS and macOS plugin podspecs, as well as '
      'making sure the podspecs follow repository standards.\n\n'
      'This command requires "pod" and "flutter" to be in your path. Runs on macOS only.';

  @override
  Future<void> initializeRun() async {
    if (!platform.isMacOS) {
      printError('This command is only supported on macOS');
      throw ToolExit(_exitUnsupportedPlatform);
    }

    final ProcessResult result = await processRunner.run(
      'which',
      <String>['pod'],
      workingDir: packagesDir,
      logOnError: true,
    );
    if (result.exitCode != 0) {
      printError('Unable to find "pod". Make sure it is in your path.');
      throw ToolExit(_exitPodNotInstalled);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> errors = <String>[];

    final List<File> podspecs = await _podspecsToLint(package);
    if (podspecs.isEmpty) {
      return PackageResult.skip('No podspecs.');
    }

    for (final File podspec in podspecs) {
      if (!await _lintPodspec(podspec)) {
        errors.add(podspec.basename);
      }
    }

    if (await _hasIOSSwiftCode(package)) {
      print('iOS Swift code found, checking for search paths settings...');
      for (final File podspec in podspecs) {
        if (_isPodspecMissingSearchPaths(podspec)) {
          const String workaroundBlock = r'''
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
''';
          final String path =
              getRelativePosixPath(podspec, from: package.directory);
          printError('$path is missing seach path configuration. Any iOS '
              'plugin implementation that contains Swift implementation code '
              'needs to contain the following:\n\n'
              '$workaroundBlock\n'
              'For more details, see https://github.com/flutter/flutter/issues/118418.');
          errors.add(podspec.basename);
        }
      }
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  Future<List<File>> _podspecsToLint(RepositoryPackage package) async {
    final List<File> podspecs =
        await getFilesForPackage(package).where((File entity) {
      final String filePath = entity.path;
      return path.extension(filePath) == '.podspec';
    }).toList();

    podspecs.sort((File a, File b) => a.basename.compareTo(b.basename));
    return podspecs;
  }

  Future<bool> _lintPodspec(File podspec) async {
    // Do not run the static analyzer on plugins with known analyzer issues.
    final String podspecPath = podspec.path;

    final String podspecBasename = podspec.basename;
    print('Linting $podspecBasename');

    // Lint plugin as framework (use_frameworks!).
    final ProcessResult frameworkResult =
        await _runPodLint(podspecPath, libraryLint: true);
    print(frameworkResult.stdout);
    print(frameworkResult.stderr);

    // Lint plugin as library.
    final ProcessResult libraryResult =
        await _runPodLint(podspecPath, libraryLint: false);
    print(libraryResult.stdout);
    print(libraryResult.stderr);

    return frameworkResult.exitCode == 0 && libraryResult.exitCode == 0;
  }

  Future<ProcessResult> _runPodLint(String podspecPath,
      {required bool libraryLint}) async {
    final List<String> arguments = <String>[
      'lib',
      'lint',
      podspecPath,
      '--configuration=Debug', // Release targets unsupported arm64 simulators. Use Debug to only build against targeted x86_64 simulator devices.
      '--skip-tests',
      '--use-modular-headers', // Flutter sets use_modular_headers! in its templates.
      if (libraryLint) '--use-libraries'
    ];

    print('Running "pod ${arguments.join(' ')}"');
    return processRunner.run('pod', arguments,
        workingDir: packagesDir, stdoutEncoding: utf8, stderrEncoding: utf8);
  }

  /// Returns true if there is any iOS plugin implementation code written in
  /// Swift.
  Future<bool> _hasIOSSwiftCode(RepositoryPackage package) async {
    return getFilesForPackage(package).any((File entity) {
      final String relativePath =
          getRelativePosixPath(entity, from: package.directory);
      // Ignore example code.
      if (relativePath.startsWith('example/')) {
        return false;
      }
      final String filePath = entity.path;
      return path.extension(filePath) == '.swift';
    });
  }

  /// Returns true if [podspec] could apply to iOS, but does not have the
  /// workaround for search paths that makes Swift plugins build correctly in
  /// Objective-C applications. See
  /// https://github.com/flutter/flutter/issues/118418 for context and details.
  ///
  /// This does not check that the plugin has Swift code, and thus whether the
  /// workaround is needed, only whether or not it is there.
  bool _isPodspecMissingSearchPaths(File podspec) {
    final String directory = podspec.parent.basename;
    // All macOS Flutter apps are Swift, so macOS-only podspecs don't need the
    // workaround. If it's anywhere other than macos/, err or the side of
    // assuming it's required.
    if (directory == 'macos') {
      return false;
    }

    // This errs on the side of being too strict, to minimize the chance of
    // accidental incorrect configuration. If we ever need more flexibility
    // due to a false negative we can adjust this as necessary.
    final RegExp workaround = RegExp(r'''
\s*s\.(?:ios\.)?xcconfig = {[^}]*
\s*'LIBRARY_SEARCH_PATHS' => '\$\(TOOLCHAIN_DIR\)/usr/lib/swift/\$\(PLATFORM_NAME\)/ \$\(SDKROOT\)/usr/lib/swift',
\s*'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',[^}]*
\s*}''', dotAll: true);
    return !workaround.hasMatch(podspec.readAsStringSync());
  }
}
