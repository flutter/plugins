// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

import 'common.dart';

class BuildExamplesCommand extends PluginCommand {
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
    final Map<String, bool> platforms = {
      for (final String platform in platformSwitches)
        platform: argResults[platform] as bool
    };
    if (!platforms.values.any((bool enabled) => enabled)) {
      print(
          'None of ${platformSwitches.map((String platform) => '--$platform').join(', ')} '
          'were specified, so not building anything.');
      return;
    }
    final String flutterCommand =
        LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';

    final String enableExperiment = argResults[kEnableExperiment] as String;

    checkSharding();
    final List<String> failingPackages = <String>[];
    await for (Directory plugin in getPlugins()) {
      for (Directory example in getExamplesForPlugin(plugin)) {
        final String packageName =
            p.relative(example.path, from: packagesDir.path);

        if (platforms[kLinux]) {
          print('\nBUILDING Linux for $packageName');
          if (isLinuxPlugin(plugin, fileSystem)) {
            int buildExitCode = await processRunner.runAndStream(
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

        if (platforms[kMacos]) {
          print('\nBUILDING macOS for $packageName');
          if (isMacOsPlugin(plugin, fileSystem)) {
            int exitCode = await processRunner.runAndStream(
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

        if (platforms[kWeb]) {
          print('\nBUILDING web for $packageName');
          if (isWebPlugin(plugin, fileSystem)) {
            int buildExitCode = await processRunner.runAndStream(
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

        if (platforms[kWindows]) {
          print('\nBUILDING Windows for $packageName');
          if (isWindowsPlugin(plugin, fileSystem)) {
            int buildExitCode = await processRunner.runAndStream(
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

        if (platforms[kIpa]) {
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

        if (platforms[kApk]) {
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
      for (String package in failingPackages) {
        print(' * $package');
      }
      throw ToolExit(1);
    }

    print('All builds successful!');
  }
}
