// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// A thin wrapper for Win32 platform specific Shell methods.
///
/// Allows for unit testing by decoupling win32 API calls from the business logic.
class ShellWin32Api {
  /// Creates and [initializes](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-shcreateitemfromparsingname) a Shell item object from a parsing name.
  /// If the directory doesn't exist it will return an error result.
  int createItemFromParsingName(
    Pointer<Utf16> pszPath,
    Pointer<GUID> ptrGuid,
    Pointer<Pointer<NativeType>> ptrPath,
  ) {
    return SHCreateItemFromParsingName(pszPath, nullptr, ptrGuid, ptrPath);
  }

  /// Returns the path for [shellItem] as a UTF-16 string, or an empty string on
  /// failure.
  String getPathForShellItem(IShellItem shellItem) {
    return using((Arena arena) {
      final Pointer<Pointer<Utf16>> ptrPath = arena<Pointer<Utf16>>();
      final int operationResult = shellItem.getDisplayName(
        SIGDN.SIGDN_FILESYSPATH,
        ptrPath.cast(),
      );

      if (!SUCCEEDED(operationResult)) {
        throw WindowsException(operationResult);
      }
      return ptrPath.value.toDartString();
    });
  }

  /// Releases the given [shellItem]
  int releaseShellItem(IShellItem shellItem) {
    return shellItem.release();
  }
}
