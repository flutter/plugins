// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dialog_mode.dart';
import 'dialog_wrapper.dart';
import 'ifile_dialog_controller_factory.dart';
import 'ifile_dialog_factory.dart';

/// Implementation of DialogWrapperFactory that provides [DialogWrapper] instances.
class DialogWrapperFactory {
  /// Creates a [DialogWrapperFactory] that makes use of [IFileDialogControllerFactory] and [IFileDialogFactory]
  /// to create [DialogWrapper] instances.
  DialogWrapperFactory(
    this._fileDialogControllerFactory,
    this._fileDialogFactory,
  );

  final IFileDialogControllerFactory _fileDialogControllerFactory;

  final IFileDialogFactory _fileDialogFactory;

  /// Creates a [DialogWrapper] based on [dialogMode].
  DialogWrapper createInstance(DialogMode dialogMode) {
    return DialogWrapper(
      _fileDialogControllerFactory,
      _fileDialogFactory,
      dialogMode,
    );
  }
}
