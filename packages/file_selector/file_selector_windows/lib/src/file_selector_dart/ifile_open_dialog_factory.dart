// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:win32/win32.dart';

/// A wrapper of the IFileOpenDialog interface to use its from function.
class IFileOpenDialogFactory {
  /// Wraps the IFileOpenDialog from function.
  IFileOpenDialog from(IFileDialog fileDialog) {
    return IFileOpenDialog.from(fileDialog);
  }
}
