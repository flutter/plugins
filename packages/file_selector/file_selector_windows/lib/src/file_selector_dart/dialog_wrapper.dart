// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:win32/win32.dart';

import 'dialog_mode.dart';
import 'file_dialog_controller.dart';
import 'ifile_dialog_controller_factory.dart';
import 'ifile_dialog_factory.dart';
import 'shell_win32_api.dart';

/// Wraps an IFileDialog, managing object lifetime as a scoped object and
/// providing a simplified API for interacting with it as needed for the plugin.
class DialogWrapper {
  /// Creates a DialogWrapper using a [IFileDialogControllerFactory] and a [DialogMode].
  /// It is also responsible of creating a [IFileDialog].
  DialogWrapper(IFileDialogControllerFactory fileDialogControllerFactory,
      IFileDialogFactory fileDialogFactory, this._dialogMode)
      : _isOpenDialog = _dialogMode == DialogMode.Open {
    try {
      final IFileDialog dialog = fileDialogFactory.createInstace(_dialogMode);
      _dialogController = fileDialogControllerFactory.createController(dialog);
      _shellWin32Api = ShellWin32Api();
    } catch (ex) {
      if (ex is WindowsException) {
        _lastResult = ex.hr;
      }
    }
  }

  /// Creates a DialogWrapper for testing purposes.
  @visibleForTesting
  DialogWrapper.withFakeDependencies(FileDialogController dialogController,
      this._dialogMode, this._shellWin32Api)
      : _isOpenDialog = _dialogMode == DialogMode.Open,
        _dialogController = dialogController;

  int _lastResult = S_OK;

  final DialogMode _dialogMode;

  final bool _isOpenDialog;

  final String _allowAnyValue = 'Any';

  final String _allowAnyExtension = '*.*';

  late FileDialogController _dialogController;

  late ShellWin32Api _shellWin32Api;

  /// Returns the result of the last Win32 API call related to this object.
  int get lastResult => _lastResult;

  /// Attempts to set the default folder for the dialog to [path], if it exists.
  void setFolder(String path) {
    if (path == null || path.isEmpty) {
      return;
    }

    using((Arena arena) {
      final Pointer<GUID> ptrGuid = GUIDFromString(IID_IShellItem);
      final Pointer<Pointer<COMObject>> ptrPath = arena<Pointer<COMObject>>();
      _lastResult =
          _shellWin32Api.createItemFromParsingName(path, ptrGuid, ptrPath);

      if (!SUCCEEDED(_lastResult)) {
        return;
      }

      _dialogController.setFolder(ptrPath.value);
    });
  }

  /// Sets the file name that is initially shown in the dialog.
  void setFileName(String name) {
    _dialogController.setFileName(name);
  }

  /// Sets the label of the confirmation button.
  void setOkButtonLabel(String label) {
    _dialogController.setOkButtonLabel(label);
  }

  /// Adds the given options to the dialog's current [options](https://pub.dev/documentation/win32/latest/winrt/FILEOPENDIALOGOPTIONS-class.html).
  /// Both are bitfields.
  void addOptions(int newOptions) {
    using((Arena arena) {
      final Pointer<Uint32> currentOptions = arena<Uint32>();
      _lastResult = _dialogController.getOptions(currentOptions);
      if (!SUCCEEDED(_lastResult)) {
        return;
      }
      currentOptions.value |= newOptions;
      _lastResult = _dialogController.setOptions(currentOptions.value);
    });
  }

  /// Sets the filters for allowed file types to select.
  /// filters -> std::optional<EncodableList>
  void setFileTypeFilters(List<XTypeGroup> filters) {
    final Map<String, String> filterSpecification = <String, String>{};

    if (filters.isEmpty) {
      filterSpecification[_allowAnyValue] = _allowAnyExtension;
    } else {
      for (final XTypeGroup option in filters) {
        final String? label = option.label;
        if (option.allowsAny || option.extensions!.isEmpty) {
          filterSpecification[label ?? _allowAnyValue] = _allowAnyExtension;
        } else {
          final String extensionsForLabel = option.extensions!
              .map((String extension) => '*.$extension')
              .join(';');
          filterSpecification[label ?? extensionsForLabel] = extensionsForLabel;
        }
      }
    }

    using((Arena arena) {
      final Pointer<COMDLG_FILTERSPEC> registerFilterSpecification =
          arena<COMDLG_FILTERSPEC>(filterSpecification.length);

      int index = 0;
      for (final String key in filterSpecification.keys) {
        registerFilterSpecification[index]
          ..pszName = TEXT(key)
          ..pszSpec = TEXT(filterSpecification[key]!);
        index++;
      }

      _lastResult = _dialogController.setFileTypes(
          filterSpecification.length, registerFilterSpecification);
    });
  }

  /// Displays the dialog, and returns the selected files, or null on error.
  List<String?>? show(int parentWindow) {
    _lastResult = _dialogController.show(parentWindow);
    if (!SUCCEEDED(_lastResult)) {
      return null;
    }
    late List<String>? files;

    using((Arena arena) {
      final Pointer<Pointer<COMObject>> shellItemArrayPtr =
          arena<Pointer<COMObject>>();
      final Pointer<Uint32> shellItemCountPtr = arena<Uint32>();
      final Pointer<Pointer<COMObject>> shellItemPtr =
          arena<Pointer<COMObject>>();

      files =
          _getFilePathList(shellItemArrayPtr, shellItemCountPtr, shellItemPtr);
    });
    return files;
  }

  List<String>? _getFilePathList(
      Pointer<Pointer<COMObject>> shellItemArrayPtr,
      Pointer<Uint32> shellItemCountPtr,
      Pointer<Pointer<COMObject>> shellItemPtr) {
    final List<String> files = <String>[];
    if (_isOpenDialog) {
      _lastResult = _dialogController.getResults(shellItemArrayPtr);
      if (!SUCCEEDED(_lastResult)) {
        return null;
      }

      final IShellItemArray shellItemResources =
          IShellItemArray(shellItemArrayPtr.cast());
      _lastResult = shellItemResources.getCount(shellItemCountPtr);
      if (!SUCCEEDED(_lastResult)) {
        return null;
      }
      for (int index = 0; index < shellItemCountPtr.value; index++) {
        shellItemResources.getItemAt(index, shellItemPtr);
        final IShellItem shellItem = IShellItem(shellItemPtr.cast());
        files.add(_shellWin32Api.getPathForShellItem(shellItem));
      }
    } else {
      _lastResult = _dialogController.getResult(shellItemPtr);
      if (!SUCCEEDED(_lastResult)) {
        return null;
      }
      final IShellItem shellItem = IShellItem(shellItemPtr.cast());
      files.add(_shellWin32Api.getPathForShellItem(shellItem));
    }
    return files;
  }
}
