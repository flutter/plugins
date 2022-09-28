// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_windows/src/file_selector_dart/ifile_open_dialog_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

import 'fake_ifile_open_dialog.dart';

// Fake FakeIFileOpenDialogFactory class for testing purposes.
class FakeIFileOpenDialogFactory extends Fake
    implements IFileOpenDialogFactory {
  int _fromCalledTimes = 0;
  bool _shouldFail = false;

  final FakeIFileOpenDialog fakeIFileOpenDialog = FakeIFileOpenDialog();

  @override
  IFileOpenDialog from(IFileDialog dialog) {
    _fromCalledTimes += 1;
    if (_shouldFail) {
      throw WindowsException(E_NOINTERFACE);
    }

    return fakeIFileOpenDialog;
  }

  int getFromCalledTimes() {
    return _fromCalledTimes;
  }

  void mockSuccess() {
    _shouldFail = false;
  }

  void mockFailure() {
    _shouldFail = true;
  }
}
