// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/publish_check_command.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$PublishCheckCommand tests', () {
    FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late RecordingProcessRunner processRunner;
    late CommandRunner<void> runner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final PublishCheckCommand publishCheckCommand = PublishCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(publishCheckCommand);
    });

    test('publish check all packages', () async {
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin_tools_test_package_a', packagesDir);
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin_tools_test_package_b', packagesDir);

      await runCapturingPrint(runner, <String>['publish-check']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin1.path),
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin2.path),
          ]));
    });

    test('fail on negative test', () async {
      createFakePlugin('plugin_tools_test_package_a', packagesDir);

      processRunner.mockProcessesForExecutable['flutter'] = <io.Process>[
        MockProcess(exitCode: 1, stdout: 'Some error from pub')
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Some error from pub'),
          contains('Unable to publish plugin_tools_test_package_a'),
        ]),
      );
    });

    test('fail on bad pubspec', () async {
      final RepositoryPackage package = createFakePlugin('c', packagesDir);
      await package.pubspecFile.writeAsString('bad-yaml');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No valid pubspec found.'),
        ]),
      );
    });

    test('fails if AUTHORS is missing', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      package.authorsFile.delete();

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'No AUTHORS file found. Packages must include an AUTHORS file.'),
        ]),
      );
    });

    test('does not require AUTHORS for third-party', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir.parent
              .childDirectory('third_party')
              .childDirectory('packages'));
      package.authorsFile.delete();

      final List<String> output =
          await runCapturingPrint(runner, <String>['publish-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package'),
        ]),
      );
    });

    test('pass on prerelease if --allow-pre-release flag is on', () async {
      createFakePlugin('d', packagesDir);

      final MockProcess process = MockProcess(
          exitCode: 1,
          stdout: 'Package has 1 warning.\n'
              'Packages with an SDK constraint on a pre-release of the Dart '
              'SDK should themselves be published as a pre-release version.');
      processRunner.mockProcessesForExecutable['flutter'] = <io.Process>[
        process,
      ];

      expect(
          runCapturingPrint(
              runner, <String>['publish-check', '--allow-pre-release']),
          completes);
    });

    test('fail on prerelease if --allow-pre-release flag is off', () async {
      createFakePlugin('d', packagesDir);

      final MockProcess process = MockProcess(
          exitCode: 1,
          stdout: 'Package has 1 warning.\n'
              'Packages with an SDK constraint on a pre-release of the Dart '
              'SDK should themselves be published as a pre-release version.');
      processRunner.mockProcessesForExecutable['flutter'] = <io.Process>[
        process,
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Packages with an SDK constraint on a pre-release of the Dart SDK'),
          contains('Unable to publish d'),
        ]),
      );
    });

    test('Success message on stderr is not printed as an error', () async {
      createFakePlugin('d', packagesDir);

      processRunner.mockProcessesForExecutable['flutter'] = <io.Process>[
        MockProcess(stdout: 'Package has 0 warnings.'),
      ];

      final List<String> output =
          await runCapturingPrint(runner, <String>['publish-check']);

      expect(output, isNot(contains(contains('ERROR:'))));
    });

    test(
        '--machine: Log JSON with status:no-publish and correct human message, if there are no packages need to be published. ',
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
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return http.Response('', 500);
      });
      final PublishCheckCommand command = PublishCheckCommand(packagesDir,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      createFakePlugin('no_publish_a', packagesDir, version: '0.1.0');
      createFakePlugin('no_publish_b', packagesDir, version: '0.2.0');

      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--machine']);

      expect(output.first, r'''
{
  "status": "no-publish",
  "humanMessage": [
    "\n============================================================\n|| Running for no_publish_a\n============================================================\n",
    "Package no_publish_a version: 0.1.0 has already be published on pub.",
    "\n============================================================\n|| Running for no_publish_b\n============================================================\n",
    "Package no_publish_b version: 0.2.0 has already be published on pub.",
    "\n",
    "------------------------------------------------------------",
    "Run overview:",
    "  no_publish_a - ran",
    "  no_publish_b - ran",
    "",
    "Ran for 2 package(s)",
    "\n",
    "No issues found!"
  ]
}''');
    });

    test(
        '--machine: Log JSON with status:needs-publish and correct human message, if there is at least 1 plugin needs to be published.',
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
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return http.Response('', 500);
      });
      final PublishCheckCommand command = PublishCheckCommand(packagesDir,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      createFakePlugin('no_publish_a', packagesDir, version: '0.1.0');
      createFakePlugin('no_publish_b', packagesDir, version: '0.2.0');

      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--machine']);

      expect(output.first, r'''
{
  "status": "needs-publish",
  "humanMessage": [
    "\n============================================================\n|| Running for no_publish_a\n============================================================\n",
    "Package no_publish_a version: 0.1.0 has already be published on pub.",
    "\n============================================================\n|| Running for no_publish_b\n============================================================\n",
    "Running pub publish --dry-run:",
    "Package no_publish_b is able to be published.",
    "\n",
    "------------------------------------------------------------",
    "Run overview:",
    "  no_publish_a - ran",
    "  no_publish_b - ran",
    "",
    "Ran for 2 package(s)",
    "\n",
    "No issues found!"
  ]
}''');
    });

    test(
        '--machine: Log correct JSON, if there is at least 1 plugin contains error.',
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
        return http.Response('', 500);
      });
      final PublishCheckCommand command = PublishCheckCommand(packagesDir,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      final RepositoryPackage plugin =
          createFakePlugin('no_publish_a', packagesDir, version: '0.1.0');
      createFakePlugin('no_publish_b', packagesDir, version: '0.2.0');

      await plugin.pubspecFile.writeAsString('bad-yaml');

      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--machine'],
          errorHandler: (Error error) {
        expect(error, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(output.first, contains(r'''
{
  "status": "error",
  "humanMessage": [
    "\n============================================================\n|| Running for no_publish_a\n============================================================\n",
    "Failed to parse `pubspec.yaml` at /packages/no_publish_a/pubspec.yaml: ParsedYamlException:'''));
      // This is split into two checks since the details of the YamlException
      // aren't controlled by this package, so asserting its exact format would
      // make the test fragile to irrelevant changes in those details.
      expect(output.first, contains(r'''
    "No valid pubspec found.",
    "\n============================================================\n|| Running for no_publish_b\n============================================================\n",
    "url https://pub.dev/packages/no_publish_b.json",
    "no_publish_b.json",
    "Running pub publish --dry-run:",
    "Package no_publish_b is able to be published.",
    "\n",
    "The following packages had errors:",
    "  no_publish_a",
    "See above for full details."
  ]
}'''));
    });
  });
}
