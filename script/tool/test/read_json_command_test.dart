// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/read_json_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('$MapReadJsonCommand', () {
    CommandRunner<void> runner;
    final FileSystem fileSystem = MemoryFileSystem();

    setUp(() {
      final MapReadJsonCommand command = MapReadJsonCommand(fileSystem);

      runner = CommandRunner<void>('test_test', 'Test for $MapReadJsonCommand');
      runner.addCommand(command);
    });

    test('throws if --json-file key is empty.', () async {
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
          redColorString('json-file is not specified'),
        ]),
      );
    });

    test('throws if --key key is empty.', () async {
      bool hasError = false;

      final List<String> outputs = await runCapturingPrint(
        runner,
        <String>['read-map-json', '--json-file', '{"key": "value"}'],
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
      final File jsonFile = fileSystem.file('temp_json.json');
      jsonFile.createSync();
      const String jsonString = '''
{
  "key1":"value1"
}
''';
      jsonFile.writeAsStringSync(jsonString);
      final List<String> outputs = await runCapturingPrint(runner, <String>[
        'read-map-json',
        '--json-file',
        'temp_json.json',
        '--key',
        'key1'
      ]);

      expect(
        outputs,
        orderedEquals(<String>[
          'value1',
        ]),
      );
    });
  });
}
