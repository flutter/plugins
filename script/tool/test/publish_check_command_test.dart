// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common.dart';
import 'package:flutter_plugin_tools/src/publish_check_command.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$PublishCheckProcessRunner tests', () {
    PublishCheckProcessRunner processRunner;
    CommandRunner<void> runner;

    setUp(() {
      initializeFakePackages();
      processRunner = PublishCheckProcessRunner();
      final PublishCheckCommand publishCheckCommand = PublishCheckCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(publishCheckCommand);
    });

    tearDown(() {
      mockPackagesDir.deleteSync(recursive: true);
    });

    test('publish check all packages', () async {
      final Directory plugin1Dir = createFakePlugin('a');
      final Directory plugin2Dir = createFakePlugin('b');

      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );
      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );
      await runner.run(<String>['publish-check']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin1Dir.path),
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin2Dir.path),
          ]));
    });

    test('fail on negative test', () async {
      createFakePlugin('a');

      final MockProcess process = MockProcess();
      process.stdoutController.close(); // ignore: unawaited_futures
      process.stderrController.close(); // ignore: unawaited_futures
      process.exitCodeCompleter.complete(1);

      processRunner.processesToReturn.add(process);

      expect(
        () => runner.run(<String>['publish-check']),
        throwsA(isA<ToolExit>()),
      );
    });

    test('fail on bad pubspec', () async {
      final Directory dir = createFakePlugin('c');
      await dir.childFile('pubspec.yaml').writeAsString('bad-yaml');

      final MockProcess process = MockProcess();
      processRunner.processesToReturn.add(process);

      expect(() => runner.run(<String>['publish-check']),
          throwsA(isA<ToolExit>()));
    });

    test('pass on prerelease if --allow-pre-release flag is on', () async {
      createFakePlugin('d');

      const String preReleaseOutput = 'Package has 1 warning.'
          'Packages with an SDK constraint on a pre-release of the Dart SDK should themselves be published as a pre-release version.';

      final MockProcess process = MockProcess();
      process.stdoutController.add(preReleaseOutput.codeUnits);
      process.stdoutController.close(); // ignore: unawaited_futures
      process.stderrController.close(); // ignore: unawaited_futures

      process.exitCodeCompleter.complete(1);

      processRunner.processesToReturn.add(process);

      expect(runner.run(<String>['publish-check', '--allow-pre-release']),
          completes);
    });

    test('fail on prerelease if --allow-pre-release flag is off', () async {
      createFakePlugin('d');

      const String preReleaseOutput = 'Package has 1 warning.'
          'Packages with an SDK constraint on a pre-release of the Dart SDK should themselves be published as a pre-release version.';

      final MockProcess process = MockProcess();
      process.stdoutController.add(preReleaseOutput.codeUnits);
      process.stdoutController.close(); // ignore: unawaited_futures
      process.stderrController.close(); // ignore: unawaited_futures

      process.exitCodeCompleter.complete(1);

      processRunner.processesToReturn.add(process);

      expect(runner.run(<String>['publish-check']), throwsA(isA<ToolExit>()));
    });

    test(
        '--log-status: Log no_publish at the end if there are no packages need to be published. ',
        () async {
      const Map<String, dynamic> httpResponseA = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      const Map<String, dynamic> httpResponseB = <String, dynamic>{
        'name': 'b',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
          '0.2.0',
        ],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        print('url ${request.url}');
        print(request.url.pathSegments.last);
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return null;
      });
      final PublishCheckCommand command = PublishCheckCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      final Directory plugin1Dir =
          createFakePlugin('no_publish_a', includeVersion: true);
      final Directory plugin2Dir =
          createFakePlugin('no_publish_b', includeVersion: true);

      createFakePubspec(plugin1Dir,
          name: 'no_publish_a', includeVersion: true, version: '0.1.0');
      createFakePubspec(plugin2Dir,
          name: 'no_publish_b', includeVersion: true, version: '0.2.0');

      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );

      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--log-status']);

      expect(output.last, 'no-publish');
    });

    test(
        '--log-status: Log needs-publish at the end if there is at least 1 plugin needs to be published. ',
        () async {
      const Map<String, dynamic> httpResponseA = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      const Map<String, dynamic> httpResponseB = <String, dynamic>{
        'name': 'b',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        print('url ${request.url}');
        print(request.url.pathSegments.last);
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return null;
      });
      final PublishCheckCommand command = PublishCheckCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      final Directory plugin1Dir =
          createFakePlugin('no_publish_a', includeVersion: true);
      final Directory plugin2Dir =
          createFakePlugin('no_publish_b', includeVersion: true);

      createFakePubspec(plugin1Dir,
          name: 'no_publish_a', includeVersion: true, version: '0.1.0');
      createFakePubspec(plugin2Dir,
          name: 'no_publish_b', includeVersion: true, version: '0.2.0');

      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );

      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--log-status']);

      expect(output.last, 'needs-publish');
    });

    test(
        '--log-status: Log error at the end if there is at least 1 plugin contains error.',
        () async {
      const Map<String, dynamic> httpResponseA = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      const Map<String, dynamic> httpResponseB = <String, dynamic>{
        'name': 'b',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        print('url ${request.url}');
        print(request.url.pathSegments.last);
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return null;
      });
      final PublishCheckCommand command = PublishCheckCommand(
          mockPackagesDir, mockFileSystem,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      final Directory plugin1Dir =
          createFakePlugin('no_publish_a', includeVersion: true);
      final Directory plugin2Dir =
          createFakePlugin('no_publish_b', includeVersion: true);

      createFakePubspec(plugin1Dir,
          name: 'no_publish_a', includeVersion: true, version: '0.1.0');
      createFakePubspec(plugin2Dir,
          name: 'no_publish_b', includeVersion: true, version: '0.2.0');
      await plugin1Dir.childFile('pubspec.yaml').writeAsString('bad-yaml');

      processRunner.processesToReturn.add(
        MockProcess()..exitCodeCompleter.complete(0),
      );

      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--log-status'],
          errorHandler: (Error error) {
        expect(error, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);
      expect(output.last, 'error');
    });
  });
}

class PublishCheckProcessRunner extends RecordingProcessRunner {
  final Queue<MockProcess> processesToReturn = Queue<MockProcess>();

  @override
  io.Process get processToReturn => processesToReturn.removeFirst();
}
