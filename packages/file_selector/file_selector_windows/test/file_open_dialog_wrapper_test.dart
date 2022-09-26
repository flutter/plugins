// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_windows/src/file_open_dialog_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

import 'fake_open_file_dialog.dart';

void main() {
  final FileOpenDialogWrapper fileOpenDialogWrapper = FileOpenDialogWrapper();
  final FakeIOpenFileDialog fakeFileOpenDialog = FakeIOpenFileDialog();

  test('getOptions should call dialog getOptions', () {
    final Pointer<Uint32> ptrOptions = calloc<Uint32>();
    fileOpenDialogWrapper.getOptions(ptrOptions, fakeFileOpenDialog);
    expect(fakeFileOpenDialog.getOptionsCalledTimes(), 1);
    free(ptrOptions);
  });

  test('setOptions should call dialog setOptions', () {
    fileOpenDialogWrapper.setOptions(32, fakeFileOpenDialog);
    expect(fakeFileOpenDialog.setOptionsCalledTimes(), 1);
  });

  test('getResult should call dialog getResult', () {
    final Pointer<Pointer<COMObject>> ptrCOMObject =
        calloc<Pointer<COMObject>>();
    fileOpenDialogWrapper.getResult(ptrCOMObject, fakeFileOpenDialog);
    expect(fakeFileOpenDialog.getResultCalledTimes(), 1);
    free(ptrCOMObject);
  });
}
