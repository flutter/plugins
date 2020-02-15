// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';
import 'path_provider_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/path_provider');

class MethodChannelPathProvider extends PathProviderPlatform {
  Platform _platform = const LocalPlatform();

  /// This API is only exposed for the unit tests. It should not be used by
  /// any code outside of the plugin itself.
  @visibleForTesting
  void setMockPathProviderPlatform(Platform platform) {
    _platform = platform;
  }

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  ///
  /// Files in this directory may be cleared at any time. This does *not* return
  /// a new temporary directory. Instead, the caller is responsible for creating
  /// (and cleaning up) files or directories within this directory. This
  /// directory is scoped to the calling application.
  ///
  /// On iOS, this uses the `NSCachesDirectory` API.
  ///
  /// On Android, this uses the `getCacheDir` API on the context.
  @override
  Future<String> getTemporaryDirectory() {
    return _channel.invokeMethod<String>('getTemporaryDirectory');
  }

  /// Path to a directory where the application may place application support
  /// files.
  ///
  /// Use this for files you don’t want exposed to the user. Your app should not
  /// use this directory for user data files.
  ///
  /// On iOS, this uses the `NSApplicationSupportDirectory` API.
  /// If this directory does not exist, it is created automatically.
  ///
  /// On Android, this function uses the `getFilesDir` API on the context.
  @override
  Future<String> getApplicationSupportDirectory() {
    return _channel.invokeMethod<String>('getApplicationSupportDirectory');
  }

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  ///
  /// On Android, this function throws an [UnsupportedError] as no equivalent
  /// path exists.
  @override
  Future<String> getLibraryDirectory() {
    return _channel.invokeMethod<String>('getLibraryDirectory');
  }

  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  ///
  /// On iOS, this uses the `NSDocumentDirectory` API. Consider using
  /// [getApplicationSupportDirectory] instead if the data is not user-generated.
  ///
  /// On Android, this uses the `getDataDirectory` API on the context. Consider
  /// using [getExternalStorageDirectory] instead if data is intended to be visible
  /// to the user.
  @override
  Future<String> getApplicationDocumentsDirectory() {
    return _channel.invokeMethod<String>('getApplicationDocumentsDirectory');
  }

  /// Path to a directory where the application may access top level storage.
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  ///
  /// On iOS, this function throws an [UnsupportedError] as it is not possible
  /// to access outside the app's sandbox.
  ///
  /// On Android this uses the `getExternalFilesDir(null)`.
  @override
  Future<String> getExternalStorageDirectory() {
    return _channel.invokeMethod<String>('getStorageDirectory');
  }

  /// Paths to directories where application specific external cache data can be
  /// stored. These paths typically reside on external storage like separate
  /// partitions or SD cards. Phones may have multiple storage directories
  /// available.
  ///
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  ///
  /// On iOS, this function throws an UnsupportedError as it is not possible
  /// to access outside the app's sandbox.
  ///
  /// On Android this returns Context.getExternalCacheDirs() or
  /// Context.getExternalCacheDir() on API levels below 19.
  @override
  Future<List<String>> getExternalCacheDirectories() {
    return _channel.invokeListMethod<String>('getExternalCacheDirectories');
  }

  /// Paths to directories where application specific data can be stored.
  /// These paths typically reside on external storage like separate partitions
  /// or SD cards. Phones may have multiple storage directories available.
  ///
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  ///
  /// On iOS, this function throws an UnsupportedError as it is not possible
  /// to access outside the app's sandbox.
  ///
  /// On Android this returns Context.getExternalFilesDirs(String type) or
  /// Context.getExternalFilesDir(String type) on API levels below 19.
  @override
  Future<List<String>> getExternalStorageDirectories({
    /// Optional parameter. See [StorageDirectory] for more informations on
    /// how this type translates to Android storage directories.
    StorageDirectory type,
  }) {
    return _channel.invokeListMethod<String>(
      'getExternalStorageDirectories',
      <String, dynamic>{'type': type?.index},
    );
  }

  /// Path to the directory where downloaded files can be stored.
  /// This is typically only relevant on desktop operating systems.
  ///
  /// On Android and on iOS, this function throws an [UnsupportedError] as no equivalent
  /// path exists.
  @override
  Future<String> getDownloadsDirectory() {
    return _channel.invokeMethod<String>('getDownloadsDirectory');
  }
}
