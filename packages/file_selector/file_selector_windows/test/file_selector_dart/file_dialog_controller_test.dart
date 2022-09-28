// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_windows/src/file_selector_dart/file_dialog_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

import 'fake_file_dialog.dart';
import 'fake_ifile_open_dialog_factory.dart';

void main() {
  final FakeIFileDialog fakeFileOpenDialog = FakeIFileDialog();
  final FakeIFileOpenDialogFactory fakeIFileOpenDialogFactory =
      FakeIFileOpenDialogFactory();
  final FileDialogController fileDialogController =
      FileDialogController(fakeFileOpenDialog, fakeIFileOpenDialogFactory);

  setUp(() {
    fakeIFileOpenDialogFactory.mockSuccess();
    fakeIFileOpenDialogFactory.fakeIFileOpenDialog.mockSuccess();
  });

  tearDown(() {
    fakeFileOpenDialog.resetCounters();
    fakeIFileOpenDialogFactory.fakeIFileOpenDialog.resetCounters();
  });

  test('setFolder should call dialog setFolder', () {
    final Pointer<COMObject> ptrFolder = calloc<COMObject>();
    fileDialogController.setFolder(ptrFolder);
    free(ptrFolder);
    expect(fakeFileOpenDialog.setFolderCalledTimes(), 1);
  });

  test('setFileName should call dialog setFileName', () {
    fileDialogController.setFileName('fileName');
    expect(fakeFileOpenDialog.setFileNameCalledTimes(), 1);
  });

  test('setFileTypes should call dialog setFileTypes', () {
    final Pointer<COMDLG_FILTERSPEC> ptrFilters = calloc<COMDLG_FILTERSPEC>();
    fileDialogController.setFileTypes(1, ptrFilters);
    free(ptrFilters);
    expect(fakeFileOpenDialog.setFileTypesCalledTimes(), 1);
  });

  test('setOkButtonLabel should call dialog setOkButtonLabel', () {
    fileDialogController.setOkButtonLabel('button');
    expect(fakeFileOpenDialog.setOkButtonLabelCalledTimes(), 1);
  });

  test('show should call dialog show', () {
    fileDialogController.show(0);
    expect(fakeFileOpenDialog.showCalledTimes(), 1);
  });

  test('getOptions should call dialog getOptions', () {
    final Pointer<Uint32> ptrOptions = calloc<Uint32>();
    fileDialogController.getOptions(ptrOptions);
    free(ptrOptions);
    expect(fakeFileOpenDialog.getOptionsCalledTimes(), 1);
  });

  test('setOptions should call dialog setOptions', () {
    fileDialogController.setOptions(32);
    expect(fakeFileOpenDialog.setOptionsCalledTimes(), 1);
  });

  test('getResult should call dialog getResult', () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fileDialogController.getResult(ptrCOMObject);
    free(ptrCOMObject);
    expect(fakeFileOpenDialog.getResultCalledTimes(), 1);
  });

  test('getResults should call the from method of the factory', () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fileDialogController.getResults(ptrCOMObject);
    free(ptrCOMObject);
    expect(fakeIFileOpenDialogFactory.getFromCalledTimes(), 1);
  });

  test('getResults should call dialog getResults', () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fileDialogController.getResults(ptrCOMObject);
    free(ptrCOMObject);
    expect(
        fakeIFileOpenDialogFactory.fakeIFileOpenDialog.getResultsCalledTimes(),
        1);
  });

  test(
      'getResults should return an error when building a file open dialog throws',
      () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fakeIFileOpenDialogFactory.mockFailure();
    free(ptrCOMObject);
    expect(fileDialogController.getResults(ptrCOMObject), E_FAIL);
  });

  test(
      'getResults should return an error and release the dialog when getting results throws',
      () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fakeIFileOpenDialogFactory.fakeIFileOpenDialog.mockFailure();
    free(ptrCOMObject);
    expect(fileDialogController.getResults(ptrCOMObject), E_FAIL);
    expect(
        fakeIFileOpenDialogFactory.fakeIFileOpenDialog.getReleaseCalledTimes(),
        1);
  });

  test('getResults should call dialog release', () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fileDialogController.getResults(ptrCOMObject);
    free(ptrCOMObject);
    expect(
        fakeIFileOpenDialogFactory.fakeIFileOpenDialog.getReleaseCalledTimes(),
        1);
  });
}
