// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:win32/win32.dart';

import 'dialog_mode.dart';

/// A factory for [IFileDialog] instances.
class IFileDialogFactory {
  /// Creates the corresponding IFileDialog instance. The caller is responsible of releasing the resource.
  IFileDialog createInstance(DialogMode dialogMode) {
    switch (dialogMode) {
      case DialogMode.open:
        return FileOpenDialog.createInstance();
      case DialogMode.save:
        return FileSaveDialog.createInstance();
    }
  }
}
