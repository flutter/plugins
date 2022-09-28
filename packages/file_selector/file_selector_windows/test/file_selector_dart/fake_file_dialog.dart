// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

// Fake IFileDialog class for testing purposes.
class FakeIFileDialog extends Fake implements IFileDialog {
  int _getOptionsCalledTimes = 0;
  int _getResultCalledTimes = 0;
  int _setOptionsCalledTimes = 0;
  int _setFolderCalledTimes = 0;
  int _setFileNameCalledTimes = 0;
  int _setFileTypesCalledTimes = 0;
  int _setOkButtonLabelCalledTimes = 0;
  int _showCalledTimes = 0;

  @override
  int getOptions(Pointer<Uint32> pfos) {
    _getOptionsCalledTimes++;
    return S_OK;
  }

  @override
  int setOptions(int options) {
    _setOptionsCalledTimes++;
    return S_OK;
  }

  @override
  int getResult(Pointer<Pointer<COMObject>> ppsi) {
    _getResultCalledTimes++;
    return S_OK;
  }

  @override
  int setFolder(Pointer<COMObject> psi) {
    _setFolderCalledTimes++;
    return S_OK;
  }

  @override
  int setFileTypes(int cFileTypes, Pointer<COMDLG_FILTERSPEC> rgFilterSpec) {
    _setFileTypesCalledTimes++;
    return S_OK;
  }

  @override
  int setFileName(Pointer<Utf16> pszName) {
    _setFileNameCalledTimes++;
    return S_OK;
  }

  @override
  int setOkButtonLabel(Pointer<Utf16> pszText) {
    _setOkButtonLabelCalledTimes++;
    return S_OK;
  }

  @override
  int show(int hwndOwner) {
    _showCalledTimes++;
    return S_OK;
  }

  void resetCounters() {
    _getOptionsCalledTimes = 0;
    _getResultCalledTimes = 0;
    _setOptionsCalledTimes = 0;
    _setFolderCalledTimes = 0;
    _setFileTypesCalledTimes = 0;
    _setOkButtonLabelCalledTimes = 0;
    _showCalledTimes = 0;
    _setFileNameCalledTimes = 0;
  }

  int getOptionsCalledTimes() {
    return _getOptionsCalledTimes;
  }

  int setOptionsCalledTimes() {
    return _setOptionsCalledTimes;
  }

  int getResultCalledTimes() {
    return _getResultCalledTimes;
  }

  int setFolderCalledTimes() {
    return _setFolderCalledTimes;
  }

  int setFileNameCalledTimes() {
    return _setFileNameCalledTimes;
  }

  int setFileTypesCalledTimes() {
    return _setFileTypesCalledTimes;
  }

  int setOkButtonLabelCalledTimes() {
    return _setOkButtonLabelCalledTimes;
  }

  int showCalledTimes() {
    return _showCalledTimes;
  }
}
