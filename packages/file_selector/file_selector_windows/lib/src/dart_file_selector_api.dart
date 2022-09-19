// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:file_selector_windows/src/messages.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:win32/win32.dart';

import 'dart_file_dialog.dart';
import 'dart_file_open_dialog_api.dart';
import 'dart_shell_item_api.dart';

/// Dart native implementation of FileSelectorAPI
class DartFileSelectorAPI extends FileDialog {
  /// We need the file to exist. This value defaults to `false`.
  DartFileSelectorAPI(
      [FileOpenDialogAPI? fileOpenDialogAPI, ShellItemAPI? shellItemAPI])
      : super() {
    _fileOpenDialogAPI = fileOpenDialogAPI ?? FileOpenDialogAPI();
    _shellItemAPI = shellItemAPI ?? ShellItemAPI();
  }

  late FileOpenDialogAPI _fileOpenDialogAPI;
  late ShellItemAPI _shellItemAPI;

  /// Returns a directory path from user selection.
  String? getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) {
    fileMustExist = true;
    final SelectionOptions selectionOptions = SelectionOptions(
        allowMultiple: false, selectFolders: true, allowedTypes: <TypeGroup>[]);
    return _getDirectory(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        selectionOptions: selectionOptions);
  }

  /// Returns a full path, including file name and it's extension, from user selection.
  String? getSavePath({
    String? initialDirectory,
    String? confirmButtonText,
    String? suggestedFileName,
    SelectionOptions? selectionOptions,
  }) {
    fileMustExist = false;
    final SelectionOptions defaultSelectionOptions = SelectionOptions(
        allowMultiple: false, selectFolders: true, allowedTypes: <TypeGroup>[]);
    return _getDirectory(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        suggestedFileName: suggestedFileName,
        selectionOptions: selectionOptions ?? defaultSelectionOptions);
  }

  /// Returns a list of file paths.
  List<String> getFiles(
      {String? initialDirectory,
      String? confirmButtonText,
      required SelectionOptions selectionOptions}) {
    fileMustExist = false;
    int hResult = initializeComLibrary();
    final IFileOpenDialog fileDialog = FileOpenDialog.createInstance();
    using((Arena arena) {
      final Pointer<Uint32> ptrOptions = arena<Uint32>();

      hResult = getOptions(ptrOptions, fileDialog);
      hResult = setDialogOptions(ptrOptions, selectionOptions, fileDialog);
    });

    hResult = setInitialDirectory(initialDirectory, fileDialog);
    hResult = addFileFilters(selectionOptions, fileDialog);
    hResult = addConfirmButtonLabel(confirmButtonText, fileDialog);
    hResult = _fileOpenDialogAPI.show(hWndOwner, fileDialog);

    return returnSelectedElements(hResult, selectionOptions, fileDialog);
  }

  /// Returns dialog options.
  @visibleForTesting
  int getOptions(Pointer<Uint32> ptrOptions, IFileOpenDialog dialog) {
    final int hResult = _fileOpenDialogAPI.getOptions(ptrOptions, dialog);
    _validateResult(hResult);

    return hResult;
  }

  /// Returns the dialog option based on conditions.
  @visibleForTesting
  int getDialogOptions(int options, SelectionOptions selectionOptions) {
    if (!fileMustExist) {
      options &= ~FILEOPENDIALOGOPTIONS.FOS_PATHMUSTEXIST;
      options &= ~FILEOPENDIALOGOPTIONS.FOS_FILEMUSTEXIST;
    }

    if (selectionOptions.selectFolders) {
      options |= FILEOPENDIALOGOPTIONS.FOS_PICKFOLDERS;
    }

    if (selectionOptions.allowMultiple) {
      options |= FILEOPENDIALOGOPTIONS.FOS_ALLOWMULTISELECT;
    }

    return options;
  }

  /// Sets and checks options for the dialog.
  @visibleForTesting
  int setDialogOptions(Pointer<Uint32> ptrOptions,
      SelectionOptions selectionOptions, IFileOpenDialog dialog) {
    final int options = getDialogOptions(ptrOptions.value, selectionOptions);

    final int hResult = _fileOpenDialogAPI.setOptions(options, dialog);

    _validateResult(hResult);

    return hResult;
  }

  /// Sets the initial directory to open the dialog
  @visibleForTesting
  int setInitialDirectory(String? initialDirectory, IFileOpenDialog dialog) {
    int hResult = 0;

    if (initialDirectory == null || initialDirectory.isEmpty) {
      return hResult;
    }

    using((Arena arena) {
      final Pointer<GUID> ptrGuid = GUIDFromString(IID_IShellItem);
      final Pointer<Pointer<COMObject>> ptrPath = arena<Pointer<COMObject>>();
      hResult = _fileOpenDialogAPI.createItemFromParsingName(
          initialDirectory, ptrGuid, ptrPath);

      _validateResult(hResult);

      hResult = _fileOpenDialogAPI.setFolder(ptrPath, dialog);

      _validateResult(hResult);
    });

    return hResult;
  }

  /// Initialices the com library
  @visibleForTesting
  int initializeComLibrary() {
    final int hResult = CoInitializeEx(
        nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    _validateResult(hResult);
    return hResult;
  }

  /// Returns a list directory paths from user interaction.
  @visibleForTesting
  List<String> returnSelectedElements(
      int hResult, SelectionOptions selectionOptions, IFileOpenDialog dialog) {
    final List<String> selectedElements = <String>[];

    if (FAILED(hResult)) {
      if (hResult != HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
        throw WindowsException(hResult);
      }
    } else {
      hResult = _getSelectedPathsFromUserInput(
          selectionOptions, selectedElements, dialog);
    }

    hResult = _fileOpenDialogAPI.release(dialog);
    _validateResult(hResult);

    CoUninitialize();
    return selectedElements;
  }

  /// Add confirmation button text.
  @visibleForTesting
  int addConfirmButtonLabel(
    String? confirmButtonText,
    IFileOpenDialog dialog,
  ) {
    final int hResult =
        _fileOpenDialogAPI.setOkButtonLabel(confirmButtonText, dialog);
    _validateResult(hResult);
    return hResult;
  }

  /// Adds file type filters.
  @visibleForTesting
  int addFileFilters(
      SelectionOptions selectionOptions, IFileOpenDialog fileDialog) {
    clearFilterSpecification();
    for (final TypeGroup? option in selectionOptions.allowedTypes) {
      if (option == null ||
          option.extensions == null ||
          option.extensions.isEmpty) {
        continue;
      }

      final String label = option.label;
      String extensionsForLabel = '';
      for (final String? extensionFile in option.extensions) {
        if (extensionFile != null) {
          extensionsForLabel += '*.$extensionFile;';
        }
      }
      filterSpecification[label] = extensionsForLabel;
    }

    int hResult = 0;
    if (filterSpecification.isNotEmpty) {
      hResult =
          _fileOpenDialogAPI.setFileTypes(filterSpecification, fileDialog);
      _validateResult(hResult);
    }

    return hResult;
  }

  /// Set the suggested file name of the given dialog.
  @visibleForTesting
  int setSuggestedFileName(
      String? suggestedFileName, IFileOpenDialog fileDialog) {
    int hResult = 0;
    if (suggestedFileName != null && suggestedFileName.isNotEmpty) {
      hResult = _fileOpenDialogAPI.setFileName(suggestedFileName, fileDialog);
      _validateResult(hResult);
    }

    return hResult;
  }

  String? _getDirectory({
    String? initialDirectory,
    String? confirmButtonText,
    String? suggestedFileName,
    required SelectionOptions selectionOptions,
  }) {
    int hResult = initializeComLibrary();
    final IFileOpenDialog dialog = FileOpenDialog.createInstance();
    using((Arena arena) {
      final Pointer<Uint32> ptrOptions = arena<Uint32>();
      hResult = getOptions(ptrOptions, dialog);
      hResult = setDialogOptions(ptrOptions, selectionOptions, dialog);
    });

    hResult = setInitialDirectory(initialDirectory, dialog);
    hResult = addFileFilters(selectionOptions, dialog);
    hResult = addConfirmButtonLabel(confirmButtonText, dialog);
    hResult = setSuggestedFileName(suggestedFileName, dialog);
    hResult = _fileOpenDialogAPI.show(hWndOwner, dialog);

    final List<String> selectedPaths =
        returnSelectedElements(hResult, selectionOptions, dialog);
    return selectedPaths.isEmpty ? null : selectedPaths.first;
  }

  void _validateResult(int hResult) {
    if (FAILED(hResult)) {
      throw WindowsException(hResult);
    }
  }

  int _getSelectedPathsFromUserInput(
    SelectionOptions selectionOptions,
    List<String> selectedElements,
    IFileOpenDialog dialog,
  ) {
    int hResult = 0;
    using((Arena arena) {
      final Pointer<Pointer<COMObject>> ptrShellItemArray =
          arena<Pointer<COMObject>>();

      if (selectionOptions.allowMultiple) {
        hResult = _fileOpenDialogAPI.getResults(ptrShellItemArray, dialog);
        _validateResult(hResult);
        final IShellItemArray iShellItemArray =
            _shellItemAPI.createShellItemArray(ptrShellItemArray);
        final Pointer<Uint32> ptrNumberOfSelectedElements = arena<Uint32>();
        _shellItemAPI.getCount(ptrNumberOfSelectedElements, iShellItemArray);

        for (int index = 0;
            index < ptrNumberOfSelectedElements.value;
            index++) {
          final Pointer<Pointer<COMObject>> ptrShellItem =
              arena<Pointer<COMObject>>();

          hResult =
              _shellItemAPI.getItemAt(index, ptrShellItem, iShellItemArray);
          _validateResult(hResult);

          hResult =
              _addSelectedPathFromPpsi(ptrShellItem, arena, selectedElements);

          _shellItemAPI.release(iShellItemArray);
        }
      } else {
        hResult = _fileOpenDialogAPI.getResult(ptrShellItemArray, dialog);
        _validateResult(hResult);
        hResult = _addSelectedPathFromPpsi(
            ptrShellItemArray, arena, selectedElements);
      }
    });

    _validateResult(hResult);

    return hResult;
  }

  int _addSelectedPathFromPpsi(Pointer<Pointer<COMObject>> ptrShellItem,
      Arena arena, List<String> selectedElements) {
    final IShellItem shellItem = _shellItemAPI.createShellItem(ptrShellItem);
    final Pointer<IntPtr> ptrPath = arena<IntPtr>();

    int hResult = _shellItemAPI.getDisplayName(ptrPath, shellItem);
    _validateResult(hResult);

    selectedElements.add(_shellItemAPI.getUserSelectedPath(ptrPath));
    hResult = _shellItemAPI.releaseItem(shellItem);
    _validateResult(hResult);

    return hResult;
  }
}
