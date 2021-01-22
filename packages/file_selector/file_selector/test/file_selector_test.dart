// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  MockFileSelector mock;
  final initialDirectory = '/home/flutteruser';
  final confirmButtonText = 'Use this profile picture';
  final suggestedName = 'suggested_name';
  final acceptedTypeGroups = [
    XTypeGroup(label: 'documents', mimeTypes: [
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessing',
    ]),
    XTypeGroup(label: 'images', extensions: [
      'jpg',
      'png',
    ]),
  ];

  setUp(() {
    mock = MockFileSelector();
    FileSelectorPlatform.instance = mock;
  });

  group('openFile', () {
    final expectedFile = XFile('path');

    test('works', () async {
      when(mock.openFile(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
      )).thenAnswer((_) => Future.value(expectedFile));

      final file = await openFile(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
      );

      expect(file, expectedFile);
    });

    test('works with no arguments', () async {
      when(mock.openFile()).thenAnswer((_) => Future.value(expectedFile));

      final file = await openFile();

      expect(file, expectedFile);
    });

    test('sets the initial directory', () async {
      when(mock.openFile(initialDirectory: initialDirectory))
          .thenAnswer((_) => Future.value(expectedFile));

      final file = await openFile(initialDirectory: initialDirectory);
      expect(file, expectedFile);
    });

    test('sets the button confirmation label', () async {
      when(mock.openFile(confirmButtonText: confirmButtonText))
          .thenAnswer((_) => Future.value(expectedFile));

      final file = await openFile(confirmButtonText: confirmButtonText);
      expect(file, expectedFile);
    });

    test('sets the accepted type groups', () async {
      when(mock.openFile(acceptedTypeGroups: acceptedTypeGroups))
          .thenAnswer((_) => Future.value(expectedFile));

      final file = await openFile(acceptedTypeGroups: acceptedTypeGroups);
      expect(file, expectedFile);
    });
  });

  group('openFiles', () {
    final expectedFiles = [XFile('path')];

    test('works', () async {
      when(mock.openFiles(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
      )).thenAnswer((_) => Future.value(expectedFiles));

      final file = await openFiles(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
      );

      expect(file, expectedFiles);
    });

    test('works with no arguments', () async {
      when(mock.openFiles()).thenAnswer((_) => Future.value(expectedFiles));

      final files = await openFiles();

      expect(files, expectedFiles);
    });

    test('sets the initial directory', () async {
      when(mock.openFiles(initialDirectory: initialDirectory))
          .thenAnswer((_) => Future.value(expectedFiles));

      final files = await openFiles(initialDirectory: initialDirectory);
      expect(files, expectedFiles);
    });

    test('sets the button confirmation label', () async {
      when(mock.openFiles(confirmButtonText: confirmButtonText))
          .thenAnswer((_) => Future.value(expectedFiles));

      final files = await openFiles(confirmButtonText: confirmButtonText);
      expect(files, expectedFiles);
    });

    test('sets the accepted type groups', () async {
      when(mock.openFiles(acceptedTypeGroups: acceptedTypeGroups))
          .thenAnswer((_) => Future.value(expectedFiles));

      final files = await openFiles(acceptedTypeGroups: acceptedTypeGroups);
      expect(files, expectedFiles);
    });
  });

  group('getSavePath', () {
    final expectedSavePath = '/example/path';

    test('works', () async {
      when(mock.getSavePath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
        suggestedName: suggestedName,
      )).thenAnswer((_) => Future.value(expectedSavePath));

      final savePath = await getSavePath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
        suggestedName: suggestedName,
      );

      expect(savePath, expectedSavePath);
    });

    test('works with no arguments', () async {
      when(mock.getSavePath())
          .thenAnswer((_) => Future.value(expectedSavePath));

      final savePath = await getSavePath();
      expect(savePath, expectedSavePath);
    });

    test('sets the initial directory', () async {
      when(mock.getSavePath(initialDirectory: initialDirectory))
          .thenAnswer((_) => Future.value(expectedSavePath));

      final savePath = await getSavePath(initialDirectory: initialDirectory);
      expect(savePath, expectedSavePath);
    });

    test('sets the button confirmation label', () async {
      when(mock.getSavePath(confirmButtonText: confirmButtonText))
          .thenAnswer((_) => Future.value(expectedSavePath));

      final savePath = await getSavePath(confirmButtonText: confirmButtonText);
      expect(savePath, expectedSavePath);
    });

    test('sets the accepted type groups', () async {
      when(mock.getSavePath(acceptedTypeGroups: acceptedTypeGroups))
          .thenAnswer((_) => Future.value(expectedSavePath));

      final savePath =
          await getSavePath(acceptedTypeGroups: acceptedTypeGroups);
      expect(savePath, expectedSavePath);
    });

    test('sets the suggested name', () async {
      when(mock.getSavePath(suggestedName: suggestedName))
          .thenAnswer((_) => Future.value(expectedSavePath));

      final savePath = await getSavePath(suggestedName: suggestedName);
      expect(savePath, expectedSavePath);
    });
  });

  group('getDirectoryPath', () {
    final expectedDirectoryPath = '/example/path';

    test('works', () async {
      when(mock.getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
      )).thenAnswer((_) => Future.value(expectedDirectoryPath));

      final directoryPath = await getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
      );

      expect(directoryPath, expectedDirectoryPath);
    });

    test('works with no arguments', () async {
      when(mock.getDirectoryPath())
          .thenAnswer((_) => Future.value(expectedDirectoryPath));

      final directoryPath = await getDirectoryPath();
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the initial directory', () async {
      when(mock.getDirectoryPath(initialDirectory: initialDirectory))
          .thenAnswer((_) => Future.value(expectedDirectoryPath));

      final directoryPath =
          await getDirectoryPath(initialDirectory: initialDirectory);
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the button confirmation label', () async {
      when(mock.getDirectoryPath(confirmButtonText: confirmButtonText))
          .thenAnswer((_) => Future.value(expectedDirectoryPath));

      final directoryPath =
          await getDirectoryPath(confirmButtonText: confirmButtonText);
      expect(directoryPath, expectedDirectoryPath);
    });
  });
}

class MockFileSelector extends Mock
    with MockPlatformInterfaceMixin
    implements FileSelectorPlatform {}
