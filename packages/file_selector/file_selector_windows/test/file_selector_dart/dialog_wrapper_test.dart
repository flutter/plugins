// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/src/file_selector_dart/dialog_mode.dart';
import 'package:file_selector_windows/src/file_selector_dart/dialog_wrapper.dart';
import 'package:file_selector_windows/src/file_selector_dart/file_dialog_controller.dart';
import 'package:file_selector_windows/src/file_selector_dart/shell_win32_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:win32/win32.dart';

import 'dialog_wrapper_test.mocks.dart';

@GenerateMocks(<Type>[FileDialogController, ShellWin32Api])
void main() {
  const int defaultReturnValue = S_OK;
  late final MockFileDialogController mockFileDialogController =
      MockFileDialogController();
  late final MockShellWin32Api mockShellWin32Api = MockShellWin32Api();
  const DialogMode dialogMode = DialogMode.Open;
  final DialogWrapper dialogWrapper = DialogWrapper.withFakeDependencies(
      mockFileDialogController, dialogMode, mockShellWin32Api);

  setUp(() {
    setDefaultMocks(mockFileDialogController, defaultReturnValue);
  });

  tearDown(() {
    reset(mockFileDialogController);
    reset(mockShellWin32Api);
  });

  test('setFileName should call dialog setFileName', () {
    const String folderName = 'Documents';
    dialogWrapper.setFileName(folderName);
    verify(mockFileDialogController.setFileName(folderName)).called(1);
  });

  test('setOkButtonLabel should call dialog setOkButtonLabel', () {
    const String okButtonLabel = 'Confirm';
    dialogWrapper.setOkButtonLabel(okButtonLabel);
    verify(mockFileDialogController.setOkButtonLabel(okButtonLabel)).called(1);
  });

  test('addOptions should call dialog getOptions and setOptions', () {
    const int newOptions = FILEOPENDIALOGOPTIONS.FOS_NOREADONLYRETURN;
    dialogWrapper.addOptions(newOptions);
    verify(mockFileDialogController.getOptions(any)).called(1);
    verify(mockFileDialogController.setOptions(newOptions)).called(1);
  });

  test('addOptions should not call setOptions if getOptions returns an error',
      () {
    const int options = FILEOPENDIALOGOPTIONS.FOS_NOREADONLYRETURN;
    when(mockFileDialogController.getOptions(any)).thenReturn(E_FAIL);
    dialogWrapper.addOptions(options);
    verifyNever(mockFileDialogController.setOptions(any));
  });

  test(
      'setFileTypeFilters should call setFileTypes with expected typeGroups count',
      () {
    final List<XTypeGroup> typeGroups = <XTypeGroup>[
      const XTypeGroup(extensions: <String>['jpg', 'png'], label: 'Images'),
      const XTypeGroup(extensions: <String>['txt', 'json'], label: 'Text'),
    ];
    dialogWrapper.setFileTypeFilters(typeGroups);
    verify(mockFileDialogController.setFileTypes(typeGroups.length, any))
        .called(1);
  });

  test('setFileTypeFilters should call setFileTypes with Any by default', () {
    const String expectedPszName = 'Any';
    const String expectedPszSpec = '*.*';
    final List<XTypeGroup> typeGroups = <XTypeGroup>[];
    mockSetFileTypesConditions(
        mockFileDialogController, expectedPszName, expectedPszSpec);
    dialogWrapper.setFileTypeFilters(typeGroups);
    verify(mockFileDialogController.setFileTypes(1, any)).called(1);
    expect(dialogWrapper.lastResult, S_OK);
  });

  test(
      'setFileTypeFilters should call setFileTypes with a label and default extensions',
      () {
    const String label = 'All files';
    const String expectedPszSpec = '*.*';
    final List<XTypeGroup> typeGroups = <XTypeGroup>[
      const XTypeGroup(label: label),
    ];
    mockSetFileTypesConditions(
        mockFileDialogController, label, expectedPszSpec);
    dialogWrapper.setFileTypeFilters(typeGroups);
    verify(mockFileDialogController.setFileTypes(1, any)).called(1);
    expect(dialogWrapper.lastResult, S_OK);
  });

  test(
      'setFileTypeFilters should call setFileTypes with both default label and extensions',
      () {
    const String defaultLabel = 'Any';
    const String expectedPszSpec = '*.*';
    final List<XTypeGroup> typeGroups = <XTypeGroup>[
      const XTypeGroup(),
    ];
    mockSetFileTypesConditions(
        mockFileDialogController, defaultLabel, expectedPszSpec);
    dialogWrapper.setFileTypeFilters(typeGroups);
    verify(mockFileDialogController.setFileTypes(1, any)).called(1);
    expect(dialogWrapper.lastResult, S_OK);
  });

  test(
      'setFileTypeFilters should call setFileTypes with specific labels and extensions',
      () {
    const String jpg = 'jpg';
    const String png = 'png';
    const String imageLabel = 'Image';
    const String txt = 'txt';
    const String json = 'json';
    const String textLabel = 'Text';
    final Map<String, String> expectedfilterSpecification = <String, String>{
      imageLabel: '*.$jpg;*.$png',
      textLabel: '*.$txt;*.$json',
    };
    final List<XTypeGroup> typeGroups = <XTypeGroup>[
      const XTypeGroup(extensions: <String>[jpg, png], label: imageLabel),
      const XTypeGroup(extensions: <String>[txt, json], label: textLabel),
    ];
    when(mockFileDialogController.setFileTypes(any, any))
        .thenAnswer((Invocation realInvocation) {
      final Pointer<COMDLG_FILTERSPEC> pointer =
          realInvocation.positionalArguments[1] as Pointer<COMDLG_FILTERSPEC>;

      int index = 0;
      for (final String key in expectedfilterSpecification.keys) {
        if (pointer[index].pszName.toDartString() != key ||
            pointer[index].pszSpec.toDartString() !=
                expectedfilterSpecification[key]) {
          return E_FAIL;
        }
        index++;
      }
      return S_OK;
    });

    dialogWrapper.setFileTypeFilters(typeGroups);
    verify(mockFileDialogController.setFileTypes(typeGroups.length, any))
        .called(1);
    expect(dialogWrapper.lastResult, S_OK);
  });

  test(
      'setFileTypeFilters should call setFileTypes with specific extensions and No label',
      () {
    const String jpg = 'jpg';
    const String png = 'png';
    const String txt = 'txt';
    const String json = 'json';
    final Map<String, String> expectedfilterSpecification = <String, String>{
      '*.$jpg;*.$png': '*.$jpg;*.$png',
      '*.$txt;*.$json': '*.$txt;*.$json',
    };
    final List<XTypeGroup> typeGroups = <XTypeGroup>[
      const XTypeGroup(extensions: <String>[jpg, png]),
      const XTypeGroup(extensions: <String>[txt, json]),
    ];
    when(mockFileDialogController.setFileTypes(any, any))
        .thenAnswer((Invocation realInvocation) {
      final Pointer<COMDLG_FILTERSPEC> pointer =
          realInvocation.positionalArguments[1] as Pointer<COMDLG_FILTERSPEC>;

      int index = 0;
      for (final String key in expectedfilterSpecification.keys) {
        if (pointer[index].pszName.toDartString() != key ||
            pointer[index].pszSpec.toDartString() !=
                expectedfilterSpecification[key]) {
          return E_FAIL;
        }
        index++;
      }
      return S_OK;
    });

    dialogWrapper.setFileTypeFilters(typeGroups);
    verify(mockFileDialogController.setFileTypes(typeGroups.length, any))
        .called(1);
    expect(dialogWrapper.lastResult, S_OK);
  });

  test('setFolder should not call dialog setFolder if the path is empty', () {
    const String emptyPath = '';
    dialogWrapper.setFolder(emptyPath);
    verifyNever(mockFileDialogController.setFolder(any));
  });

  test('setFolder should call dialog setFolder with the provided path', () {
    const String path = 'path/to/my/folder';
    when(mockShellWin32Api.createItemFromParsingName(path, any, any))
        .thenReturn(S_OK);
    dialogWrapper.setFolder(path);
    verify(mockFileDialogController.setFolder(any)).called(1);
  });

  test('setFolder should not call dialog setFolder if createItem fails', () {
    const String path = 'path/to/my/folder';
    when(mockShellWin32Api.createItemFromParsingName(path, any, any))
        .thenReturn(E_FAIL);
    dialogWrapper.setFolder(path);
    verifyNever(mockFileDialogController.setFolder(any));
  });

  test(
      '[DialogMode == Open] show should return null if parent window is not available',
      () {
    const int parentWindow = 0;
    when(mockFileDialogController.show(parentWindow)).thenReturn(E_FAIL);

    final List<String?>? result = dialogWrapper.show(parentWindow);

    expect(result, null);
    verify(mockFileDialogController.show(parentWindow)).called(1);
    verifyNever(mockFileDialogController.getResults(any));
  });

  test(
      "[DialogMode == Open] show should return null if can't get results from dialog",
      () {
    const int parentWindow = 0;
    when(mockFileDialogController.show(parentWindow)).thenReturn(S_OK);
    when(mockFileDialogController.getResults(any)).thenReturn(E_FAIL);

    final List<String?>? result = dialogWrapper.show(parentWindow);

    expect(result, null);
    verify(mockFileDialogController.show(parentWindow)).called(1);
    verify(mockFileDialogController.getResults(any)).called(1);
  });

  test(
      "[DialogMode == Save] show should return null if can't get result from dialog",
      () {
    final DialogWrapper dialogWrapperModeSave =
        DialogWrapper.withFakeDependencies(
            mockFileDialogController, DialogMode.Save, mockShellWin32Api);
    const int parentWindow = 0;
    when(mockFileDialogController.show(parentWindow)).thenReturn(S_OK);
    when(mockFileDialogController.getResult(any)).thenReturn(E_FAIL);

    final List<String?>? result = dialogWrapperModeSave.show(parentWindow);

    expect(result, null);
    verify(mockFileDialogController.show(parentWindow)).called(1);
    verify(mockFileDialogController.getResult(any)).called(1);
  });

  test('[DialogMode == Save] show should the selected directory for', () {
    const String filePath = 'path/to/file.txt';
    final DialogWrapper dialogWrapperModeSave =
        DialogWrapper.withFakeDependencies(
            mockFileDialogController, DialogMode.Save, mockShellWin32Api);
    const int parentWindow = 0;
    when(mockFileDialogController.show(parentWindow)).thenReturn(S_OK);
    when(mockFileDialogController.getResult(any)).thenReturn(S_OK);
    when(mockShellWin32Api.getPathForShellItem(any)).thenReturn(filePath);

    final List<String?>? result = dialogWrapperModeSave.show(parentWindow);

    expect(result?.first, filePath);
  });
}

void mockSetFileTypesConditions(
    MockFileDialogController mockFileDialogController,
    String expectedPszName,
    String expectedPszSpec) {
  when(mockFileDialogController.setFileTypes(1, any))
      .thenAnswer((Invocation realInvocation) {
    final Pointer<COMDLG_FILTERSPEC> pointer =
        realInvocation.positionalArguments[1] as Pointer<COMDLG_FILTERSPEC>;

    return pointer[0].pszName.toDartString() == expectedPszName &&
            pointer[0].pszSpec.toDartString() == expectedPszSpec
        ? S_OK
        : E_FAIL;
  });
}

void setDefaultMocks(
    MockFileDialogController mockFileDialogController, int defaultReturnValue) {
  when(mockFileDialogController.setOptions(any)).thenReturn(defaultReturnValue);
  when(mockFileDialogController.getOptions(any)).thenReturn(defaultReturnValue);
  when(mockFileDialogController.setOkButtonLabel(any))
      .thenReturn(defaultReturnValue);
  when(mockFileDialogController.setFileName(any))
      .thenReturn(defaultReturnValue);
  when(mockFileDialogController.setFileTypes(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileDialogController.setFolder(any)).thenReturn(defaultReturnValue);
}
