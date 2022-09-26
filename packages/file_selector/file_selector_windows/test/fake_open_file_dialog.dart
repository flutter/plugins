// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

// Fake IOpenFileDialog class
class FakeIOpenFileDialog extends Fake implements IFileOpenDialog {
  int _getOptionsCalledTimes = 0;
  int _getResultCalledTimes = 0;
  int _setOptionsCalledTimes = 0;

  @override
  int getOptions(Pointer<Uint32> pfos) {
    _getOptionsCalledTimes++;
    return 0;
  }

  @override
  int setOptions(int options) {
    _setOptionsCalledTimes++;
    return 0;
  }

  @override
  int getResult(Pointer<Pointer<COMObject>> ppsi) {
    _getResultCalledTimes++;
    return 0;
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
}
