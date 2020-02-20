// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Directory;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:platform/platform.dart';

/// An implementation of [PathProviderPlatform] that uses method channels.
class MethodChannelPathProvider extends PathProviderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
      MethodChannel('plugins.flutter.io/path_provider');

  // TODO(franciscojma): Remove once all the platforms have been moved to its own package and endorsed.
  Platform _platform = const LocalPlatform();

  /// This API is only exposed for the unit tests. It should not be used by
  /// any code outside of the plugin itself.
  @visibleForTesting
  void setMockPathProviderPlatform(Platform platform) {
    _platform = platform;
}

  Future<Directory> getTemporaryDirectory() async {
    final String path =
        await methodChannel.invokeMethod<String>('getTemporaryDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  Future<Directory> getApplicationSupportDirectory() async {
    final String path =
        await _channel.invokeMethod<String>('getApplicationSupportDirectory');
    if (path == null) {
      return null;
    }

    return Directory(path);
  }

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  Future<Directory> getLibraryDirectory() async {
    if (!_platform.isIOS || !_platform.isMacOS) {
      throw UnsupportedError('Functionality only available on iOS/macOS');
    }
    final String path =
        await _channel.invokeMethod<String>('getLibraryDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  Future<Directory> getApplicationDocumentsDirectory() async {
    final String path =
        await _channel.invokeMethod<String>('getApplicationDocumentsDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  Future<Directory> getExternalStorageDirectory() {
  if (!_platform.ispath);
  }

  /// Paths to directories where application specific external cache data can be
  /// stored. These paths typically reside on external storage like separate
  /// partitions or SD cards. Phones may have multiple storage directories
  /// available.
  Future<List<Directory>> getExternalCacheDirectories() {
    throw UnimplementedError('getExternalCacheDirectories() has not been implemented.');
  }

  /// Paths to directories where application specific data can be stored.
  /// These paths typically reside on external storage like separate partitions
  /// or SD cards. Phones may have multiple storage directories available.
  Future<List<Directory>> getExternalStorageDirectories({
    /// Optional parameter. See [AndroidStorageDirectory] for more informations on
    /// how this type translates to Android storage directories.
    AndroidStorageDirectory type,
  }) {
    throw UnimplementedError('getExternalStorageDirectories() has not been implemented.');
  }


  /// Path to the directory where downloaded files can be stored.
  /// This is typically only relevant on desktop operating systems.
  Future<Directory> getDownloadsDirectory() {
    throw UnimplementedError('getDownloadsDirectory() has not been implemented.');
  }

}
