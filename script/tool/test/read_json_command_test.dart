// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/read_json_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('$MapReadJsonCommand', () {
    CommandRunner<void> runner;

    setUp(() {
      final MapReadJsonCommand command = MapReadJsonCommand();

      runner = CommandRunner<void>('test_test', 'Test for $MapReadJsonCommand');
      runner.addCommand(command);
    });

    test('throws if --json key is empty.', () async {
      bool hasError = false;

      final List<String> outputs = await runCapturingPrint(
        runner,
        <String>['read-map-json'],
        errorHandler: (Error error) {
          expect(error, isA<ToolExit>());
          hasError = true;
        },
      );

      expect(hasError, isTrue);

      expect(
        outputs,
        orderedEquals(<String>[
          redColorString('json is not specified'),
        ]),
      );
    });

    test('throws if --key key is empty.', () async {
      bool hasError = false;

      final List<String> outputs = await runCapturingPrint(
        runner,
        <String>['read-map-json', '--json', '{"key": "value"}'],
        errorHandler: (Error error) {
          expect(error, isA<ToolExit>());
          hasError = true;
        },
      );

      expect(hasError, isTrue);

      expect(
        outputs,
        orderedEquals(<String>[
          redColorString('key is not specified'),
        ]),
      );
    });

    test('correctly extract json value.', () async {
      final List<String> outputs = await runCapturingPrint(runner, <String>[
        'read-map-json',
        '--json',
        '{"my_key": "my_value"}',
        '--key',
        'my_key'
      ]);

      expect(
        outputs,
        orderedEquals(<String>[
          'my_value',
        ]),
      );
    });
  });
}
