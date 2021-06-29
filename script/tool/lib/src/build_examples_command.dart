// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/plugin_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

/// Key for IPA.
const String kIpa = 'ipa';

/// Key for APK.
const String kApk = 'apk';

/// A command to build the example applications for packages.
class BuildExamplesCommand extends PluginCommand {
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
  Future<void> run() async {
    final List<String> platformSwitches = <String>[
      kApk,
      kIpa,
      kPlatformLinux,
      kPlatformMacos,
      kPlatformWeb,
      kPlatformWindows,
    ];
    if (!platformSwitches.any((String platform) => getBoolArg(platform))) {
      print(
          'None of ${platformSwitches.map((String platform) => '--$platform').join(', ')} '
          'were specified, so not building anything.');
      return;
    }
    final String flutterCommand =
        const LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    final String enableExperiment = getStringArg(kEnableExperiment);

    final List<String> failingPackages = <String>[];
    await for (final Directory plugin in getPlugins()) {
      for (final Directory example in getExamplesForPlugin(plugin)) {
        final String packageName =
            p.relative(example.path, from: packagesDir.path);

        if (getBoolArg(kPlatformLinux)) {
          print('\nBUILDING Linux for $packageName');
          if (isLinuxPlugin(plugin)) {
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
              failingPackages.add('$packageName (linux)');
            }
          } else {
            print('Linux is not supported by this plugin');
          }
        }

        if (getBoolArg(kPlatformMacos)) {
          print('\nBUILDING macOS for $packageName');
          if (isMacOsPlugin(plugin)) {
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
              failingPackages.add('$packageName (macos)');
            }
          } else {
            print('macOS is not supported by this plugin');
          }
        }

        if (getBoolArg(kPlatformWeb)) {
          print('\nBUILDING web for $packageName');
          if (isWebPlugin(plugin)) {
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
              failingPackages.add('$packageName (web)');
            }
          } else {
            print('Web is not supported by this plugin');
          }
        }

        if (getBoolArg(kPlatformWindows)) {
          print('\nBUILDING Windows for $packageName');
          if (isWindowsPlugin(plugin)) {
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
              failingPackages.add('$packageName (windows)');
            }
          } else {
            print('Windows is not supported by this plugin');
          }
        }

        if (getBoolArg(kIpa)) {
          print('\nBUILDING IPA for $packageName');
          if (isIosPlugin(plugin)) {
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
              failingPackages.add('$packageName (ipa)');
            }
          } else {
            print('iOS is not supported by this plugin');
          }
        }

        if (getBoolArg(kApk)) {
          print('\nBUILDING APK for $packageName');
          if (isAndroidPlugin(plugin)) {
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
              failingPackages.add('$packageName (apk)');
            }
          } else {
            print('Android is not supported by this plugin');
          }
        }
      }
    }
    print('\n\n');

    if (failingPackages.isNotEmpty) {
      print('The following build are failing (see above for details):');
      for (final String package in failingPackages) {
        print(' * $package');
      }
      throw ToolExit(1);
    }

    print('All builds successful!');
  }
}
