// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// FileOpenDialogWrapper provides an abstraction to interact with IFileOpenDialog related methods.
class FileOpenDialogWrapper {
  /// Sets the [options](https://pub.dev/documentation/win32/latest/winrt/FILEOPENDIALOGOPTIONS-class.html) given into an IFileOpenDialog.
  int setOptions(int options, IFileOpenDialog dialog) {
    return dialog.setOptions(options);
  }

  /// Returns the IFileOpenDialog's [options](https://pub.dev/documentation/win32/latest/winrt/FILEOPENDIALOGOPTIONS-class.html).
  int getOptions(Pointer<Uint32> ptrOptions, IFileOpenDialog dialog) {
    return dialog.getOptions(ptrOptions);
  }

  /// Sets confirmation button text on an IFileOpenDialog. If the [confirmationText] is null, 'Pick' will be used.
  int setOkButtonLabel(String? confirmationText, IFileOpenDialog dialog) {
    return dialog.setOkButtonLabel(TEXT(confirmationText ?? 'Pick'));
  }

  /// Sets the allowed file type extensions in an IFileOpenDialog.
  int setFileTypes(
      Map<String, String> filterSpecification, IFileOpenDialog dialog) {
    int operationResult = 0;
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

      operationResult = dialog.setFileTypes(
          filterSpecification.length, registerFilterSpecification);
    });

    return operationResult;
  }

  /// Shows an IFileOpenDialog using the given owner.
  int show(int hwndOwner, IFileOpenDialog dialog) {
    return dialog.show(hwndOwner);
  }

  /// Release an IFileOpenDialog.
  int release(IFileOpenDialog dialog) {
    return dialog.release();
  }

  /// Return a result from an IFileOpenDialog.
  int getResult(
      Pointer<Pointer<COMObject>> ptrCOMObject, IFileOpenDialog dialog) {
    return dialog.getResult(ptrCOMObject);
  }

  /// Return results from an IFileOpenDialog. This should be used when selecting multiple items.
  int getResults(
      Pointer<Pointer<COMObject>> ptrCOMObject, IFileOpenDialog dialog) {
    return dialog.getResults(ptrCOMObject);
  }

  /// Sets the initial directory for an IFileOpenDialog.
  int setFolder(Pointer<Pointer<COMObject>> ptrPath, IFileOpenDialog dialog) {
    return dialog.setFolder(ptrPath.value);
  }

  /// Sets the suggested file name for an IFileOpenDialog.
  int setFileName(String suggestedFileName, IFileOpenDialog dialog) {
    return dialog.setFileName(TEXT(suggestedFileName));
  }

  /// Creates and [initializes](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-shcreateitemfromparsingname) a Shell item object from a parsing name.
  /// If the directory doesn't exist it will return an error result.
  int createItemFromParsingName(String initialDirectory, Pointer<GUID> ptrGuid,
      Pointer<Pointer<NativeType>> ptrPath) {
    return SHCreateItemFromParsingName(
        TEXT(initialDirectory), nullptr, ptrGuid, ptrPath);
  }

  /// Initilaize the COM library with the internal [CoInitializeEx](https://pub.dev/documentation/win32/latest/winrt/CoInitializeEx.html) method.
  /// It uses the following parameters:
  /// pvReserved (Pointer): nullptr
  /// dwCoInit (int):  COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
  /// COINIT_APARTMENTTHREADED: Initializes the thread for apartment-threaded object concurrency.
  /// COINIT_DISABLE_OLE1DDE: Disables Dynamic Data Exchange for Ole1 [support](https://learn.microsoft.com/en-us/windows/win32/learnwin32/initializing-the-com-library).
  int coInitializeEx() {
    return CoInitializeEx(
        nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
  }

  /// Creates instance of FileOpenDialog.
  IFileOpenDialog createInstance() {
    return FileOpenDialog.createInstance();
  }

  /// Closes the COM library on the current thread, unloads all DLLs loaded by the thread, frees any other resources that the thread maintains, and forces all RPC connections on the thread to close.
  void coUninitialize() {
    CoUninitialize();
  }
}
