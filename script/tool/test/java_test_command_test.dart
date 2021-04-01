// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/java_test_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('$JavaTestCommand', () {
    CommandRunner<void> runner;
    final RecordingProcessRunner processRunner = RecordingProcessRunner();

    setUp(() {
      initializeFakePackages();
      final JavaTestCommand command = JavaTestCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner);

      runner =
          CommandRunner<void>('java_test_test', 'Test for $JavaTestCommand');
      runner.addCommand(command);
    });

    tearDown(() {
      cleanupPackages();
      processRunner.recordedCalls.clear();
    });

    test('Should run Java tests in Android implementation folder', () async {
      final Directory plugin = createFakePlugin(
        'plugin1',
        isAndroidPlugin: true,
        isFlutter: true,
        withSingleExample: true,
        withExtraFiles: <List<String>>[
          <String>['example/android', 'gradlew'],
          <String>['android/src/test', 'example_test.java'],
        ],
      );

      await runner.run(<String>['java-test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            p.join(plugin.path, 'example/android/gradlew'),
            <String>['testDebugUnitTest', '--info'],
            p.join(plugin.path, 'example/android'),
          ),
        ]),
      );
    });

    test('Should run Java tests in example folder', () async {
      final Directory plugin = createFakePlugin(
        'plugin1',
        isAndroidPlugin: true,
        isFlutter: true,
        withSingleExample: true,
        withExtraFiles: <List<String>>[
          <String>['example/android', 'gradlew'],
          <String>['example/android/app/src/test', 'example_test.java'],
        ],
      );

      await runner.run(<String>['java-test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            p.join(plugin.path, 'example/android/gradlew'),
            <String>['testDebugUnitTest', '--info'],
            p.join(plugin.path, 'example/android'),
          ),
        ]),
      );
    });
  });
}
