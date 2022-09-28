// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:win32/win32.dart';

import 'ifile_open_dialog_factory.dart';

/// A thin wrapper for IFileDialog to allow for faking and inspection in tests.
///
/// Since this class defines the end of what can be unit tested, it should
/// contain as little logic as possible.
class FileDialogController {
  /// Creates a controller managing [IFileDialog](https://pub.dev/documentation/win32/latest/winrt/IFileDialog-class.html).
  /// It also receives an IFileOpenDialogFactory to construct [IFileOpenDialog]
  /// instances.
  FileDialogController(
      IFileDialog fileDialog, IFileOpenDialogFactory iFileOpenDialogFactory)
      : _fileDialog = fileDialog,
        _iFileOpenDialogFactory = iFileOpenDialogFactory;

  /// The [IFileDialog] to work with.
  final IFileDialog _fileDialog;

  /// The [IFileOpenDialogFactory] to work construc [IFileOpenDialog] instances.
  final IFileOpenDialogFactory _iFileOpenDialogFactory;

  /// Sets the default folder for the dialog to [path]. It also returns the operation result.
  int setFolder(Pointer<COMObject> path) {
    return _fileDialog.setFolder(path);
  }

  /// Sets the file [name] that is initially shown in the IFileDialog. It also returns the operation result.
  int setFileName(String name) {
    return _fileDialog.setFileName(TEXT(name));
  }

  /// Sets the allowed file type extensions in the IFileOpenDialog. It also returns the operation result.
  int setFileTypes(int count, Pointer<COMDLG_FILTERSPEC> filters) {
    return _fileDialog.setFileTypes(count, filters);
  }

  /// Sets the label of the confirmation button. It also returns the operation result. It also returns the operation result.
  int setOkButtonLabel(String text) {
    return _fileDialog.setOkButtonLabel(TEXT(text));
  }

  /// Gets the IFileDialog's [options](https://pub.dev/documentation/win32/latest/winrt/FILEOPENDIALOGOPTIONS-class.html),
  /// which is a bitfield. It also returns the operation result.
  int getOptions(Pointer<Uint32> outOptions) {
    return _fileDialog.getOptions(outOptions);
  }

  /// Sets the [options](https://pub.dev/documentation/win32/latest/winrt/FILEOPENDIALOGOPTIONS-class.html),
  /// which is a bitfield, into the IFileDialog. It also returns the operation result.
  int setOptions(int options) {
    return _fileDialog.setOptions(options);
  }

  /// Shows an IFileDialog using the given parent. It returns the operation result.
  int show(int parent) {
    return _fileDialog.show(parent);
  }

  /// Return results from an IFileDialog. This should be used when selecting
  /// single items. It also returns the operation result.
  int getResult(Pointer<Pointer<COMObject>> outItem) {
    return _fileDialog.getResult(outItem);
  }

  /// Return results from an IFileOpenDialog. This should be used when selecting
  /// single items. This function will fail if the IFileDialog* provided to the
  /// constructor was not an IFileOpenDialog instance, returning an E_FAIL
  /// error.
  int getResults(Pointer<Pointer<COMObject>> outItems) {
    IFileOpenDialog? fileOpenDialog;
    try {
      fileOpenDialog = _iFileOpenDialogFactory.from(_fileDialog);
      return fileOpenDialog.getResults(outItems);
    } catch (_) {
      return E_FAIL;
    } finally {
      fileOpenDialog?.release();
      if (fileOpenDialog != null) {
        free(fileOpenDialog.ptr);
      }
    }
  }
}
