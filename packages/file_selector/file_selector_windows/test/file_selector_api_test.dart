// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/src/file_selector_api.dart';
import 'package:file_selector_windows/src/file_selector_dart/dialog_mode.dart';
import 'package:file_selector_windows/src/file_selector_dart/dialog_wrapper.dart';
import 'package:file_selector_windows/src/file_selector_dart/dialog_wrapper_factory.dart';
import 'package:file_selector_windows/src/file_selector_dart/selection_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:win32/win32.dart';

import 'file_selector_api_test.mocks.dart';

@GenerateMocks(<Type>[DialogWrapperFactory, DialogWrapper])
void main() {
  const int parentWindow = 1;
  final MockDialogWrapperFactory mockDialogWrapperFactory =
      MockDialogWrapperFactory();
  late MockDialogWrapper mockDialogWrapper;
  final FileSelectorApi fileSelectorApi =
      FileSelectorApi.useFakeForegroundWindow(
          mockDialogWrapperFactory, parentWindow);

  const List<String> expectedFileList = <String>['fileA', 'fileB'];
  final SelectionOptions emptyOptions = SelectionOptions();

  setUp(() {
    mockDialogWrapper = MockDialogWrapper();
    when(mockDialogWrapper.lastResult).thenReturn(S_OK);
    when(mockDialogWrapperFactory.createInstance(DialogMode.Save))
        .thenReturn(mockDialogWrapper);
    when(mockDialogWrapperFactory.createInstance(DialogMode.Open))
        .thenReturn(mockDialogWrapper);
    when(mockDialogWrapper.show(parentWindow)).thenReturn(expectedFileList);
  });

  tearDown(() {
    reset(mockDialogWrapper);
    reset(mockDialogWrapperFactory);
  });

  test('FileSelectorApi should not be null', () {
    expect(fileSelectorApi, isNotNull);
  });

  group('showSaveDialog', () {
    test('should call setFileName if a suggestedName is provided', () {
      // Arrange
      const String suggestedName = 'suggestedName';

      // Act
      fileSelectorApi.showSaveDialog(emptyOptions, null, suggestedName, null);

      // Assert
      verify(mockDialogWrapper.setFileName(suggestedName)).called(1);
    });

    test('should create a DialogWrapper with DialogMode Save', () {
      // Act
      fileSelectorApi.showSaveDialog(emptyOptions, null, null, null);

      // Assert
      verify(mockDialogWrapperFactory.createInstance(DialogMode.Save))
          .called(1);
    });
  });
  group('showOpenDialog', () {
    test('should create a DialogWrapper with DialogMode Open', () {
      // Act
      fileSelectorApi.showOpenDialog(emptyOptions, null, null);

      // Assert
      verify(mockDialogWrapperFactory.createInstance(DialogMode.Open))
          .called(1);
    });
  });
  group('Common behavior', () {
    test('should throw a WindowsException is DialogWrapper can not be created',
        () {
      // Arrange
      when(mockDialogWrapperFactory.createInstance(DialogMode.Open))
          .thenReturn(mockDialogWrapper);
      when(mockDialogWrapper.lastResult).thenReturn(E_FAIL);

      // Act - Assert
      expect(() => fileSelectorApi.showOpenDialog(emptyOptions, null, null),
          throwsA(const TypeMatcher<WindowsException>()));
    });

    test('should not call AddOptions if no options are configured', () {
      // Act
      fileSelectorApi.showOpenDialog(emptyOptions, null, null);

      // Assert
      verifyNever(mockDialogWrapper.addOptions(any));
    });
    test('should call AddOptions with FOS_PICKFOLDERS configured', () {
      // Arrange
      final SelectionOptions options = SelectionOptions(selectFolders: true);

      // Act
      fileSelectorApi.showOpenDialog(options, null, null);

      // Assert
      verify(mockDialogWrapper
              .addOptions(FILEOPENDIALOGOPTIONS.FOS_PICKFOLDERS))
          .called(1);
    });

    test('should call AddOptions with FOS_ALLOWMULTISELECT configured', () {
      // Arrange
      final SelectionOptions options = SelectionOptions(allowMultiple: true);

      // Act
      fileSelectorApi.showOpenDialog(options, null, null);

      // Assert
      verify(mockDialogWrapper
              .addOptions(FILEOPENDIALOGOPTIONS.FOS_ALLOWMULTISELECT))
          .called(1);
    });

    test('should call setFolder if an initialDirectory is provided', () {
      // Arrange
      const String initialDirectory = 'path/to/dir';

      // Act
      fileSelectorApi.showOpenDialog(emptyOptions, initialDirectory, null);

      // Assert
      verify(mockDialogWrapper.setFolder(initialDirectory)).called(1);
    });

    test('should call setOkButtonLabel if confirmButtonText is provided', () {
      // Arrange
      const String confirmButtonText = 'OK';

      // Act
      fileSelectorApi.showOpenDialog(emptyOptions, null, confirmButtonText);

      // Assert
      verify(mockDialogWrapper.setOkButtonLabel(confirmButtonText)).called(1);
    });

    test('should call setFileTypeFilters with provided allowedTypes', () {
      // Arrange
      final SelectionOptions options =
          SelectionOptions(allowedTypes: <XTypeGroup>[
        const XTypeGroup(extensions: <String>['jpg', 'png'], label: 'Images'),
        const XTypeGroup(extensions: <String>['txt', 'json'], label: 'Text'),
      ]);

      // Act
      fileSelectorApi.showOpenDialog(options, null, null);

      // Assert
      verify(mockDialogWrapper.setFileTypeFilters(options.allowedTypes))
          .called(1);
    });

    test('should return the file list on success', () {
      // Act
      final List<String?> result =
          fileSelectorApi.showOpenDialog(emptyOptions, null, null);

      // Assert
      expect(result.length, expectedFileList.length);
      expect(result, expectedFileList);
    });

    test('should throw an exception if file list is null', () {
      // Arrange
      when(mockDialogWrapper.show(parentWindow)).thenReturn(null);

      // Act - Assert
      expect(() => fileSelectorApi.showOpenDialog(emptyOptions, null, null),
          throwsA(const TypeMatcher<WindowsException>()));
    });
  });
}
