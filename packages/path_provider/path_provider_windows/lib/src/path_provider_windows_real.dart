// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:win32/win32.dart';

import 'folders.dart';

/// Wraps the Win32 VerQueryValue API call.
///
/// This class exists to allow injecting alternate metadata in tests without
/// building multiple custom test binaries.
@visibleForTesting
class VersionInfoQuerier {
  /// Returns the value for [key] in [versionInfo]s English strings section, or
  /// null if there is no such entry, or if versionInfo is null.
  getStringValue(Pointer<Uint8> versionInfo, key) {
    if (versionInfo == null) {
      return null;
    }
    const kEnUsLanguageCode = '040904e4';
    final keyPath = TEXT('\\StringFileInfo\\$kEnUsLanguageCode\\$key');
    final length = allocate<Uint32>();
    final valueAddress = allocate<IntPtr>();
    try {
      if (VerQueryValue(versionInfo, keyPath, valueAddress, length) == 0) {
        return null;
      }
      return Pointer<Utf16>.fromAddress(valueAddress.value)
          .unpackString(length.value);
    } finally {
      free(keyPath);
      free(length);
      free(valueAddress);
    }
  }
}

/// The Windows implementation of [PathProviderPlatform]
///
/// This class implements the `package:path_provider` functionality for Windows.
class PathProviderWindows extends PathProviderPlatform {
  /// The object to use for performing VerQueryValue calls.
  @visibleForTesting
  VersionInfoQuerier versionInfoQuerier = VersionInfoQuerier();

  /// This is typically the same as the TMP environment variable.
  @override
  Future<String> getTemporaryPath() async {
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

      // Ensure that the directory exists, since GetTempPath doesn't.
      final directory = Directory(path);
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      return Future.value(path);
    } finally {
      free(buffer);
    }
  }

  @override
  Future<String> getApplicationSupportPath() async {
    final appDataRoot = await getPath(WindowsKnownFolder.RoamingAppData);
    final directory = Directory(
        path.join(appDataRoot, _getApplicationSpecificSubdirectory()));
    // Ensure that the directory exists if possible, since it will on other
    // platforms. If the name is longer than MAXPATH, creating will fail, so
    // skip that step; it's up to the client to decide what to do with the path
    // in that case (e.g., using a short path).
    if (directory.path.length <= MAX_PATH) {
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }
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

  /// Returns the relative path string to append to the root directory returned
  /// by Win32 APIs for application storage (such as RoamingAppDir) to get a
  /// directory that is unique to the application.
  ///
  /// The convention is to use company-name\product-name\. This will use that if
  /// possible, using the data in the VERSIONINFO resource, with the following
  /// fallbacks:
  /// - If the company name isn't there, that component will be dropped.
  /// - If the product name isn't there, it will use the exe's filename (without
  ///   extension).
  String _getApplicationSpecificSubdirectory() {
    String companyName;
    String productName;

    final Pointer<Utf16> moduleNameBuffer =
        allocate<Uint16>(count: MAX_PATH + 1).cast<Utf16>();
    final Pointer<Uint32> unused = allocate<Uint32>();
    Pointer<Uint8> infoBuffer;
    try {
      // Get the module name.
      final moduleNameLength = GetModuleFileName(0, moduleNameBuffer, MAX_PATH);
      if (moduleNameLength == 0) {
        final error = GetLastError();
        throw WindowsException(error);
      }

      // From that, load the VERSIONINFO resource
      int infoSize = GetFileVersionInfoSize(moduleNameBuffer, unused);
      if (infoSize != 0) {
        infoBuffer = allocate<Uint8>(count: infoSize);
        if (GetFileVersionInfo(moduleNameBuffer, 0, infoSize, infoBuffer) ==
            0) {
          free(infoBuffer);
          infoBuffer = null;
        }
      }
      companyName = _sanitizedDirectoryName(
          versionInfoQuerier.getStringValue(infoBuffer, 'CompanyName'));
      productName = _sanitizedDirectoryName(
          versionInfoQuerier.getStringValue(infoBuffer, 'ProductName'));

      // If there was no product name, use the executable name.
      if (productName == null) {
        productName = path.basenameWithoutExtension(
            moduleNameBuffer.unpackString(moduleNameLength));
      }

      return companyName != null
          ? path.join(companyName, productName)
          : productName;
    } finally {
      free(moduleNameBuffer);
      free(unused);
      if (infoBuffer != null) {
        free(infoBuffer);
      }
    }
  }

  /// Makes [rawString] safe as a directory component. See
  /// https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions
  ///
  /// If after sanitizing the string is empty, returns null.
  String _sanitizedDirectoryName(String rawString) {
    if (rawString == null) {
      return null;
    }
    String sanitized = rawString
        // Replace banned characters.
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        // Remove trailing whitespace.
        .trimRight()
        // Ensure that it does not end with a '.'.
        .replaceAll(RegExp(r'[.]+$'), '');
    const kMaxComponentLength = 255;
    if (sanitized.length > kMaxComponentLength) {
      sanitized = sanitized.substring(0, kMaxComponentLength);
    }
    return sanitized.isEmpty ? null : sanitized;
  }
}
