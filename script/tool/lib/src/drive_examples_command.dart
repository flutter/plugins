// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'common.dart';

class DriveExamplesCommand extends PluginCommand {
  DriveExamplesCommand(
    Directory packagesDir,
    FileSystem fileSystem, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, fileSystem, processRunner: processRunner) {
    argParser.addFlag(kAndroid,
        help: 'Runs the Android implementation of the examples');
    argParser.addFlag(kIos,
        help: 'Runs the iOS implementation of the examples');
    argParser.addFlag(kLinux,
        help: 'Runs the Linux implementation of the examples');
    argParser.addFlag(kMacos,
        help: 'Runs the macOS implementation of the examples');
    argParser.addFlag(kWeb,
        help: 'Runs the web implementation of the examples');
    argParser.addFlag(kWindows,
        help: 'Runs the Windows implementation of the examples');
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help:
          'Runs the driver tests in Dart VM with the given experiments enabled.',
    );
  }

  @override
  final String name = 'drive-examples';

  @override
  final String description = 'Runs driver tests for plugin example apps.\n\n'
      'For each *_test.dart in test_driver/ it drives an application with a '
      'corresponding name in the test/ or test_driver/ directories.\n\n'
      'For example, test_driver/app_test.dart would match test/app.dart.\n\n'
      'This command requires "flutter" to be in your path.\n\n'
      'If a file with a corresponding name cannot be found, this driver file'
      'will be used to drive the tests that match '
      'integration_test/*_test.dart.';

  @override
  Future<void> run() async {
    checkSharding();
    final List<String> failingTests = <String>[];
    final bool isLinux = argResults[kLinux] == true;
    final bool isMacos = argResults[kMacos] == true;
    final bool isWeb = argResults[kWeb] == true;
    final bool isWindows = argResults[kWindows] == true;
    await for (final Directory plugin in getPlugins()) {
      final String flutterCommand =
          LocalPlatform().isWindows ? 'flutter.bat' : 'flutter';
      for (final Directory example in getExamplesForPlugin(plugin)) {
        final String packageName =
            p.relative(example.path, from: packagesDir.path);
        if (!(await pluginSupportedOnCurrentPlatform(plugin, fileSystem))) {
          continue;
        }
        final Directory driverTests =
            fileSystem.directory(p.join(example.path, 'test_driver'));
        if (!driverTests.existsSync()) {
          // No driver tests available for this example
          continue;
        }
        // Look for driver tests ending in _test.dart in test_driver/
        await for (final FileSystemEntity test in driverTests.list()) {
          final String driverTestName =
              p.relative(test.path, from: driverTests.path);
          if (!driverTestName.endsWith('_test.dart')) {
            continue;
          }
          // Try to find a matching app to drive without the _test.dart
          final String deviceTestName = driverTestName.replaceAll(
            RegExp(r'_test.dart$'),
            '.dart',
          );
          String deviceTestPath = p.join('test', deviceTestName);
          if (!fileSystem
              .file(p.join(example.path, deviceTestPath))
              .existsSync()) {
            // If the app isn't in test/ folder, look in test_driver/ instead.
            deviceTestPath = p.join('test_driver', deviceTestName);
          }

          final List<String> targetPaths = <String>[];
          if (fileSystem
              .file(p.join(example.path, deviceTestPath))
              .existsSync()) {
            targetPaths.add(deviceTestPath);
          } else {
            final Directory integrationTests =
                fileSystem.directory(p.join(example.path, 'integration_test'));

            if (await integrationTests.exists()) {
              await for (final FileSystemEntity integration_test
                  in integrationTests.list()) {
                if (!integration_test.basename.endsWith('_test.dart')) {
                  continue;
                }
                targetPaths
                    .add(p.relative(integration_test.path, from: example.path));
              }
            }

            if (targetPaths.isEmpty) {
              print('''
Unable to infer a target application for $driverTestName to drive.
Tried searching for the following:
1. test/$deviceTestName
2. test_driver/$deviceTestName
3. test_driver/*_test.dart
''');
              failingTests.add(p.relative(test.path, from: example.path));
              continue;
            }
          }

          final List<String> driveArgs = <String>['drive'];

          final String enableExperiment =
              argResults[kEnableExperiment] as String;
          if (enableExperiment.isNotEmpty) {
            driveArgs.add('--enable-experiment=$enableExperiment');
          }

          if (isLinux && isLinuxPlugin(plugin, fileSystem)) {
            driveArgs.addAll(<String>[
              '-d',
              'linux',
            ]);
          }
          if (isMacos && isMacOsPlugin(plugin, fileSystem)) {
            driveArgs.addAll(<String>[
              '-d',
              'macos',
            ]);
          }
          if (isWeb && isWebPlugin(plugin, fileSystem)) {
            driveArgs.addAll(<String>[
              '-d',
              'web-server',
              '--web-port=7357',
              '--browser-name=chrome',
            ]);
          }
          if (isWindows && isWindowsPlugin(plugin, fileSystem)) {
            driveArgs.addAll(<String>[
              '-d',
              'windows',
            ]);
          }

          for (final targetPath in targetPaths) {
            final int exitCode = await processRunner.runAndStream(
                flutterCommand,
                [
                  ...driveArgs,
                  '--driver',
                  p.join('test_driver', driverTestName),
                  '--target',
                  targetPath,
                ],
                workingDir: example,
                exitOnError: true);
            if (exitCode != 0) {
              failingTests.add(p.join(packageName, deviceTestPath));
            }
          }
        }
      }
    }
    print('\n\n');

    if (failingTests.isNotEmpty) {
      print('The following driver tests are failing (see above for details):');
      for (final String test in failingTests) {
        print(' * $test');
      }
      throw ToolExit(1);
    }

    print('All driver tests successful!');
  }

  Future<bool> pluginSupportedOnCurrentPlatform(
      FileSystemEntity plugin, FileSystem fileSystem) async {
    final bool isAndroid = argResults[kAndroid] == true;
    final bool isIOS = argResults[kIos] == true;
    final bool isLinux = argResults[kLinux] == true;
    final bool isMacos = argResults[kMacos] == true;
    final bool isWeb = argResults[kWeb] == true;
    final bool isWindows = argResults[kWindows] == true;
    if (isAndroid) {
      return isAndroidPlugin(plugin, fileSystem);
    }
    if (isIOS) {
      return isIosPlugin(plugin, fileSystem);
    }
    if (isLinux) {
      return isLinuxPlugin(plugin, fileSystem);
    }
    if (isMacos) {
      return isMacOsPlugin(plugin, fileSystem);
    }
    if (isWeb) {
      return isWebPlugin(plugin, fileSystem);
    }
    if (isWindows) {
      return isWindowsPlugin(plugin, fileSystem);
    }
    // When we are here, no flags are specified. Only return true if the plugin
    // supports Android for legacy command support. TODO(cyanglaz): Make Android
    // flag also required like other platforms (breaking change).
    // https://github.com/flutter/flutter/issues/58285
    return isAndroidPlugin(plugin, fileSystem);
  }
}
