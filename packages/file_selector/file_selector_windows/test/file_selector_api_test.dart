// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_windows/src/file_open_dialog_wrapper.dart';
import 'package:file_selector_windows/src/file_selector.dart';
import 'package:file_selector_windows/src/messages.g.dart';
import 'package:file_selector_windows/src/shell_item_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:win32/win32.dart';

import 'file_selector_api_test.mocks.dart';
import 'open_file_dialog_mock.dart';

@GenerateMocks(<Type>[FileOpenDialogWrapper, ShellItemWrapper])
void main() {
  const int defaultReturnValue = 1;
  const int successReturnValue = 0;
  const String defaultPath = 'C:';
  const List<String> expectedPaths = <String>[defaultPath];
  const List<String> expectedMultiplePaths = <String>[defaultPath, defaultPath];
  TestWidgetsFlutterBinding.ensureInitialized();
  final MockFileOpenDialogWrapper mockFileOpenDialogWrapper =
      MockFileOpenDialogWrapper();
  final MockShellItemWrapper mockShellItemWrapper = MockShellItemWrapper();
  late FileSelector api;
  late Pointer<Uint32> ptrOptions;
  late int hResult;
  late IFileOpenDialog mockFileOpenDialog;

  tearDown(() {
    reset(mockFileOpenDialogWrapper);
    reset(mockShellItemWrapper);
  });

  group('#Isolated functions', () {
    final TypeGroup imagesTypeGroup =
        TypeGroup(extensions: <String?>[], label: 'Images');
    final SelectionOptions singleFileSelectionOptions = SelectionOptions(
      allowMultiple: false,
      selectFolders: false,
      allowedTypes: <TypeGroup?>[imagesTypeGroup],
    );

    setUp(() {
      api = FileSelector(mockFileOpenDialogWrapper, mockShellItemWrapper);
      ptrOptions = calloc<Uint32>();
      final Pointer<COMObject> ptrCOMObject = calloc<COMObject>();
      hResult = 0;
      mockFileOpenDialog = MockOpenFileDialog(ptrCOMObject);
      setDefaultMocks(
          mockFileOpenDialogWrapper,
          mockShellItemWrapper,
          successReturnValue,
          defaultReturnValue,
          defaultPath,
          mockFileOpenDialog);
    });

    test('setDirectoryOptions should call dialog setOptions', () {
      final SelectionOptions selectionOptions = SelectionOptions(
          allowMultiple: false,
          selectFolders: true,
          allowedTypes: <TypeGroup>[]);
      expect(
          api.setDialogOptions(
              ptrOptions, selectionOptions, mockFileOpenDialog),
          defaultReturnValue);
      verify(mockFileOpenDialogWrapper.setOptions(any, any)).called(1);
    });

    test('getOptions should call dialog getOptions', () {
      expect(
          api.getOptions(ptrOptions, mockFileOpenDialog), defaultReturnValue);
      verify(mockFileOpenDialogWrapper.getOptions(
              ptrOptions, mockFileOpenDialog))
          .called(defaultReturnValue);
    });

    test('addConfirmButtonLabel should call dialog setOkButtonLabel', () {
      const String confirmationText = 'Text';
      expect(api.setOkButtonLabel(confirmationText, mockFileOpenDialog),
          defaultReturnValue);
      verify(mockFileOpenDialogWrapper.setOkButtonLabel(
              confirmationText, mockFileOpenDialog))
          .called(defaultReturnValue);
    });

    test('addFileFilters should call dialog setFileTypes', () {
      final TypeGroup typeGroup =
          TypeGroup(extensions: <String?>['jpg', 'png'], label: 'Images');

      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: true,
        allowedTypes: <TypeGroup?>[typeGroup],
      );

      final Map<String, String> filterSpecification = <String, String>{
        'Images': '*.jpg;*.png;',
      };

      expect(api.setFileTypeFilters(selectionOptions, mockFileOpenDialog),
          defaultReturnValue);
      verify(mockFileOpenDialogWrapper.setFileTypes(
              filterSpecification, mockFileOpenDialog))
          .called(1);
    });

    test(
        'invoking addFileFilters twice should call dialog setFileTypes with proper parameters',
        () {
      final TypeGroup typeGroup =
          TypeGroup(extensions: <String?>['jpg', 'png'], label: 'Images');

      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: true,
        allowedTypes: <TypeGroup?>[typeGroup],
      );

      final Map<String, String> filterSpecification = <String, String>{
        'Images': '*.jpg;*.png;',
      };

      expect(api.setFileTypeFilters(selectionOptions, mockFileOpenDialog),
          defaultReturnValue);
      expect(api.setFileTypeFilters(selectionOptions, mockFileOpenDialog),
          defaultReturnValue);
      verify(mockFileOpenDialogWrapper.setFileTypes(
              filterSpecification, mockFileOpenDialog))
          .called(2);
    });

    test(
        'addFileFilters should not call dialog setFileTypes if filterSpecification is empty',
        () {
      final TypeGroup typeGroup =
          TypeGroup(extensions: <String?>[], label: 'Images');

      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: true,
        allowedTypes: <TypeGroup?>[typeGroup],
      );

      expect(api.setFileTypeFilters(selectionOptions, mockFileOpenDialog),
          successReturnValue);
      verifyNever(
          mockFileOpenDialogWrapper.setFileTypes(any, mockFileOpenDialog));
    });

    test(
        'returnSelectedElements should call dialog getResult and should return selected path',
        () {
      expect(
          api.returnSelectedElements(
              hResult, singleFileSelectionOptions, mockFileOpenDialog),
          expectedPaths);
      verify(mockFileOpenDialogWrapper.getResult(any, mockFileOpenDialog))
          .called(1);
    });

    test(
        'returnSelectedElements should throw if dialog getResult returns an error',
        () {
      when(mockFileOpenDialogWrapper.getResult(any, any)).thenReturn(-1);
      expect(
          () => api.returnSelectedElements(
              hResult, singleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verify(mockFileOpenDialogWrapper.getResult(any, mockFileOpenDialog))
          .called(1);
      verifyNever(mockShellItemWrapper.getDisplayName(any, any));
    });

    test(
        'returnSelectedElements should throw if dialog getDisplayName returns an error',
        () {
      when(mockShellItemWrapper.getDisplayName(any, any)).thenReturn(-1);
      expect(
          () => api.returnSelectedElements(
              hResult, singleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verify(mockFileOpenDialogWrapper.getResult(any, mockFileOpenDialog))
          .called(1);
      verify(mockShellItemWrapper.getDisplayName(any, any)).called(1);
    });

    test(
        'returnSelectedElements should throw if dialog releaseItem returns an error',
        () {
      when(mockShellItemWrapper.releaseItem(any)).thenReturn(-1);
      expect(
          () => api.returnSelectedElements(
              hResult, singleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verify(mockFileOpenDialogWrapper.getResult(any, mockFileOpenDialog))
          .called(1);
      verify(mockShellItemWrapper.getDisplayName(any, any)).called(1);
      verify(mockShellItemWrapper.releaseItem(any)).called(1);
    });

    test(
        'returnSelectedElements should return without a path when the user cancels interaction',
        () {
      const int cancelledhResult = -2147023673;

      expect(
          api.returnSelectedElements(
              cancelledhResult, singleFileSelectionOptions, mockFileOpenDialog),
          <String>[]);

      verifyNever(mockFileOpenDialogWrapper.getResult(any, mockFileOpenDialog));
      verifyNever(mockShellItemWrapper.getDisplayName(any, any));
      verifyNever(mockShellItemWrapper.getUserSelectedPath(any));
    });

    test('returnSelectedElements should call dialog getDisplayName', () {
      expect(
          api.returnSelectedElements(
              hResult, singleFileSelectionOptions, mockFileOpenDialog),
          expectedPaths);
      verify(mockShellItemWrapper.getDisplayName(any, any)).called(1);
    });

    test('returnSelectedElements should call dialog getUserSelectedPath', () {
      expect(
          api.returnSelectedElements(
              hResult, singleFileSelectionOptions, mockFileOpenDialog),
          expectedPaths);
      verify(mockShellItemWrapper.getUserSelectedPath(any)).called(1);
    });

    test('setInitialDirectory should return param if initialDirectory is empty',
        () {
      expect(
          api.setInitialDirectory('', mockFileOpenDialog), successReturnValue);
    });

    test(
        'setInitialDirectory should return successReturnValue if initialDirectory is null',
        () {
      expect(api.setInitialDirectory(null, mockFileOpenDialog),
          successReturnValue);
    });

    test('setInitialDirectory should success when initialDirectory is valid',
        () {
      expect(api.setInitialDirectory(defaultPath, mockFileOpenDialog),
          successReturnValue);
    });

    test(
        'setInitialDirectory should throw WindowsException when initialDirectory is invalid',
        () {
      when(mockFileOpenDialogWrapper.createItemFromParsingName(any, any, any))
          .thenReturn(-1);
      expect(() => api.setInitialDirectory(':/', mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));
    });

    test('getSavePath should call setFileName', () {
      const String fileName = 'fileName';
      expect(
          api.getSavePath(
            suggestedFileName: fileName,
          ),
          defaultPath);
      verify(mockFileOpenDialogWrapper.setFileName(fileName, any)).called(1);
    });

    test('getSavePath should not call setFileName without a suggestedFileName',
        () {
      const String fileName = 'fileName';
      expect(
          api.getSavePath(
            confirmButtonText: 'Choose',
            initialDirectory: defaultPath,
          ),
          defaultPath);
      verifyNever(mockFileOpenDialogWrapper.setFileName(fileName, any));
    });

    test('getOptions should return 8 if fileMustExist is false', () {
      const int options = 6152;
      expect(api.getDialogOptions(options, singleFileSelectionOptions), 8);
    });

    test(
        'getOptions should return 520 if fileMustExist is false and allowMultiple is true',
        () {
      const int options = 6152;
      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: false,
        allowedTypes: <TypeGroup?>[imagesTypeGroup],
      );
      expect(api.getDialogOptions(options, selectionOptions), 520);
    });

    test(
        'getOptions should return 40 if fileMustExist is false and selectFolders is true',
        () {
      const int options = 6152;
      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: false,
        selectFolders: true,
        allowedTypes: <TypeGroup?>[imagesTypeGroup],
      );
      expect(api.getDialogOptions(options, selectionOptions), 40);
    });

    test('getOptions should return 6152 if fileMustExist is true', () {
      const int options = 6152;
      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: false,
        selectFolders: false,
        allowedTypes: <TypeGroup?>[imagesTypeGroup],
      );
      api.fileMustExist = true;
      expect(api.getDialogOptions(options, selectionOptions), 6152);
    });

    test(
        'getOptions should return 6664 if fileMustExist is true and allowMultiple is true',
        () {
      const int options = 6152;
      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: false,
        allowedTypes: <TypeGroup?>[imagesTypeGroup],
      );
      api.fileMustExist = true;
      expect(api.getDialogOptions(options, selectionOptions), 6664);
    });

    test(
        'getOptions should return 6184 if fileMustExist is true and selectFolders is true',
        () {
      const int options = 6152;
      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: false,
        selectFolders: true,
        allowedTypes: <TypeGroup?>[imagesTypeGroup],
      );
      api.fileMustExist = true;
      expect(api.getDialogOptions(options, selectionOptions), 6184);
    });

    test(
        'getOptions should return 6696 if fileMustExist is true, allowMultiple is true and selectFolders is true',
        () {
      const int options = 6152;
      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: true,
        allowedTypes: <TypeGroup?>[imagesTypeGroup],
      );
      api.fileMustExist = true;
      expect(api.getDialogOptions(options, selectionOptions), 6696);
    });

    test('getSavePath should call setFolder', () {
      expect(
          api.getSavePath(
            confirmButtonText: 'Choose',
            initialDirectory: defaultPath,
          ),
          defaultPath);
      verify(mockFileOpenDialogWrapper.setFolder(any, any)).called(1);
    });
  });

  group('#Multi file selection', () {
    final SelectionOptions multipleFileSelectionOptions = SelectionOptions(
      allowMultiple: true,
      selectFolders: false,
      allowedTypes: <TypeGroup?>[],
    );
    setUp(() {
      api = FileSelector(mockFileOpenDialogWrapper, mockShellItemWrapper);
      ptrOptions = calloc<Uint32>();
      final Pointer<COMObject> ptrCOMObject = calloc<COMObject>();
      hResult = 0;
      mockFileOpenDialog = MockOpenFileDialog(ptrCOMObject);
      setDefaultMocks(
          mockFileOpenDialogWrapper,
          mockShellItemWrapper,
          successReturnValue,
          defaultReturnValue,
          defaultPath,
          mockFileOpenDialog);
    });

    test(
        'returnSelectedElements should call dialog getResults and return the paths',
        () {
      mockGetCount(mockShellItemWrapper, 1);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedPaths);
      verify(mockFileOpenDialogWrapper.getResults(any, any)).called(1);
    });

    test(
        'returnSelectedElements should call createShellItemArray and return the paths',
        () {
      mockGetCount(mockShellItemWrapper, 1);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedPaths);
      verify(mockShellItemWrapper.createShellItemArray(any)).called(1);
    });

    test('returnSelectedElements should call getCount and return the paths',
        () {
      mockGetCount(mockShellItemWrapper, 1);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedPaths);
      verify(mockShellItemWrapper.getCount(any, any)).called(1);
    });

    test('returnSelectedElements should call getItemAt and return the paths',
        () {
      const int selectedFiles = 2;
      mockGetCount(mockShellItemWrapper, selectedFiles);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedMultiplePaths);
      verify(mockShellItemWrapper.getItemAt(any, any, any))
          .called(selectedFiles);
    });

    test('returnSelectedElements should call release and return the paths', () {
      const int selectedFiles = 2;
      mockGetCount(mockShellItemWrapper, selectedFiles);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedMultiplePaths);
      verify(mockShellItemWrapper.release(any)).called(selectedFiles);
    });

    test('returnSelectedElements should call createShellItem', () {
      const int selectedFiles = 2;
      mockGetCount(mockShellItemWrapper, selectedFiles);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedMultiplePaths);
      verify(mockShellItemWrapper.createShellItem(any)).called(selectedFiles);
    });

    test('returnSelectedElements should call getDisplayName', () {
      const int selectedFiles = 2;
      mockGetCount(mockShellItemWrapper, selectedFiles);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedMultiplePaths);
      verify(mockShellItemWrapper.getDisplayName(any, any))
          .called(selectedFiles);
    });

    test('returnSelectedElements should call getUserSelectedPath', () {
      const int selectedFiles = 2;
      mockGetCount(mockShellItemWrapper, selectedFiles);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedMultiplePaths);
      verify(mockShellItemWrapper.getUserSelectedPath(any))
          .called(selectedFiles);
    });

    test('returnSelectedElements should call releaseItem', () {
      const int selectedFiles = 2;
      mockGetCount(mockShellItemWrapper, selectedFiles);
      expect(
          api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          expectedMultiplePaths);
      verify(mockShellItemWrapper.releaseItem(any)).called(selectedFiles);
    });

    test(
        'returnSelectedElements should throw if dialog getResults returns an error',
        () {
      when(mockFileOpenDialogWrapper.getResults(any, any)).thenReturn(-1);

      expect(
          () => api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verifyNever(mockShellItemWrapper.createShellItemArray(any));
    });

    test('returnSelectedElements should throw if getItemAt returns an error',
        () {
      mockGetCount(mockShellItemWrapper, 1);
      when(mockShellItemWrapper.getItemAt(any, any, any)).thenReturn(-1);

      expect(
          () => api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verifyNever(mockShellItemWrapper.createShellItem(any));
    });

    test(
        'returnSelectedElements should throw if getDisplayName returns an error',
        () {
      mockGetCount(mockShellItemWrapper, 1);
      when(mockShellItemWrapper.getDisplayName(any, any)).thenReturn(-1);

      expect(
          () => api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verifyNever(mockShellItemWrapper.getUserSelectedPath(any));
    });

    test('returnSelectedElements should throw if releaseItem returns an error',
        () {
      mockGetCount(mockShellItemWrapper, 1);
      when(mockShellItemWrapper.releaseItem(any)).thenReturn(-1);

      expect(
          () => api.returnSelectedElements(
              hResult, multipleFileSelectionOptions, mockFileOpenDialog),
          throwsA(predicate((Object? e) => e is WindowsException)));

      verifyNever(mockShellItemWrapper.release(any));
    });
  });

  group('#Public facing functions', () {
    setUp(() {
      api = FileSelector(mockFileOpenDialogWrapper, mockShellItemWrapper);
      setDefaultMocks(
          mockFileOpenDialogWrapper,
          mockShellItemWrapper,
          successReturnValue,
          defaultReturnValue,
          defaultPath,
          mockFileOpenDialog);
    });

    test('getDirectory should return selected path', () {
      expect(defaultPath, api.getDirectoryPath());
    });

    test('getFile should return selected path', () {
      final TypeGroup typeGroup =
          TypeGroup(extensions: <String?>['jpg'], label: 'Images');

      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: false,
        selectFolders: false,
        allowedTypes: <TypeGroup?>[typeGroup],
      );
      expect(
          api.getFiles(
              selectionOptions: selectionOptions,
              initialDirectory: 'c:',
              confirmButtonText: 'Choose'),
          expectedPaths);
    });

    test('getFile with multiple selection should return selected paths', () {
      mockGetCount(mockShellItemWrapper, 2);
      final TypeGroup typeGroup =
          TypeGroup(extensions: <String?>['jpg'], label: 'Images');

      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: true,
        selectFolders: false,
        allowedTypes: <TypeGroup?>[typeGroup],
      );
      expect(
          api.getFiles(
              selectionOptions: selectionOptions,
              initialDirectory: 'c:',
              confirmButtonText: 'Choose'),
          expectedMultiplePaths);
    });

    test('getSavePath should return full path with file name and extension',
        () {
      const String fileName = 'file.txt';
      when(mockShellItemWrapper.getUserSelectedPath(any))
          .thenReturn('$defaultPath$fileName');
      final TypeGroup typeGroup =
          TypeGroup(extensions: <String?>['txt'], label: 'Text');

      final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: false,
        selectFolders: false,
        allowedTypes: <TypeGroup?>[typeGroup],
      );
      expect(
          api.getSavePath(
              confirmButtonText: 'Choose',
              initialDirectory: defaultPath,
              selectionOptions: selectionOptions,
              suggestedFileName: fileName),
          '$defaultPath$fileName');
    });
  });
}

void mockGetCount(
    MockShellItemWrapper mockShellItemWrapper, int numberOfElements) {
  when(mockShellItemWrapper.getCount(any, any))
      .thenAnswer((Invocation realInvocation) {
    final Pointer<Uint32> pointer =
        realInvocation.positionalArguments.first as Pointer<Uint32>;
    pointer.value = numberOfElements;
  });
}

void setDefaultMocks(
    MockFileOpenDialogWrapper mockFileOpenDialogWrapper,
    MockShellItemWrapper mockShellItemWrapper,
    int successReturnValue,
    int defaultReturnValue,
    String defaultPath,
    IFileOpenDialog dialog) {
  final Pointer<Pointer<COMObject>> ppsi = calloc<Pointer<COMObject>>();
  when(mockFileOpenDialogWrapper.setOptions(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.getOptions(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.setOkButtonLabel(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.setFileTypes(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.show(any, any)).thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.getResult(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.getResults(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.release(any)).thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.setFolder(any, any))
      .thenReturn(successReturnValue);
  when(mockFileOpenDialogWrapper.setFileName(any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.createItemFromParsingName(any, any, any))
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.coInitializeEx())
      .thenReturn(defaultReturnValue);
  when(mockFileOpenDialogWrapper.createInstance()).thenReturn(dialog);
  when(mockShellItemWrapper.createShellItem(any))
      .thenReturn(IShellItem(ppsi.cast()));
  when(mockShellItemWrapper.createShellItemArray(any))
      .thenReturn(IShellItemArray(ppsi.cast()));

  when(mockShellItemWrapper.getDisplayName(any, any))
      .thenReturn(defaultReturnValue);
  when(mockShellItemWrapper.getUserSelectedPath(any)).thenReturn(defaultPath);
  when(mockShellItemWrapper.releaseItem(any)).thenReturn(defaultReturnValue);
  when(mockShellItemWrapper.getItemAt(any, any, any))
      .thenReturn(defaultReturnValue);
  free(ppsi);
}
