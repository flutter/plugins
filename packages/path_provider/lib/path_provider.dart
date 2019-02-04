// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/path_provider');

/// Path to the temporary directory on the device.
///
/// Files in this directory may be cleared at any time. This does *not* return
/// a new temporary directory. Instead, the caller is responsible for creating
/// (and cleaning up) files or directories within this directory. This
/// directory is scoped to the calling application.
///
/// On iOS, this uses the `NSCachesDirectory` API.
///
/// On Android, this uses the `getCacheDir` API on the context.
Future<Directory> getTemporaryDirectory() async {
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  final String path = await _channel.invokeMethod('getTemporaryDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Path to a directory where the application may place files that are private
/// to the application and will only be cleared when the application itself
/// is deleted.
///
/// On iOS, this uses the `NSDocumentsDirectory` API.
///
/// On Android, this returns the AppData directory.
Future<Directory> getApplicationDocumentsDirectory() async {
  final String path =
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await _channel.invokeMethod('getApplicationDocumentsDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Path to a directory where the application may access top level storage.
/// The current operating system should be determined before issuing this
/// function call, as this functionality is only available on Android.
///
/// On iOS, this function throws an UnsupportedError as it is not possible
/// to access outside the app's sandbox.
///
/// On Android this returns getExternalStorageDirectory.
Future<Directory> getExternalStorageDirectory() async {
  if (Platform.isIOS)
    throw UnsupportedError("Functionality not available on iOS");
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  final String path = await _channel.invokeMethod('getStorageDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}
