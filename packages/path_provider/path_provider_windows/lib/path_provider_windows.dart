// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// The Windows implementation of [PathProviderPlatform]
///
/// This class implements the `package:path_provider` functionality for Windows
class PathProviderWindows extends PathProviderPlatform {
  /// Registers this class as the default instance of [PathProviderPlatform]
  static void register() {
    PathProviderPlatform.instance = PathProviderWindows();
  }

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  @override
  Future<String> getTemporaryPath() {
    throw UnimplementedError('getTemporaryPath() has not been implemented.');
  }

  /// Path to a directory where the application may place application support
  /// files.
  @override
  Future<String> getApplicationSupportPath() {
    throw UnimplementedError(
        'getApplicationSupportPath() has not been implemented.');
  }

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  @override
  Future<String> getLibraryPath() {
    throw UnimplementedError('getLibraryPath() has not been implemented.');
  }

  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  @override
  Future<String> getApplicationDocumentsPath() {
    throw UnimplementedError(
        'getApplicationDocumentsPath() has not been implemented.');
  }

  /// Path to a directory where the application may access top level storage.
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  @override
  Future<String> getExternalStoragePath() {
    throw UnimplementedError(
        'getExternalStoragePath() has not been implemented.');
  }

  /// Paths to directories where application specific external cache data can be
  /// stored. These paths typically reside on external storage like separate
  /// partitions or SD cards. Phones may have multiple storage directories
  /// available.
  @override
  Future<List<String>> getExternalCachePaths() {
    throw UnimplementedError(
        'getExternalCachePaths() has not been implemented.');
  }

  /// Paths to directories where application specific data can be stored.
  /// These paths typically reside on external storage like separate partitions
  /// or SD cards. Phones may have multiple storage directories available.
  @override
  Future<List<String>> getExternalStoragePaths({
    /// Optional parameter. See [StorageDirectory] for more informations on
    /// how this type translates to Android storage directories.
    StorageDirectory type,
  }) {
    throw UnimplementedError(
        'getExternalStoragePaths() has not been implemented.');
  }

  /// Path to the directory where downloaded files can be stored.
  /// This is typically only relevant on desktop operating systems.
  @override
  Future<String> getDownloadsPath() {
    throw UnimplementedError('getDownloadsPath() has not been implemented.');
  }
}
