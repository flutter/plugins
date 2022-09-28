// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:win32/win32.dart';

import 'dialog_mode.dart';

/// A factory for [IFileDialog] instances.
class IFileDialogFactory {
  /// Creates the corresponding IFileDialog instace. The caller is responsible of releasing the resource.
  IFileDialog createInstace(DialogMode dialogMode) {
    if (dialogMode == DialogMode.Open) {
      return FileOpenDialog.createInstance();
    }

    return FileSaveDialog.createInstance();
  }
}
