// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Constants:

/// Typedef for kNull values.
const kNull = 0;

/// Typedef for MAX_VALUE.
const kMaxPath = 260;

// Function definitions:

// Definition for SHGetFolderPathW. Retrieves a folder path given a CSIDL.
//
// SHFOLDERAPI SHGetFolderPathW(
//   HWND   hwnd,
//   int    csidl,
//   HANDLE hToken,
//   DWORD  dwFlags,
//   LPWSTR pszPath
// );
typedef shGetFolderPathNative = Int32 Function(Int64 hwnd, Int32 csidl,
    Int64 hToken, Int32 dwFlags, Pointer<Uint16> pszPath);
typedef shGetFolderPathDart = int Function(
    int hwnd, int csidl, int hToken, int dwFlags, Pointer<Uint16> pszPath);

// Definition for GetModuleFileNameW. Retrieves the path to the current process.
//
// DWORD GetModuleFileNameW(
//   HMODULE hModule,
//   LPWSTR  lpFilename,
//   DWORD   nSize
// );
typedef GetModuleFileNameC = Int32 Function(
  Int32 hModule,
  Pointer<Uint16> fileName,
  Int16 nSize,
);
typedef GetModuleFileNameDart = int Function(
  int hModule,
  Pointer<Uint16> fileName,
  int nSize,
);

/// Reference to the Shell32 dynamic library.
final shell32 = DynamicLibrary.open('shell32.dll');

/// Reference to the Kernel32 dynamic library.
final kernel32 = DynamicLibrary.open('kernel32.dll');

/// Dart invocation of the win32 SHGetFolderPathW function.
final shGetFolderPath =
    shell32.lookupFunction<shGetFolderPathNative, shGetFolderPathDart>(
        'SHGetFolderPathW');

/// Dart invocation of the win32 GetModuleFileNameW function.
final getModuleFileNameW =
    kernel32.lookupFunction<GetModuleFileNameC, GetModuleFileNameDart>(
        'GetModuleFileNameW');

/// Convenience method to get the AppData Local folder path.
String getLocalDataPath() {
  final CSIDL_LOCAL_APPDATA = 0x001c;
  final CSIDL_FLAG_CREATE = 0x8000;
  Pointer<Uint16> path = allocate<Uint16>(count: kMaxPath);
  shGetFolderPath(
      kNull, CSIDL_LOCAL_APPDATA | CSIDL_FLAG_CREATE, kNull, 0, path);

  Uint16List pathData = path.asTypedList(kMaxPath);
  return String.fromCharCodes(
      path.asTypedList(kMaxPath), 0, pathData.indexOf(0));
}

/// Convenience method to retrieve the path of the current process.
String getModuleFileName() {
  Pointer<Uint16> rs = allocate<Uint16>(count: kMaxPath);
  getModuleFileNameW(kNull, rs, kMaxPath);
  Uint16List pathData = rs.asTypedList(kMaxPath);
  return String.fromCharCodes(rs.asTypedList(kMaxPath), 0, pathData.indexOf(0));
}
