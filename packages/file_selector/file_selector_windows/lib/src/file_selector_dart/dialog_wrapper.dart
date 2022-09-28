// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
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
  DialogWrapper(
    IFileDialogControllerFactory fileDialogControllerFactory,
    IFileDialogFactory fileDialogFactory,
    this._dialogMode,
  ) : _isOpenDialog = _dialogMode == DialogMode.open {
    try {
      final IFileDialog dialog = fileDialogFactory.createInstance(_dialogMode);
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
  DialogWrapper.withFakeDependencies(
    FileDialogController dialogController,
    this._dialogMode,
    this._shellWin32Api,
  )   : _isOpenDialog = _dialogMode == DialogMode.open,
        _dialogController = dialogController;

  final DialogMode _dialogMode;

  final bool _isOpenDialog;

  late final FileDialogController _dialogController;

  late final ShellWin32Api _shellWin32Api;

  static const String _allowAnyValue = 'Any';

  static const String _allowAnyExtension = '*.*';

  /// Returns the result of the last Win32 API call related to this object.
  int get lastResult => _lastResult;

  int _lastResult = S_OK;

  /// Attempts to set the default folder for the dialog to [path], if it exists.
  void setFolder(String path) {
    if (path.isEmpty) {
      return;
    }

    using((Arena arena) {
      final Pointer<GUID> ptrGuid = GUIDFromString(
        IID_IShellItem,
        allocator: arena,
      );
      final Pointer<Pointer<COMObject>> ptrPath = arena<Pointer<COMObject>>();
      _lastResult = _shellWin32Api.createItemFromParsingName(
        path.toNativeUtf16(allocator: arena),
        ptrGuid,
        ptrPath,
      );

      if (!SUCCEEDED(_lastResult)) {
        return;
      }

      _lastResult = _dialogController.setFolder(ptrPath.value);
    });
  }

  /// Sets the file name that is initially shown in the dialog.
  void setFileName(String name) {
    _lastResult = _dialogController.setFileName(name);
  }

  /// Sets the label of the confirmation button.
  void setOkButtonLabel(String label) {
    _lastResult = _dialogController.setOkButtonLabel(label);
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
          ..pszName = key.toNativeUtf16(allocator: arena)
          ..pszSpec = filterSpecification[key]!.toNativeUtf16(allocator: arena);
        index += 1;
      }

      _lastResult = _dialogController.setFileTypes(
        filterSpecification.length,
        registerFilterSpecification,
      );
    });
  }

  /// Releases the IFileDialog resource.
  /// This method should be called after using the the DialogWrapper
  int release() {
    return _dialogController.release();
  }

  /// Displays the dialog, and returns the selected files, or null on error.
  List<String?>? show(int parentWindow) {
    _lastResult = _dialogController.show(parentWindow);
    if (!SUCCEEDED(_lastResult)) {
      return null;
    }

    return using((Arena arena) {
      final Pointer<Pointer<COMObject>> shellItemArrayPtr =
          arena<Pointer<COMObject>>();
      final Pointer<Uint32> shellItemCountPtr = arena<Uint32>();
      final Pointer<Pointer<COMObject>> shellItemPtr =
          arena<Pointer<COMObject>>();

      return _getFilePathList(
          shellItemArrayPtr, shellItemCountPtr, shellItemPtr);
    });
  }

  List<String>? _getFilePathList(
      Pointer<Pointer<COMObject>> shellItemArrayPtr,
      Pointer<Uint32> shellItemCountPtr,
      Pointer<Pointer<COMObject>> shellItemPtr) {
    try {
      final List<String> files = <String>[];
      int lastOperationResult;
      if (_isOpenDialog) {
        lastOperationResult = _dialogController.getResults(shellItemArrayPtr);
        if (!SUCCEEDED(lastOperationResult)) {
          throw WindowsException(lastOperationResult);
        }

        final IShellItemArray shellItemResources =
            IShellItemArray(shellItemArrayPtr.cast());
        lastOperationResult = shellItemResources.getCount(shellItemCountPtr);
        if (!SUCCEEDED(lastOperationResult)) {
          throw WindowsException(lastOperationResult);
        }
        for (int index = 0; index < shellItemCountPtr.value; index += 1) {
          shellItemResources.getItemAt(index, shellItemPtr);
          final IShellItem shellItem = IShellItem(shellItemPtr.cast());
          files.add(_shellWin32Api.getPathForShellItem(shellItem));
          _shellWin32Api.releaseShellItem(shellItem);
        }
      } else {
        lastOperationResult = _dialogController.getResult(shellItemPtr);
        if (!SUCCEEDED(lastOperationResult)) {
          throw WindowsException(lastOperationResult);
        }
        final IShellItem shellItem = IShellItem(shellItemPtr.cast());
        files.add(_shellWin32Api.getPathForShellItem(shellItem));
        _shellWin32Api.releaseShellItem(shellItem);
      }
      return files;
    } on WindowsException catch (ex) {
      _lastResult = ex.hr;
      return null;
    }
  }
}
