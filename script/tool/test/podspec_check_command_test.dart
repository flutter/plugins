// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/podspec_check_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

/// Adds a fake podspec to [plugin]'s [platform] directory.
///
/// If [includeSwiftWorkaround] is set, the xcconfig additions to make Swift
/// libraries work in apps that have no Swift will be included. If
/// [scopeSwiftWorkaround] is set, it will be specific to the iOS configuration.
void _writeFakePodspec(RepositoryPackage plugin, String platform,
    {bool includeSwiftWorkaround = false, bool scopeSwiftWorkaround = false}) {
  final String pluginName = plugin.directory.basename;
  final File file = plugin.directory
      .childDirectory(platform)
      .childFile('$pluginName.podspec');
  final String swiftWorkaround = includeSwiftWorkaround
      ? '''
  s.${scopeSwiftWorkaround ? 'ios.' : ''}xcconfig = {
     'LIBRARY_SEARCH_PATHS' => '\$(TOOLCHAIN_DIR)/usr/lib/swift/\$(PLATFORM_NAME)/ \$(SDKROOT)/usr/lib/swift',
     'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
'''
      : '';
  file.createSync(recursive: true);
  file.writeAsStringSync('''
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'shared_preferences_foundation'
  s.version          = '0.0.1'
  s.summary          = 'iOS and macOS implementation of the shared_preferences plugin.'
  s.description      = <<-DESC
Wraps NSUserDefaults, providing a persistent store for simple key-value pairs.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/main/packages/shared_preferences/shared_preferences_foundation'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/main/packages/shared_preferences/shared_preferences_foundation' }
  s.source_files = 'Classes/**/*'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  $swiftWorkaround
  s.swift_version = '5.0'

end
''');
}

void main() {
  group('PodspecCheckCommand', () {
    FileSystem fileSystem;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late MockPlatform mockPlatform;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);

      mockPlatform = MockPlatform(isMacOS: true);
      processRunner = RecordingProcessRunner();
      final PodspecCheckCommand command = PodspecCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner =
          CommandRunner<void>('podspec_test', 'Test for $PodspecCheckCommand');
      runner.addCommand(command);
    });

    test('only runs on macOS', () async {
      createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['plugin1.podspec']);
      mockPlatform.isMacOS = false;

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
        processRunner.recordedCalls,
        equals(<ProcessCall>[]),
      );

      expect(
          output,
          containsAllInOrder(
            <Matcher>[contains('only supported on macOS')],
          ));
    });

    test('runs pod lib lint on a podspec', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>[
          'bogus.dart', // Ignore non-podspecs.
        ],
      );
      _writeFakePodspec(plugin, 'ios');

      processRunner.mockProcessesForExecutable['pod'] = <io.Process>[
        MockProcess(stdout: 'Foo', stderr: 'Bar'),
        MockProcess(),
      ];

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('which', const <String>['pod'], packagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                plugin
                    .platformDirectory(FlutterPlatform.ios)
                    .childFile('plugin1.podspec')
                    .path,
                '--configuration=Debug',
                '--skip-tests',
                '--use-modular-headers',
                '--use-libraries'
              ],
              packagesDir.path),
          ProcessCall(
              'pod',
              <String>[
                'lib',
                'lint',
                plugin
                    .platformDirectory(FlutterPlatform.ios)
                    .childFile('plugin1.podspec')
                    .path,
                '--configuration=Debug',
                '--skip-tests',
                '--use-modular-headers',
              ],
              packagesDir.path),
        ]),
      );

      expect(output, contains('Linting plugin1.podspec'));
      expect(output, contains('Foo'));
      expect(output, contains('Bar'));
    });

    test('fails if pod is missing', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir);
      _writeFakePodspec(plugin, 'ios');

      // Simulate failure from `which pod`.
      processRunner.mockProcessesForExecutable['which'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Unable to find "pod". Make sure it is in your path.'),
            ],
          ));
    });

    test('fails if linting as a framework fails', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir);
      _writeFakePodspec(plugin, 'ios');

      // Simulate failure from `pod`.
      processRunner.mockProcessesForExecutable['pod'] = <io.Process>[
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The following packages had errors:'),
              contains('plugin1:\n'
                  '    plugin1.podspec')
            ],
          ));
    });

    test('fails if linting as a static library fails', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir);
      _writeFakePodspec(plugin, 'ios');

      // Simulate failure from the second call to `pod`.
      processRunner.mockProcessesForExecutable['pod'] = <io.Process>[
        MockProcess(),
        MockProcess(exitCode: 1),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The following packages had errors:'),
              contains('plugin1:\n'
                  '    plugin1.podspec')
            ],
          ));
    });

    test('fails if an iOS Swift plugin is missing the search paths workaround',
        () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['ios/Classes/SomeSwift.swift']);
      _writeFakePodspec(plugin, 'ios');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(r'''
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }'''),
              contains('The following packages had errors:'),
              contains('plugin1:\n'
                  '    plugin1.podspec')
            ],
          ));
    });

    test(
        'fails if a shared-source Swift plugin is missing the search paths workaround',
        () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['darwin/Classes/SomeSwift.swift']);
      _writeFakePodspec(plugin, 'darwin');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['podspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(r'''
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }'''),
              contains('The following packages had errors:'),
              contains('plugin1:\n'
                  '    plugin1.podspec')
            ],
          ));
    });

    test('does not require the search paths workaround for macOS plugins',
        () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['macos/Classes/SomeSwift.swift']);
      _writeFakePodspec(plugin, 'macos');

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Ran for 1 package(s)'),
            ],
          ));
    });

    test('does not require the search paths workaround for ObjC iOS plugins',
        () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>[
            'ios/Classes/SomeObjC.h',
            'ios/Classes/SomeObjC.m'
          ]);
      _writeFakePodspec(plugin, 'ios');

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Ran for 1 package(s)'),
            ],
          ));
    });

    test('passes if the search paths workaround is present', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['ios/Classes/SomeSwift.swift']);
      _writeFakePodspec(plugin, 'ios', includeSwiftWorkaround: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Ran for 1 package(s)'),
            ],
          ));
    });

    test('passes if the search paths workaround is present for iOS only',
        () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          extraFiles: <String>['ios/Classes/SomeSwift.swift']);
      _writeFakePodspec(plugin, 'ios',
          includeSwiftWorkaround: true, scopeSwiftWorkaround: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Ran for 1 package(s)'),
            ],
          ));
    });

    test('does not require the search paths workaround for Swift example code',
        () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'ios/Classes/SomeObjC.h',
        'ios/Classes/SomeObjC.m',
        'example/ios/Runner/AppDelegate.swift',
      ]);
      _writeFakePodspec(plugin, 'ios');

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Ran for 1 package(s)'),
            ],
          ));
    });

    test('skips when there are no podspecs', () async {
      createFakePlugin('plugin1', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['podspec-check']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[contains('SKIPPING: No podspecs.')],
          ));
    });
  });
}
