// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

// Fake IShellItemArray class
class FakeIShellItemArray extends Fake implements IShellItemArray {
  int _getCountCalledTimes = 0;
  int _getItemAtCalledTimes = 0;
  int _releaseCalledTimes = 0;

  @override
  int getCount(Pointer<Uint32> ptrCount) {
    _getCountCalledTimes++;
    return 0;
  }

  @override
  int getItemAt(int dwIndex, Pointer<Pointer<COMObject>> ppsi) {
    _getItemAtCalledTimes++;
    return 0;
  }

  @override
  int release() {
    _releaseCalledTimes++;
    return 0;
  }

  int getCountCalledTimes() {
    return _getCountCalledTimes;
  }

  int getItemAtCalledTimes() {
    return _getItemAtCalledTimes;
  }

  int releaseCalledTimes() {
    return _releaseCalledTimes;
  }
}
