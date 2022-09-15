// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:file_selector_windows/src/messages.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'file_selector_windows_test.mocks.dart';
import 'test_api.dart';

@GenerateMocks(<Type>[TestFileSelectorApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FileSelectorWindows plugin = FileSelectorWindows();
  late MockTestFileSelectorApi mockApi;

  setUp(() {
    mockApi = MockTestFileSelectorApi();
    TestFileSelectorApi.setup(mockApi);
  });

  test('registered instance', () {
    FileSelectorWindows.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorWindows>());
  });

  group('#openFile', () {
    setUp(() {
      when(mockApi.showOpenDialog(any, any, any)).thenReturn(<String?>['foo']);
    });

    test('simple call works', () async {
      final XFile? file = await plugin.openFile();

      expect(file!.path, 'foo');
      final VerificationResult result =
          verify(mockApi.showOpenDialog(captureAny, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(options.allowMultiple, false);
      expect(options.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image']);

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result =
          verify(mockApi.showOpenDialog(captureAny, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(
          _typeGroupListsMatch(options.allowedTypes, <TypeGroup>[
            TypeGroup(label: 'text', extensions: <String>['txt']),
            TypeGroup(label: 'image', extensions: <String>['jpg']),
          ]),
          true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFile(initialDirectory: '/example/directory');

      verify(mockApi.showOpenDialog(any, '/example/directory', null));
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFile(confirmButtonText: 'Open File');

      verify(mockApi.showOpenDialog(any, null, 'Open File'));
    });

    test('throws for a type group that does not support Windows', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('#openFiles', () {
    setUp(() {
      when(mockApi.showOpenDialog(any, any, any))
          .thenReturn(<String?>['foo', 'bar']);
    });

    test('simple call works', () async {
      final List<XFile> file = await plugin.openFiles();

      expect(file[0].path, 'foo');
      expect(file[1].path, 'bar');
      final VerificationResult result =
          verify(mockApi.showOpenDialog(captureAny, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(options.allowMultiple, true);
      expect(options.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image']);

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result =
          verify(mockApi.showOpenDialog(captureAny, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(
          _typeGroupListsMatch(options.allowedTypes, <TypeGroup>[
            TypeGroup(label: 'text', extensions: <String>['txt']),
            TypeGroup(label: 'image', extensions: <String>['jpg']),
          ]),
          true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFiles(initialDirectory: '/example/directory');

      verify(mockApi.showOpenDialog(any, '/example/directory', null));
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(confirmButtonText: 'Open Files');

      verify(mockApi.showOpenDialog(any, null, 'Open Files'));
    });

    test('throws for a type group that does not support Windows', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('#getDirectoryPath', () {
    setUp(() {
      when(mockApi.showOpenDialog(any, any, any)).thenReturn(<String?>['foo']);
    });

    test('simple call works', () async {
      final String? path = await plugin.getDirectoryPath();

      expect(path, 'foo');
      final VerificationResult result =
          verify(mockApi.showOpenDialog(captureAny, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(options.allowMultiple, false);
      expect(options.selectFolders, true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/example/directory');

      verify(mockApi.showOpenDialog(any, '/example/directory', null));
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPath(confirmButtonText: 'Open Directory');

      verify(mockApi.showOpenDialog(any, null, 'Open Directory'));
    });
  });

  group('#getSavePath', () {
    setUp(() {
      when(mockApi.showSaveDialog(any, any, any, any))
          .thenReturn(<String?>['foo']);
    });

    test('simple call works', () async {
      final String? path = await plugin.getSavePath();

      expect(path, 'foo');
      final VerificationResult result =
          verify(mockApi.showSaveDialog(captureAny, null, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(options.allowMultiple, false);
      expect(options.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image']);

      await plugin
          .getSavePath(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result =
          verify(mockApi.showSaveDialog(captureAny, null, null, null));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(
          _typeGroupListsMatch(options.allowedTypes, <TypeGroup>[
            TypeGroup(label: 'text', extensions: <String>['txt']),
            TypeGroup(label: 'image', extensions: <String>['jpg']),
          ]),
          true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSavePath(initialDirectory: '/example/directory');

      verify(mockApi.showSaveDialog(any, '/example/directory', null, null));
    });

    test('passes suggestedName correctly', () async {
      await plugin.getSavePath(suggestedName: 'baz.txt');

      verify(mockApi.showSaveDialog(any, null, 'baz.txt', null));
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSavePath(confirmButtonText: 'Save File');

      verify(mockApi.showSaveDialog(any, null, null, 'Save File'));
    });

    test('throws for a type group that does not support Windows', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
      );

      await expectLater(
          plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
          completes);
    });
  });
}

// True if the given options match.
//
// This is needed because Pigeon data classes don't have custom equality checks,
// so only match for identical instances.
bool _typeGroupListsMatch(List<TypeGroup?> a, List<TypeGroup?> b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (!_typeGroupsMatch(a[i], b[i])) {
      return false;
    }
  }
  return true;
}

// True if the given type groups match.
//
// This is needed because Pigeon data classes don't have custom equality checks,
// so only match for identical instances.
bool _typeGroupsMatch(TypeGroup? a, TypeGroup? b) {
  return a!.label == b!.label && listEquals(a.extensions, b.extensions);
}
