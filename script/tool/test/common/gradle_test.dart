// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/gradle.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../util.dart';

void main() {
  late FileSystem fileSystem;
  late RecordingProcessRunner processRunner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    processRunner = RecordingProcessRunner();
  });

  group('isConfigured', () {
    test('reports true when configured on Windows', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/gradlew.bat']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      expect(project.isConfigured(), true);
    });

    test('reports true when configured on non-Windows', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/gradlew']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      expect(project.isConfigured(), true);
    });

    test('reports false when not configured on Windows', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/foo']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      expect(project.isConfigured(), false);
    });

    test('reports true when configured on non-Windows', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/foo']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      expect(project.isConfigured(), false);
    });
  });

  group('runXcodeBuild', () {
    test('runs without arguments', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/gradlew']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      final int exitCode = await project.runCommand('foo');

      expect(exitCode, 0);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                plugin.childDirectory('android').childFile('gradlew').path,
                const <String>[
                  'foo',
                ],
                plugin.childDirectory('android').path),
          ]));
    });

    test('runs with arguments', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/gradlew']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      final int exitCode = await project.runCommand(
        'foo',
        arguments: <String>['--bar', '--baz'],
      );

      expect(exitCode, 0);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                plugin.childDirectory('android').childFile('gradlew').path,
                const <String>[
                  'foo',
                  '--bar',
                  '--baz',
                ],
                plugin.childDirectory('android').path),
          ]));
    });

    test('runs with the correct wrapper on Windows', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/gradlew.bat']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      final int exitCode = await project.runCommand('foo');

      expect(exitCode, 0);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                plugin.childDirectory('android').childFile('gradlew.bat').path,
                const <String>[
                  'foo',
                ],
                plugin.childDirectory('android').path),
          ]));
    });

    test('returns error codes', () async {
      final Directory plugin = createFakePlugin(
          'plugin', fileSystem.directory('/'),
          extraFiles: <String>['android/gradlew.bat']);
      final GradleProject project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      processRunner.mockProcessesForExecutable[project.gradleWrapper.path] =
          <io.Process>[
        MockProcess(exitCode: 1),
      ];

      final int exitCode = await project.runCommand('foo');

      expect(exitCode, 1);
    });
  });
}
