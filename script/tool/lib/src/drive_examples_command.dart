// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';

const int _exitNoPlatformFlags = 2;
const int _exitNoAvailableDevice = 3;

/// A command to run the example applications for packages via Flutter driver.
class DriveExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the drive command.
  DriveExamplesCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
  }) : super(packagesDir, processRunner: processRunner) {
    argParser.addFlag(kPlatformAndroid,
        help: 'Runs the Android implementation of the examples');
    argParser.addFlag(kPlatformIos,
        help: 'Runs the iOS implementation of the examples');
    argParser.addFlag(kPlatformLinux,
        help: 'Runs the Linux implementation of the examples');
    argParser.addFlag(kPlatformMacos,
        help: 'Runs the macOS implementation of the examples');
    argParser.addFlag(kPlatformWeb,
        help: 'Runs the web implementation of the examples');
    argParser.addFlag(kPlatformWindows,
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
      'For each *_test.dart in test_driver/ it drives an application with the '
      'either the corresponding test in test_driver (for example, '
      'test_driver/app_test.dart would match test_driver/app.dart), or the '
      '*_test.dart files in integration_test/.\n\n'
      'This command requires "flutter" to be in your path.';

  Map<String, List<String>> _targetDeviceFlags = const <String, List<String>>{};

  @override
  Future<void> initializeRun() async {
    final List<String> platformSwitches = <String>[
      kPlatformAndroid,
      kPlatformIos,
      kPlatformLinux,
      kPlatformMacos,
      kPlatformWeb,
      kPlatformWindows,
    ];
    final int platformCount = platformSwitches
        .where((String platform) => getBoolArg(platform))
        .length;
    // The flutter tool currently doesn't accept multiple device arguments:
    // https://github.com/flutter/flutter/issues/35733
    // If that is implemented, this check can be relaxed.
    if (platformCount != 1) {
      printError(
          'Exactly one of ${platformSwitches.map((String platform) => '--$platform').join(', ')} '
          'must be specified.');
      throw ToolExit(_exitNoPlatformFlags);
    }

    String? androidDevice;
    if (getBoolArg(kPlatformAndroid)) {
      final List<String> devices = await _getDevicesForPlatform('android');
      if (devices.isEmpty) {
        printError('No Android devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      androidDevice = devices.first;
    }

    String? iosDevice;
    if (getBoolArg(kPlatformIos)) {
      final List<String> devices = await _getDevicesForPlatform('ios');
      if (devices.isEmpty) {
        printError('No iOS devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      iosDevice = devices.first;
    }

    _targetDeviceFlags = <String, List<String>>{
      if (getBoolArg(kPlatformAndroid))
        kPlatformAndroid: <String>['-d', androidDevice!],
      if (getBoolArg(kPlatformIos)) kPlatformIos: <String>['-d', iosDevice!],
      if (getBoolArg(kPlatformLinux)) kPlatformLinux: <String>['-d', 'linux'],
      if (getBoolArg(kPlatformMacos)) kPlatformMacos: <String>['-d', 'macos'],
      if (getBoolArg(kPlatformWeb))
        kPlatformWeb: <String>[
          '-d',
          'web-server',
          '--web-port=7357',
          '--browser-name=chrome'
        ],
      if (getBoolArg(kPlatformWindows))
        kPlatformWindows: <String>['-d', 'windows'],
    };
  }

  @override
  Future<List<String>> runForPackage(Directory package) async {
    if (package.basename.endsWith('_platform_interface') &&
        !package.childDirectory('example').existsSync()) {
      // Platform interface packages generally aren't intended to have
      // examples, and don't need integration tests, so skip rather than fail.
      printSkip(
          'Platform interfaces are not expected to have integratino tests.');
      return PackageLoopingCommand.success;
    }

    final List<String> deviceFlags = <String>[];
    for (final MapEntry<String, List<String>> entry
        in _targetDeviceFlags.entries) {
      if (pluginSupportsPlatform(entry.key, package)) {
        deviceFlags.addAll(entry.value);
      } else {
        print('Skipping unsupported platform ${entry.key}...');
      }
    }
    // If there is no supported target platform, skip the plugin.
    if (deviceFlags.isEmpty) {
      printSkip(
          '${getPackageDescription(package)} does not support any requested platform.');
      return PackageLoopingCommand.success;
    }

    int examplesFound = 0;
    bool testsRan = false;
    final List<String> errors = <String>[];
    for (final Directory example in getExamplesForPlugin(package)) {
      ++examplesFound;
      final String exampleName =
          p.relative(example.path, from: packagesDir.path);

      final List<File> drivers = await _getDrivers(example);
      if (drivers.isEmpty) {
        print('No driver tests found for $exampleName');
        continue;
      }

      for (final File driver in drivers) {
        final List<File> testTargets = <File>[];

        // Try to find a matching app to drive without the _test.dart
        // TODO(stuartmorgan): Migrate all remaining uses of this legacy
        // approach (currently only video_player) and remove support for it:
        // https://github.com/flutter/flutter/issues/85224.
        final File? legacyTestFile = _getLegacyTestFileForTestDriver(driver);
        if (legacyTestFile != null) {
          testTargets.add(legacyTestFile);
        } else {
          (await _getIntegrationTests(example)).forEach(testTargets.add);
        }

        if (testTargets.isEmpty) {
          final String driverRelativePath =
              p.relative(driver.path, from: package.path);
          printError(
              'Found $driverRelativePath, but no integration_test/*_test.dart files.');
          errors.add(
              'No test files for ${p.relative(driver.path, from: package.path)}');
          continue;
        }

        testsRan = true;
        final List<File> failingTargets = await _driveTests(
            example, driver, testTargets,
            deviceFlags: deviceFlags);
        for (final File failingTarget in failingTargets) {
          errors.add(p.relative(failingTarget.path, from: package.path));
        }
      }
    }
    if (!testsRan) {
      printError('No driver tests were run ($examplesFound examples found).');
      errors.add('No tests ran (use --exclude if this is intentional).');
    }
    return errors;
  }

  Future<List<String>> _getDevicesForPlatform(String platform) async {
    final List<String> deviceIds = <String>[];

    final ProcessResult result = await processRunner.run(
        flutterCommand, <String>['devices', '--machine'],
        stdoutEncoding: utf8, exitOnError: true);
    if (result.exitCode != 0) {
      return deviceIds;
    }

    final List<Map<String, dynamic>> devices =
        (jsonDecode(result.stdout as String) as List<dynamic>)
            .cast<Map<String, dynamic>>();
    for (final Map<String, dynamic> deviceInfo in devices) {
      final String targetPlatform =
          (deviceInfo['targetPlatform'] as String?) ?? '';
      if (targetPlatform.startsWith(platform)) {
        final String? deviceId = deviceInfo['id'] as String?;
        if (deviceId != null) {
          deviceIds.add(deviceId);
        }
      }
    }
    return deviceIds;
  }

  Future<List<File>> _getDrivers(Directory example) async {
    final List<File> drivers = <File>[];

    final Directory driverDir = example.childDirectory('test_driver');
    await for (final FileSystemEntity driver in driverDir.list()) {
      if (driver is File && driver.basename.endsWith('_test.dart')) {
        drivers.add(driver);
      }
    }
    return drivers;
  }

  File? _getLegacyTestFileForTestDriver(File testDriver) {
    final String testName = testDriver.basename.replaceAll(
      RegExp(r'_test.dart$'),
      '.dart',
    );
    final File testFile = testDriver.parent.childFile(testName);

    return testFile.existsSync() ? testFile : null;
  }

  Future<List<File>> _getIntegrationTests(Directory example) async {
    final List<File> tests = <File>[];
    final Directory integrationTestDir =
        example.childDirectory('integration_test');

    if (integrationTestDir.existsSync()) {
      await for (final FileSystemEntity file in integrationTestDir.list()) {
        if (file is File && file.basename.endsWith('_test.dart')) {
          tests.add(file);
        }
      }
    }
    return tests;
  }

  /// Runs each file from [targets] using `flutter drive`, returning a list of
  /// any failing test targets.
  Future<List<File>> _driveTests(
    Directory example,
    File driver,
    List<File> targets, {
    required List<String> deviceFlags,
  }) async {
    final List<File> failures = <File>[];

    final String enableExperiment = getStringArg(kEnableExperiment);

    for (final File target in targets) {
      final int exitCode = await processRunner.runAndStream(
          flutterCommand,
          <String>[
            'drive',
            ...deviceFlags,
            if (enableExperiment.isNotEmpty)
              '--enable-experiment=$enableExperiment',
            '--driver',
            p.relative(driver.path, from: example.path),
            '--target',
            p.relative(target.path, from: example.path),
          ],
          workingDir: example,
          exitOnError: true);
      if (exitCode != 0) {
        failures.add(target);
      }
    }
    return failures;
  }
}
