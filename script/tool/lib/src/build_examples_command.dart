// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

/// Key for APK.
const String _platformFlagApk = 'apk';

const int _exitNoPlatformFlags = 2;

/// A command to build the example applications for packages.
class BuildExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the build command.
  BuildExamplesCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addFlag(kPlatformLinux);
    argParser.addFlag(kPlatformMacos);
    argParser.addFlag(kPlatformWeb);
    argParser.addFlag(kPlatformWindows);
    argParser.addFlag(kPlatformIos);
    argParser.addFlag(_platformFlagApk);
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
      _platformFlagApk,
      kPlatformIos,
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
    final List<String> errors = <String>[];

    for (final Directory example in getExamplesForPlugin(package)) {
      final String packageName =
          p.relative(example.path, from: packagesDir.path);

      if (getBoolArg(kPlatformLinux)) {
        print('\nBUILDING $packageName for Linux');
        if (isLinuxPlugin(package)) {
          if (!await _buildExample(example, kPlatformLinux)) {
            errors.add('$packageName (Linux)');
          }
        } else {
          printSkip('Linux is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformMacos)) {
        print('\nBUILDING $packageName for macOS');
        if (isMacOsPlugin(package)) {
          if (!await _buildExample(example, kPlatformMacos)) {
            errors.add('$packageName (macOS)');
          }
        } else {
          printSkip('macOS is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformWeb)) {
        print('\nBUILDING $packageName for web');
        if (isWebPlugin(package)) {
          if (!await _buildExample(example, kPlatformWeb)) {
            errors.add('$packageName (web)');
          }
        } else {
          printSkip('Web is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformWindows)) {
        print('\nBUILDING $packageName for Windows');
        if (isWindowsPlugin(package)) {
          if (!await _buildExample(example, kPlatformWindows)) {
            errors.add('$packageName (Windows)');
          }
        } else {
          printSkip('Windows is not supported by this plugin');
        }
      }

      if (getBoolArg(kPlatformIos)) {
        print('\nBUILDING $packageName for iOS');
        if (isIosPlugin(package)) {
          if (!await _buildExample(
            example,
            kPlatformIos,
            extraBuildFlags: <String>['--no-codesign'],
          )) {
            errors.add('$packageName (iOS)');
          }
        } else {
          printSkip('iOS is not supported by this plugin');
        }
      }

      if (getBoolArg(_platformFlagApk)) {
        print('\nBUILDING APK for $packageName');
        if (isAndroidPlugin(package)) {
          if (!await _buildExample(example, _platformFlagApk)) {
            errors.add('$packageName (apk)');
          }
        } else {
          printSkip('Android is not supported by this plugin');
        }
      }
    }

    return errors;
  }

  Future<bool> _buildExample(
    Directory example,
    String flutterBuildType, {
    List<String> extraBuildFlags = const <String>[],
  }) async {
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';
    final String enableExperiment = getStringArg(kEnableExperiment);

    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>[
        'build',
        flutterBuildType,
        ...extraBuildFlags,
        if (enableExperiment.isNotEmpty)
          '--enable-experiment=$enableExperiment',
      ],
      workingDir: example,
    );
    return exitCode == 0;
  }
}
