// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:file_selector_windows/src/file_selector.dart';
import 'package:file_selector_windows/src/messages.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'file_selector_windows_test.mocks.dart';

import 'test_api.dart';

@GenerateMocks(<Type>[TestFileSelectorApi, FileSelector])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FileSelectorWindows plugin;
  late MockFileSelector mockFileSelector;

  setUp(() {
    mockFileSelector = MockFileSelector();
    plugin = FileSelectorWindows.withFileSelectorAPI(mockFileSelector);
  });

  tearDown(() {
    reset(mockFileSelector);
  });

  test('registered instance', () {
    FileSelectorWindows.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorWindows>());
  });

  group('#openFile', () {
    setUp(() {
      when(mockFileSelector.getFiles(
              selectionOptions: anyNamed('selectionOptions')))
          .thenReturn(<String>['foo']);
    });

    test('simple call works', () async {
      final XFile? file = await plugin.openFile();

      expect(file!.path, 'foo');
      final VerificationResult result = verify(mockFileSelector.getFiles(
          selectionOptions: captureAnyNamed('selectionOptions')));
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

      final VerificationResult result = verify(mockFileSelector.getFiles(
          selectionOptions: captureAnyNamed('selectionOptions'),
          initialDirectory: anyNamed('initialDirectory'),
          confirmButtonText: anyNamed('confirmButtonText')));
      final SelectionOptions options = result.captured[0] as SelectionOptions;
      expect(
          _typeGroupListsMatch(options.allowedTypes, <TypeGroup>[
            TypeGroup(label: 'text', extensions: <String>['txt']),
            TypeGroup(label: 'image', extensions: <String>['jpg']),
          ]),
          true);
    });

    test('passes initialDirectory correctly', () async {
      when(mockFileSelector.getFiles(
              selectionOptions: anyNamed('selectionOptions'),
              initialDirectory: '/example/directory'))
          .thenReturn(<String>['foo']);
      await plugin.openFile(initialDirectory: '/example/directory');

      verify(mockFileSelector.getFiles(
          selectionOptions: anyNamed('selectionOptions'),
          initialDirectory: '/example/directory',
          confirmButtonText: anyNamed('confirmButtonText')));
    });

    test('passes confirmButtonText correctly', () async {
      when(mockFileSelector.getFiles(
              selectionOptions: anyNamed('selectionOptions'),
              confirmButtonText: 'Open File'))
          .thenReturn(<String>['foo']);
      await plugin.openFile(confirmButtonText: 'Open File');

      verify(mockFileSelector.getFiles(
          selectionOptions: anyNamed('selectionOptions'),
          initialDirectory: anyNamed('initialDirectory'),
          confirmButtonText: 'Open File'));
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
      when(mockFileSelector.getFiles(
              selectionOptions: anyNamed('selectionOptions'),
              initialDirectory: anyNamed('initialDirectory'),
              confirmButtonText: anyNamed('confirmButtonText')))
          .thenReturn(<String>['foo', 'bar']);
    });

    test('simple call works', () async {
      final List<XFile> file = await plugin.openFiles();

      expect(file[0].path, 'foo');
      expect(file[1].path, 'bar');

      final VerificationResult result = verify(mockFileSelector.getFiles(
          selectionOptions: captureAnyNamed('selectionOptions')));

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

      final VerificationResult result = verify(mockFileSelector.getFiles(
          selectionOptions: captureAnyNamed('selectionOptions')));
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

      verify(mockFileSelector.getFiles(
          selectionOptions: anyNamed('selectionOptions'),
          initialDirectory: '/example/directory'));
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(confirmButtonText: 'Open Files');

      verify(mockFileSelector.getFiles(
          selectionOptions: anyNamed('selectionOptions'),
          initialDirectory: anyNamed('initialDirectory'),
          confirmButtonText: 'Open Files'));
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

  const String mockedPath = 'c://folder/foo';
  const String confirmText = 'Open Directory';
  const String initialDirectory = 'c://example/directory';
  group('#getDirectoryPath', () {
    setUp(() {
      when(mockFileSelector.getDirectoryPath()).thenReturn(mockedPath);
      when(mockFileSelector.getDirectoryPath(confirmButtonText: confirmText))
          .thenReturn(mockedPath);
      when(mockFileSelector.getDirectoryPath(
              initialDirectory: initialDirectory))
          .thenReturn(mockedPath);
    });

    test('simple call works', () async {
      final String? actualPath = await plugin.getDirectoryPath();

      expect(actualPath, mockedPath);
      verify(mockFileSelector.getDirectoryPath());
    });

    test('passes initialDirectory correctly', () async {
      final String? actualPath =
          await plugin.getDirectoryPath(initialDirectory: initialDirectory);

      verify(mockFileSelector.getDirectoryPath(
          initialDirectory: initialDirectory));
      expect(actualPath, mockedPath);
    });

    test('passes confirmButtonText correctly', () async {
      final String? actualPath =
          await plugin.getDirectoryPath(confirmButtonText: confirmText);
      verify(mockFileSelector.getDirectoryPath(confirmButtonText: confirmText));
      expect(actualPath, mockedPath);
    });
  });

  group('#getSavePath', () {
    setUp(() {
      when(mockFileSelector.getSavePath(
              selectionOptions: anyNamed('selectionOptions'),
              confirmButtonText: anyNamed('confirmButtonText'),
              initialDirectory: anyNamed('initialDirectory'),
              suggestedFileName: anyNamed('suggestedFileName')))
          .thenReturn(mockedPath);
    });

    test('simple call works', () async {
      final String? actualPath = await plugin.getSavePath();

      expect(actualPath, mockedPath);
      final VerificationResult result = verify(mockFileSelector.getSavePath(
          selectionOptions: captureAnyNamed('selectionOptions'),
          confirmButtonText: anyNamed('confirmButtonText'),
          initialDirectory: anyNamed('initialDirectory'),
          suggestedFileName: anyNamed('suggestedFileName')));
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

      final VerificationResult result = verify(mockFileSelector.getSavePath(
          selectionOptions: captureAnyNamed('selectionOptions'),
          confirmButtonText: anyNamed('confirmButtonText'),
          initialDirectory: anyNamed('initialDirectory'),
          suggestedFileName: anyNamed('suggestedFileName')));
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
      verify(mockFileSelector.getSavePath(
          selectionOptions: captureAnyNamed('selectionOptions'),
          confirmButtonText: anyNamed('confirmButtonText'),
          initialDirectory: '/example/directory',
          suggestedFileName: anyNamed('suggestedFileName')));
    });

    test('passes suggestedName correctly', () async {
      await plugin.getSavePath(suggestedName: 'baz.txt');

      verify(mockFileSelector.getSavePath(
          selectionOptions: captureAnyNamed('selectionOptions'),
          confirmButtonText: anyNamed('confirmButtonText'),
          initialDirectory: anyNamed('initialDirectory'),
          suggestedFileName: 'baz.txt'));
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSavePath(confirmButtonText: 'Save File');

      verify(mockFileSelector.getSavePath(
          selectionOptions: anyNamed('selectionOptions'),
          confirmButtonText: 'Save File',
          initialDirectory: anyNamed('initialDirectory'),
          suggestedFileName: anyNamed('suggestedFileName')));
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
