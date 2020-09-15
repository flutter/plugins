// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_windows/folders.dart';

/// The Windows implementation of [PathProviderPlatform]
///
/// This class implements the `package:path_provider` functionality for Windows.
class PathProviderWindows extends PathProviderPlatform {
  @override
  Future<String> getTemporaryPath() {
    final buffer = allocate<Uint16>(count: MAX_PATH + 1).cast<Utf16>();
    String path;

    try {
      final length = GetTempPath(MAX_PATH, buffer);

      if (length == 0) {
        final error = GetLastError();
        throw WindowsException(error);
      } else {
        path = buffer.unpackString(length);

        // GetTempPath adds a trailing backslash, but SHGetKnownFolderPath does
        // not. Strip off trailing backslash for consistency with other methods
        // here.
        if (path.endsWith('\\')) {
          path = path.substring(0, path.length - 1);
        }
      }
      return Future.value(path);
    } finally {
      free(buffer);
    }
  }

  @override
  Future<String> getApplicationSupportPath() async {
    final appDataRoot = await getPath(WindowsKnownFolder.RoamingAppData);
    // DO NOT LAND. Use GetModuleFileName here once it's available in win32.
    final exePath = 'path/to/app.exe';
    final directory = Directory(
        path.join(appDataRoot, path.basenameWithoutExtension(exePath)));
    // Ensure that the returned directory exists, since it will on other
    // platforms.
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  @override
  Future<String> getApplicationDocumentsPath() =>
      getPath(WindowsKnownFolder.Documents);

  @override
  Future<String> getDownloadsPath() => getPath(WindowsKnownFolder.Downloads);

  /// Retrieve any known folder from Windows.
  ///
  /// folderID is a GUID that represents a specific known folder ID, drawn from
  /// [WindowsKnownFolder].
  Future<String> getPath(String folderID) {
    final pathPtrPtr = allocate<IntPtr>();
    Pointer<Utf16> pathPtr;

    try {
      GUID knownFolderID = GUID.fromString(folderID);

      final hr = SHGetKnownFolderPath(
          knownFolderID.addressOf, KF_FLAG_DEFAULT, NULL, pathPtrPtr);

      if (FAILED(hr)) {
        if (hr == E_INVALIDARG || hr == E_FAIL) {
          throw WindowsException(hr);
        }
      }

      pathPtr = Pointer<Utf16>.fromAddress(pathPtrPtr.value);
      final path = pathPtr.unpackString(MAX_PATH);
      return Future.value(path);
    } finally {
      CoTaskMemFree(pathPtr.cast());
      free(pathPtrPtr);
    }
  }
}
