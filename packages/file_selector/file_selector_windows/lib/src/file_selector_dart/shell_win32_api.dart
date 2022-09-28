// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// A thin wrapper for Win32 platform specific Shell methods.
///
/// The only purpose of this class is to decouple specific Win32 Api call from the bussiness logic so it can be init tested in any environment.
class ShellWin32Api {
  /// Creates and [initializes](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-shcreateitemfromparsingname) a Shell item object from a parsing name.
  /// If the directory doesn't exist it will return an error result.
  int createItemFromParsingName(String initialDirectory, Pointer<GUID> ptrGuid,
      Pointer<Pointer<NativeType>> ptrPath) {
    return SHCreateItemFromParsingName(
        TEXT(initialDirectory), nullptr, ptrGuid, ptrPath);
  }

  /// Returns the path for [shellItem] as a UTF-8 string, or an empty string on
  /// failure.
  String getPathForShellItem(IShellItem shellItem) {
    return using((Arena arena) {
      final Pointer<Pointer<Utf16>> ptrPath = arena<Pointer<Utf16>>();

      if (!SUCCEEDED(
          shellItem.getDisplayName(SIGDN.SIGDN_FILESYSPATH, ptrPath.cast()))) {
        return '';
      }

      return ptrPath.value.toDartString();
    });
  }
}
