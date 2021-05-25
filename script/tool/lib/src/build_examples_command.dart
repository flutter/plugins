// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common.dart';

/// A command to build the example applications for packages.
class BuildExamplesCommand extends PluginCommand {
  /// Creates an instance of the build command.
  BuildExamplesCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addFlag(kLinux, defaultsTo: false);
    argParser.addFlag(kMacos, defaultsTo: false);
    argParser.addFlag(kWeb, defaultsTo: false);
    argParser.addFlag(kWindows, defaultsTo: false);
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
      kLinux,
      kMacos,
      kWeb,
      kWindows,
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

        if (getBoolArg(kLinux)) {
          print('\nBUILDING Linux for $packageName');
          if (isLinuxPlugin(plugin, fileSystem)) {
            final int buildExitCode = await processRunner.runAndStream(
                flutterCommand,
                <String>[
                  'build',
                  kLinux,
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

        if (getBoolArg(kMacos)) {
          print('\nBUILDING macOS for $packageName');
          if (isMacOsPlugin(plugin, fileSystem)) {
            final int exitCode = await processRunner.runAndStream(
                flutterCommand,
                <String>[
                  'build',
                  kMacos,
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

        if (getBoolArg(kWeb)) {
          print('\nBUILDING web for $packageName');
          if (isWebPlugin(plugin, fileSystem)) {
            final int buildExitCode = await processRunner.runAndStream(
                flutterCommand,
                <String>[
                  'build',
                  kWeb,
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

        if (getBoolArg(kWindows)) {
          print('\nBUILDING Windows for $packageName');
          if (isWindowsPlugin(plugin, fileSystem)) {
            final int buildExitCode = await processRunner.runAndStream(
                flutterCommand,
                <String>[
                  'build',
                  kWindows,
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
          if (isIosPlugin(plugin, fileSystem)) {
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
          if (isAndroidPlugin(plugin, fileSystem)) {
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
