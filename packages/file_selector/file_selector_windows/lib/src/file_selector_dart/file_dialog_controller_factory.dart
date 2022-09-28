// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:win32/win32.dart';

import 'file_dialog_controller.dart';
import 'ifile_dialog_controller_factory.dart';
import 'ifile_open_dialog_factory.dart';

/// Implementation of FileDialogControllerFactory that makes standard
/// FileDialogController instances.
class FileDialogControllerFactory implements IFileDialogControllerFactory {
  @override
  FileDialogController createController(IFileDialog dialog) {
    return FileDialogController(dialog, IFileOpenDialogFactory());
  }
}
