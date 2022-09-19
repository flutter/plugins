// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// ShellItemApi provider to interact with Shell Items.
class ShellItemAPI {
  /// Create a shell item from a given pointer.
  IShellItem createShellItem(Pointer<Pointer<COMObject>> ptrShellItem) {
    return IShellItem(ptrShellItem.cast());
  }

  /// Creates an array from a given pointer.
  IShellItemArray createShellItemArray(
      Pointer<Pointer<COMObject>> ptrShellItemArray) {
    return IShellItemArray(ptrShellItemArray.cast());
  }

  /// Gets display name for an item.
  int getDisplayName(Pointer<IntPtr> ptrPath, IShellItem item) {
    return item.getDisplayName(SIGDN.SIGDN_FILESYSPATH, ptrPath.cast());
  }

  /// Returns the selected path by the user.
  String getUserSelectedPath(Pointer<IntPtr> ptrPath) {
    final Pointer<Utf16> path = Pointer<Utf16>.fromAddress(ptrPath.value);
    return path.toDartString();
  }

  /// Releases an IShellItem.
  int releaseItem(IShellItem item) {
    return item.release();
  }

  /// Gets the number of elements given a IShellItemArray.
  void getCount(Pointer<Uint32> ptrNumberOfSelectedElements,
      IShellItemArray iShellItemArray) {
    iShellItemArray.getCount(ptrNumberOfSelectedElements);
  }

  /// Gets the item at a giving position.
  int getItemAt(int index, Pointer<Pointer<COMObject>> ptrShellItem,
      IShellItemArray iShellItemArray) {
    return iShellItemArray.getItemAt(index, ptrShellItem);
  }

  /// Releases the given IShellItemArray.
  void release(IShellItemArray iShellItemArray) {
    iShellItemArray.release();
  }
}
