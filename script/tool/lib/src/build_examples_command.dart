// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

/// Key for IPA.
const String kIpa = 'ipa';

/// Key for APK.
const String kApk = 'apk';

const int _exitNoPlatformFlags = 2;

/// A command to build the example applications for packages.
class BuildExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the build command.
  BuildExamplesCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addFlag(kPlatformLinux, defaultsTo: false);
    argParser.addFlag(kPlatformMacos, defaultsTo: false);
    argParser.addFlag(kPlatformWeb, defaultsTo: false);
    argParser.addFlag(kPlatformWindows, defaultsTo: false);
    argParser.addFlag(kIpa, defaultsTo: io.Platform.isMacOS);
    argParser.addFlag(kApk);
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help: 'Enables the given Dart SDK experiments.',
    );
  }

  @override
  final String name = 'build-examples';

  @override
  final String description =
      'Builds all example apps (IPA for iOS and APK for Android).\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  Future<void> initializeRun() async {
    final List<String> platformSwitches = <String>[
      kApk,
      kIpa,
      kPlatformLinux,
      kPlatformMacos,
      kPlatformWeb,
      kPlatformWindows,
    ];
    if (!platformSwitches.any((String platform) => getBoolArg(platform))) {
      printError(
          'None of ${platformSwitches.map((String platform) => '--$platform').join(', ')} '
          'were specified. At least one platform must be provided.');
      throw ToolExit(_exitNoPlatformFlags);
    }
  }

  @override
  Future<List<String>> runForPackage(Directory package) async {
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    final String enableExperiment = getStringArg(kEnableExperiment);

    final List<String> errors = <String>[];

    for (final Directory example in getExamplesForPlugin(package)) {
      final String packageName =
          p.relative(example.path, from: packagesDir.path);

      if (getBoolArg(kPlatformLinux)) {
        print('\nBUILDING Linux for $packageName');
        if (isLinuxPlugin(package)) {
          final int buildExitCode = await processRunner.runAndStream(
              flutterCommand,
              <String>[
                'build',
                kPlatformLinux,
                if (enableExperiment.isNotEmpty)
                  '--enable-experiment=$enableExperiment',
              ],
              workingDir: example);
          if (buildExitCode != 0) {
            errors.add('$packageName (linux)');
          }
        } else {
          printSkip('Linux is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformMacos)) {
        print('\nBUILDING macOS for $packageName');
        if (isMacOsPlugin(package)) {
          final int exitCode = await processRunner.runAndStream(
              flutterCommand,
              <String>[
                'build',
                kPlatformMacos,
                if (enableExperiment.isNotEmpty)
                  '--enable-experiment=$enableExperiment',
              ],
              workingDir: example);
          if (exitCode != 0) {
            errors.add('$packageName (macos)');
          }
        } else {
          printSkip('macOS is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformWeb)) {
        print('\nBUILDING web for $packageName');
        if (isWebPlugin(package)) {
          final int buildExitCode = await processRunner.runAndStream(
              flutterCommand,
              <String>[
                'build',
                kPlatformWeb,
                if (enableExperiment.isNotEmpty)
                  '--enable-experiment=$enableExperiment',
              ],
              workingDir: example);
          if (buildExitCode != 0) {
            errors.add('$packageName (web)');
          }
        } else {
          printSkip('Web is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformWindows)) {
        print('\nBUILDING Windows for $packageName');
        if (isWindowsPlugin(package)) {
          final int buildExitCode = await processRunner.runAndStream(
              flutterCommand,
              <String>[
                'build',
                kPlatformWindows,
                if (enableExperiment.isNotEmpty)
                  '--enable-experiment=$enableExperiment',
              ],
              workingDir: example);
          if (buildExitCode != 0) {
            errors.add('$packageName (windows)');
          }
        } else {
          printSkip('Windows is not supported by this plugin');
        }
      }

      if (getBoolArg(kIpa)) {
        print('\nBUILDING IPA for $packageName');
        if (isIosPlugin(package)) {
          final int exitCode = await processRunner.runAndStream(
              flutterCommand,
              <String>[
                'build',
                'ios',
                '--no-codesign',
                if (enableExperiment.isNotEmpty)
                  '--enable-experiment=$enableExperiment',
              ],
              workingDir: example);
          if (exitCode != 0) {
            errors.add('$packageName (ipa)');
          }
        } else {
          printSkip('iOS is not supported by this plugin');
        }
      }

      if (getBoolArg(kApk)) {
        print('\nBUILDING APK for $packageName');
        if (isAndroidPlugin(package)) {
          final int exitCode = await processRunner.runAndStream(
              flutterCommand,
              <String>[
                'build',
                'apk',
                if (enableExperiment.isNotEmpty)
                  '--enable-experiment=$enableExperiment',
              ],
              workingDir: example);
          if (exitCode != 0) {
            errors.add('$packageName (apk)');
          }
        } else {
          printSkip('Android is not supported by this plugin');
        }
      }
    }

    return errors;
  }
}
