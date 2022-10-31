// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/create_all_packages_app_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late CreateAllPackagesAppCommand command;
  late FileSystem fileSystem;
  late Directory testRoot;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;

  setUp(() {
    // Since the core of this command is a call to 'flutter create', the test
    // has to use the real filesystem. Put everything possible in a unique
    // temporary to minimize effect on the host system.
    fileSystem = const LocalFileSystem();
    testRoot = fileSystem.systemTempDirectory.createTempSync();
    packagesDir = testRoot.childDirectory('packages');
    processRunner = RecordingProcessRunner();

    command = CreateAllPackagesAppCommand(
      packagesDir,
      processRunner: processRunner,
      pluginsRoot: testRoot,
    );
    runner = CommandRunner<void>(
        'create_all_test', 'Test for $CreateAllPackagesAppCommand');
    runner.addCommand(command);
  });

  tearDown(() {
    testRoot.deleteSync(recursive: true);
  });

  group('non-macOS host', () {
    setUp(() {
      command = CreateAllPackagesAppCommand(
        packagesDir,
        processRunner: processRunner,
        // Set isWindows or not based on the actual host, so that
        // `flutterCommand` works, since these tests actually call 'flutter'.
        // The important thing is that isMacOS always returns false.
        platform: MockPlatform(isWindows: const LocalPlatform().isWindows),
        pluginsRoot: testRoot,
      );
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPackagesAppCommand');
      runner.addCommand(command);
    });

    test('pubspec includes all plugins', () async {
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> pubspec = command.app.pubspecFile.readAsLinesSync();

      expect(
          pubspec,
          containsAll(<Matcher>[
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec has overrides for all plugins', () async {
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> pubspec = command.app.pubspecFile.readAsLinesSync();

      expect(
          pubspec,
          containsAllInOrder(<Matcher>[
            contains('dependency_overrides:'),
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec preserves existing Dart SDK version', () async {
      const String baselineProjectName = 'baseline';
      final Directory baselineProjectDirectory =
          testRoot.childDirectory(baselineProjectName);
      io.Process.runSync(
        getFlutterCommand(const LocalPlatform()),
        <String>[
          'create',
          '--template=app',
          '--project-name=$baselineProjectName',
          baselineProjectDirectory.path,
        ],
      );
      final Pubspec baselinePubspec =
          RepositoryPackage(baselineProjectDirectory).parsePubspec();

      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final Pubspec generatedPubspec = command.app.parsePubspec();

      const String dartSdkKey = 'sdk';
      expect(generatedPubspec.environment?[dartSdkKey],
          baselinePubspec.environment?[dartSdkKey]);
    });

    test('macOS deployment target is modified in pbxproj', () async {
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> pbxproj = command.app
          .platformDirectory(FlutterPlatform.macos)
          .childDirectory('Runner.xcodeproj')
          .childFile('project.pbxproj')
          .readAsLinesSync();

      expect(
          pbxproj,
          everyElement((String line) =>
              !line.contains('MACOSX_DEPLOYMENT_TARGET') ||
              line.contains('10.15')));
    });

    test('calls flutter pub get', () async {
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(const LocalPlatform()),
                const <String>['pub', 'get'],
                testRoot.childDirectory('all_packages').path),
          ]));
    },
        // See comment about Windows in create_all_packages_app_command.dart
        skip: io.Platform.isWindows);

    test('fails if flutter pub get fails', () async {
      createFakePlugin('plugina', packagesDir);

      processRunner.mockProcessesForExecutable[
          getFlutterCommand(const LocalPlatform())] = <io.Process>[
        MockProcess(exitCode: 1)
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['create-all-packages-app'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                "Failed to generate native build files via 'flutter pub get'"),
          ]));
    },
        // See comment about Windows in create_all_packages_app_command.dart
        skip: io.Platform.isWindows);

    test('handles --output-dir', () async {
      createFakePlugin('plugina', packagesDir);

      final Directory customOutputDir =
          fileSystem.systemTempDirectory.createTempSync();
      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--output-dir=${customOutputDir.path}'
      ]);

      expect(command.app.path,
          customOutputDir.childDirectory('all_packages').path);
    });

    test('logs exclusions', () async {
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      final List<String> output = await runCapturingPrint(runner,
          <String>['create-all-packages-app', '--exclude=pluginb,pluginc']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Exluding the following plugins from the combined build:',
            '  pluginb',
            '  pluginc',
          ]));
    });
  });

  group('macOS host', () {
    setUp(() {
      command = CreateAllPackagesAppCommand(
        packagesDir,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
        pluginsRoot: testRoot,
      );
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPackagesAppCommand');
      runner.addCommand(command);
    });

    test('macOS deployment target is modified in Podfile', () async {
      createFakePlugin('plugina', packagesDir);

      final File podfileFile = RepositoryPackage(
              command.packagesDir.parent.childDirectory('all_packages'))
          .platformDirectory(FlutterPlatform.macos)
          .childFile('Podfile');
      podfileFile.createSync(recursive: true);
      podfileFile.writeAsStringSync("""
platform :osx, '10.11'
# some other line
""");

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> podfile = command.app
          .platformDirectory(FlutterPlatform.macos)
          .childFile('Podfile')
          .readAsLinesSync();

      expect(
          podfile,
          everyElement((String line) =>
              !line.contains('platform :osx') || line.contains("'10.15'")));
    },
        // Podfile is only generated (and thus only edited) on macOS.
        skip: !io.Platform.isMacOS);
  });
}
