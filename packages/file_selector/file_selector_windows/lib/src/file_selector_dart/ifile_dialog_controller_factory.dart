// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:win32/win32.dart';

import 'file_dialog_controller.dart';

/// Interface for creating FileDialogControllers, to allow for dependency
/// injection.
abstract class IFileDialogControllerFactory {
  /// Returns a FileDialogController to interact with the given [IFileDialog].
  FileDialogController createController(IFileDialog dialog);
}
