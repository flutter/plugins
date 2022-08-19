// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
  });

  group('displayName', () {
    test('prints packageDir-relative paths by default', () async {
      expect(
        RepositoryPackage(packagesDir.childDirectory('foo')).displayName,
        'foo',
      );
      expect(
        RepositoryPackage(packagesDir
                .childDirectory('foo')
                .childDirectory('bar')
                .childDirectory('baz'))
            .displayName,
        'foo/bar/baz',
      );
    });

    test('handles third_party/packages/', () async {
      expect(
        RepositoryPackage(packagesDir.parent
                .childDirectory('third_party')
                .childDirectory('packages')
                .childDirectory('foo')
                .childDirectory('bar')
                .childDirectory('baz'))
            .displayName,
        'foo/bar/baz',
      );
    });

    test('always uses Posix-style paths', () async {
      final Directory windowsPackagesDir = createPackagesDirectory(
          fileSystem: MemoryFileSystem(style: FileSystemStyle.windows));

      expect(
        RepositoryPackage(windowsPackagesDir.childDirectory('foo')).displayName,
        'foo',
      );
      expect(
        RepositoryPackage(windowsPackagesDir
                .childDirectory('foo')
                .childDirectory('bar')
                .childDirectory('baz'))
            .displayName,
        'foo/bar/baz',
      );
    });

    test('elides group name in grouped federated plugin structure', () async {
      expect(
        RepositoryPackage(packagesDir
                .childDirectory('a_plugin')
                .childDirectory('a_plugin_platform_interface'))
            .displayName,
        'a_plugin_platform_interface',
      );
      expect(
        RepositoryPackage(packagesDir
                .childDirectory('a_plugin')
                .childDirectory('a_plugin_platform_web'))
            .displayName,
        'a_plugin_platform_web',
      );
    });

    // The app-facing package doesn't get elided to avoid potential confusion
    // with the group folder itself.
    test('does not elide group name for app-facing packages', () async {
      expect(
        RepositoryPackage(packagesDir
                .childDirectory('a_plugin')
                .childDirectory('a_plugin'))
            .displayName,
        'a_plugin/a_plugin',
      );
    });
  });

  group('getExamples', () {
    test('handles a single Flutter example', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);

      final List<RepositoryPackage> examples = plugin.getExamples().toList();

      expect(examples.length, 1);
      expect(examples[0].path, getExampleDir(plugin).path);
    });

    test('handles multiple Flutter examples', () async {
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          examples: <String>['example1', 'example2']);

      final List<RepositoryPackage> examples = plugin.getExamples().toList();

      expect(examples.length, 2);
      expect(examples[0].path,
          getExampleDir(plugin).childDirectory('example1').path);
      expect(examples[1].path,
          getExampleDir(plugin).childDirectory('example2').path);
    });

    test('handles a single non-Flutter example', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      final List<RepositoryPackage> examples = package.getExamples().toList();

      expect(examples.length, 1);
      expect(examples[0].path, getExampleDir(package).path);
    });

    test('handles multiple non-Flutter examples', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          examples: <String>['example1', 'example2']);

      final List<RepositoryPackage> examples = package.getExamples().toList();

      expect(examples.length, 2);
      expect(examples[0].path,
          getExampleDir(package).childDirectory('example1').path);
      expect(examples[1].path,
          getExampleDir(package).childDirectory('example2').path);
    });
  });

  group('federated plugin queries', () {
    test('all return false for a simple plugin', () {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);
      expect(plugin.isFederated, false);
      expect(plugin.isAppFacing, false);
      expect(plugin.isPlatformInterface, false);
      expect(plugin.isFederated, false);
    });

    test('handle app-facing packages', () {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir.childDirectory('a_plugin'));
      expect(plugin.isFederated, true);
      expect(plugin.isAppFacing, true);
      expect(plugin.isPlatformInterface, false);
      expect(plugin.isPlatformImplementation, false);
    });

    test('handle platform interface packages', () {
      final RepositoryPackage plugin = createFakePlugin(
          'a_plugin_platform_interface',
          packagesDir.childDirectory('a_plugin'));
      expect(plugin.isFederated, true);
      expect(plugin.isAppFacing, false);
      expect(plugin.isPlatformInterface, true);
      expect(plugin.isPlatformImplementation, false);
    });

    test('handle platform implementation packages', () {
      // A platform interface can end with anything, not just one of the known
      // platform names, because of cases like webview_flutter_wkwebview.
      final RepositoryPackage plugin = createFakePlugin(
          'a_plugin_foo', packagesDir.childDirectory('a_plugin'));
      expect(plugin.isFederated, true);
      expect(plugin.isAppFacing, false);
      expect(plugin.isPlatformInterface, false);
      expect(plugin.isPlatformImplementation, true);
    });
  });

  group('pubspec', () {
    test('file', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);

      final File pubspecFile = plugin.pubspecFile;

      expect(pubspecFile.path, plugin.directory.childFile('pubspec.yaml').path);
    });

    test('parsing', () async {
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          examples: <String>['example1', 'example2']);

      final Pubspec pubspec = plugin.parsePubspec();

      expect(pubspec.name, 'a_plugin');
    });
  });

  group('requiresFlutter', () {
    test('returns true for Flutter package', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, isFlutter: true);
      expect(package.requiresFlutter(), true);
    });

    test('returns false for non-Flutter package', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      expect(package.requiresFlutter(), false);
    });
  });
}
