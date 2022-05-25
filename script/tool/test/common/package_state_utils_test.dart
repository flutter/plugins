// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/package_state_utils.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
  });

  group('checkPackageChangeState', () {
    test('reports version change needed for code changes', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_package/lib/plugin.dart',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_package');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
    });

    test('handles trailing slash on package path', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_package/lib/plugin.dart',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_package/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.hasChangelogChange, false);
    });

    test('does not report version change exempt changes', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/android/lint-baseline.xml',
        'packages/a_plugin/example/android/src/androidTest/foo/bar/FooTest.java',
        'packages/a_plugin/example/ios/RunnerTests/Foo.m',
        'packages/a_plugin/example/ios/RunnerUITests/info.plist',
        'packages/a_plugin/tool/a_development_tool.dart',
        'packages/a_plugin/CHANGELOG.md',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.hasChangelogChange, true);
    });

    test('only considers a root "tool" folder to be special', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/lib/foo/tool/tool_thing.dart',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
    });

    test('requires a version change for example main', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/lib/main.dart',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
    });

    test('requires a version change for example readme.md', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/README.md',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
    });

    test('requires a version change for example example.md', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/lib/example.md',
      ];

      final PackageChangeState state = checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
    });
  });
}
