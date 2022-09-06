// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

const int _exitNoPlatformFlags = 2;
const int _exitNoAvailableDevice = 3;

/// A command to run the example applications for packages via Flutter driver.
class DriveExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the drive command.
  DriveExamplesCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addFlag(platformAndroid,
        help: 'Runs the Android implementation of the examples');
    argParser.addFlag(platformIOS,
        help: 'Runs the iOS implementation of the examples');
    argParser.addFlag(platformLinux,
        help: 'Runs the Linux implementation of the examples');
    argParser.addFlag(platformMacOS,
        help: 'Runs the macOS implementation of the examples');
    argParser.addFlag(platformWeb,
        help: 'Runs the web implementation of the examples');
    argParser.addFlag(platformWindows,
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
      'For each *_test.dart in test_driver/ it drives an application with '
      'either the corresponding test in test_driver (for example, '
      'test_driver/app_test.dart would match test_driver/app.dart), or the '
      '*_test.dart files in integration_test/.\n\n'
      'This command requires "flutter" to be in your path.';

  Map<String, List<String>> _targetDeviceFlags = const <String, List<String>>{};

  @override
  Future<void> initializeRun() async {
    final List<String> platformSwitches = <String>[
      platformAndroid,
      platformIOS,
      platformLinux,
      platformMacOS,
      platformWeb,
      platformWindows,
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
    if (getBoolArg(platformAndroid)) {
      final List<String> devices = await _getDevicesForPlatform('android');
      if (devices.isEmpty) {
        printError('No Android devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      androidDevice = devices.first;
    }

    String? iOSDevice;
    if (getBoolArg(platformIOS)) {
      final List<String> devices = await _getDevicesForPlatform('ios');
      if (devices.isEmpty) {
        printError('No iOS devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      iOSDevice = devices.first;
    }

    _targetDeviceFlags = <String, List<String>>{
      if (getBoolArg(platformAndroid))
        platformAndroid: <String>['-d', androidDevice!],
      if (getBoolArg(platformIOS)) platformIOS: <String>['-d', iOSDevice!],
      if (getBoolArg(platformLinux)) platformLinux: <String>['-d', 'linux'],
      if (getBoolArg(platformMacOS)) platformMacOS: <String>['-d', 'macos'],
      if (getBoolArg(platformWeb))
        platformWeb: <String>[
          '-d',
          'web-server',
          '--web-port=7357',
          '--browser-name=chrome',
          if (platform.environment.containsKey('CHROME_EXECUTABLE'))
            '--chrome-binary=${platform.environment['CHROME_EXECUTABLE']}',
        ],
      if (getBoolArg(platformWindows))
        platformWindows: <String>['-d', 'windows'],
    };
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final bool isPlugin = isFlutterPlugin(package);

    if (package.isPlatformInterface && package.getExamples().isEmpty) {
      // Platform interface packages generally aren't intended to have
      // examples, and don't need integration tests, so skip rather than fail.
      return PackageResult.skip(
          'Platform interfaces are not expected to have integration tests.');
    }

    // For plugin packages, skip if the plugin itself doesn't support any
    // requested platform(s).
    if (isPlugin) {
      final Iterable<String> requestedPlatforms = _targetDeviceFlags.keys;
      final Iterable<String> unsupportedPlatforms = requestedPlatforms.where(
          (String platform) => !pluginSupportsPlatform(platform, package));
      for (final String platform in unsupportedPlatforms) {
        print('Skipping unsupported platform $platform...');
      }
      if (unsupportedPlatforms.length == requestedPlatforms.length) {
        return PackageResult.skip(
            '${package.displayName} does not support any requested platform.');
      }
    }

    int examplesFound = 0;
    int supportedExamplesFound = 0;
    bool testsRan = false;
    final List<String> errors = <String>[];
    for (final RepositoryPackage example in package.getExamples()) {
      ++examplesFound;
      final String exampleName =
          getRelativePosixPath(example.directory, from: packagesDir);

      // Skip examples that don't support any requested platform(s).
      final List<String> deviceFlags = _deviceFlagsForExample(example);
      if (deviceFlags.isEmpty) {
        print(
            'Skipping $exampleName; does not support any requested platforms.');
        continue;
      }
      ++supportedExamplesFound;

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
          for (final File testFile in await _getIntegrationTests(example)) {
            // Check files for known problematic patterns.
            final bool passesValidation = _validateIntegrationTest(testFile);
            if (!passesValidation) {
              // Report the issue, but continue with the test as the validation
              // errors don't prevent running.
              errors.add('${testFile.basename} failed validation');
            }
            testTargets.add(testFile);
          }
        }

        if (testTargets.isEmpty) {
          final String driverRelativePath =
              getRelativePosixPath(driver, from: package.directory);
          printError(
              'Found $driverRelativePath, but no integration_test/*_test.dart files.');
          errors.add('No test files for $driverRelativePath');
          continue;
        }

        testsRan = true;
        final List<File> failingTargets = await _driveTests(
            example, driver, testTargets,
            deviceFlags: deviceFlags);
        for (final File failingTarget in failingTargets) {
          errors.add(
              getRelativePosixPath(failingTarget, from: package.directory));
        }
      }
    }
    if (!testsRan) {
      // It is an error for a plugin not to have integration tests, because that
      // is the only way to test the method channel communication.
      if (isPlugin) {
        printError(
            'No driver tests were run ($examplesFound example(s) found).');
        errors.add('No tests ran (use --exclude if this is intentional).');
      } else {
        return PackageResult.skip(supportedExamplesFound == 0
            ? 'No example supports requested platform(s).'
            : 'No example is configured for driver tests.');
      }
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  /// Returns the device flags for the intersection of the requested platforms
  /// and the platforms supported by [example].
  List<String> _deviceFlagsForExample(RepositoryPackage example) {
    final List<String> deviceFlags = <String>[];
    for (final MapEntry<String, List<String>> entry
        in _targetDeviceFlags.entries) {
      final String platform = entry.key;
      if (example.directory.childDirectory(platform).existsSync()) {
        deviceFlags.addAll(entry.value);
      } else {
        final String exampleName =
            getRelativePosixPath(example.directory, from: packagesDir);
        print('Skipping unsupported platform $platform for $exampleName');
      }
    }
    return deviceFlags;
  }

  Future<List<String>> _getDevicesForPlatform(String platform) async {
    final List<String> deviceIds = <String>[];

    final ProcessResult result = await processRunner.run(
        flutterCommand, <String>['devices', '--machine'],
        stdoutEncoding: utf8);
    if (result.exitCode != 0) {
      return deviceIds;
    }

    String output = result.stdout as String;
    // --machine doesn't currently prevent the tool from printing banners;
    // see https://github.com/flutter/flutter/issues/86055. This workaround
    // can be removed once that is fixed.
    output = output.substring(output.indexOf('['));

    final List<Map<String, dynamic>> devices =
        (jsonDecode(output) as List<dynamic>).cast<Map<String, dynamic>>();
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

  Future<List<File>> _getDrivers(RepositoryPackage example) async {
    final List<File> drivers = <File>[];

    final Directory driverDir = example.directory.childDirectory('test_driver');
    if (driverDir.existsSync()) {
      await for (final FileSystemEntity driver in driverDir.list()) {
        if (driver is File && driver.basename.endsWith('_test.dart')) {
          drivers.add(driver);
        }
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

  Future<List<File>> _getIntegrationTests(RepositoryPackage example) async {
    final List<File> tests = <File>[];
    final Directory integrationTestDir =
        example.directory.childDirectory('integration_test');

    if (integrationTestDir.existsSync()) {
      await for (final FileSystemEntity file in integrationTestDir.list()) {
        if (file is File && file.basename.endsWith('_test.dart')) {
          tests.add(file);
        }
      }
    }
    return tests;
  }

  /// Checks [testFile] for known bad patterns in integration tests, logging
  /// any issues.
  ///
  /// Returns true if the file passes validation without issues.
  bool _validateIntegrationTest(File testFile) {
    final List<String> lines = testFile.readAsLinesSync();

    final RegExp badTestPattern = RegExp(r'\s*test\(');
    if (lines.any((String line) => line.startsWith(badTestPattern))) {
      final String filename = testFile.basename;
      printError(
          '$filename uses "test", which will not report failures correctly. '
          'Use testWidgets instead.');
      return false;
    }

    return true;
  }

  /// For each file in [targets], uses
  /// `flutter drive --driver [driver] --target <target>`
  /// to drive [example], returning a list of any failing test targets.
  ///
  /// [deviceFlags] should contain the flags to run the test on a specific
  /// target device (plus any supporting device-specific flags). E.g.:
  ///   - `['-d', 'macos']` for driving for macOS.
  ///   - `['-d', 'web-server', '--web-port=<port>', '--browser-name=<browser>]`
  ///     for web
  Future<List<File>> _driveTests(
    RepositoryPackage example,
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
            getRelativePosixPath(driver, from: example.directory),
            '--target',
            getRelativePosixPath(target, from: example.directory),
          ],
          workingDir: example.directory);
      if (exitCode != 0) {
        failures.add(target);
      }
    }
    return failures;
  }
}
