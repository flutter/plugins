// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

// Fake IFileOpenDialog class for testing purposes.
class FakeIFileOpenDialog extends Fake implements IFileOpenDialog {
  int _getResultsCalledTimes = 0;
  int _getReleaseCalledTimes = 0;
  bool _shouldFail = false;

  @override
  Pointer<COMObject> get ptr => nullptr;

  @override
  int release() {
    _getReleaseCalledTimes += 1;
    return S_OK;
  }

  @override
  int getResults(Pointer<Pointer<COMObject>> ppsi) {
    _getResultsCalledTimes += 1;
    if (_shouldFail) {
      throw WindowsException(E_FAIL);
    }

    return S_OK;
  }

  void resetCounters() {
    _getResultsCalledTimes = 0;
    _getReleaseCalledTimes = 0;
  }

  int getResultsCalledTimes() => _getResultsCalledTimes;

  int getReleaseCalledTimes() => _getReleaseCalledTimes;

  void mockFailure() => _shouldFail = true;

  void mockSuccess() => _shouldFail = false;
}
