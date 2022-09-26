// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

// Fake IShellItemArray class
class FakeIShellItem extends Fake implements IShellItem {
  int _getDisplayNameCalledTimes = 0;
  int _releaseCalledTimes = 0;

  @override
  int getDisplayName(int sigdnName, Pointer<Pointer<Utf16>> ppszName) {
    _getDisplayNameCalledTimes++;
    return 0;
  }

  @override
  int release() {
    _releaseCalledTimes++;
    return 0;
  }

  int getDisplayNameCalledTimes() {
    return _getDisplayNameCalledTimes;
  }

  int releaseCalledTimes() {
    return _releaseCalledTimes;
  }
}
