// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Directory;

import 'enums.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:platform/platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
    final String path = await methodChannel
        .invokeMethod<String>('getApplicationSupportDirectory');
    if (path == null) {
      return null;
    }

    return Directory(path);
  }

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  Future<Directory> getLibraryDirectory() async {
    print(_platform.isAndroid);
    if (!_platform.isIOS && !_platform.isMacOS) {
      throw UnsupportedError('Functionality only available on iOS/macOS');
    }
    final String path =
        await methodChannel.invokeMethod<String>('getLibraryDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  Future<Directory> getApplicationDocumentsDirectory() async {
    final String path = await methodChannel
        .invokeMethod<String>('getApplicationDocumentsDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  Future<Directory> getExternalStorageDirectory() async {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    final String path =
        await methodChannel.invokeMethod<String>('getStorageDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  /// Paths to directories where application specific external cache data can be
  /// stored. These paths typically reside on external storage like separate
  /// partitions or SD cards. Phones may have multiple storage directories
  /// available.
  Future<List<Directory>> getExternalCacheDirectories() async {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    final List<String> paths = await methodChannel
        .invokeListMethod<String>('getExternalCacheDirectories');

    return paths.map((String path) => Directory(path)).toList();
  }

  /// Paths to directories where application specific data can be stored.
  /// These paths typically reside on external storage like separate partitions
  /// or SD cards. Phones may have multiple storage directories available.
  Future<List<Directory>> getExternalStorageDirectories({
    /// Optional parameter. See [StorageDirectory] for more informations on
    /// how this type translates to Android storage directories.
    AndroidStorageDirectory type,
  }) async {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    final List<String> paths = await methodChannel.invokeListMethod<String>(
      'getExternalStorageDirectories',
      <String, dynamic>{'type': type?.index},
    );

    return paths.map((String path) => Directory(path)).toList();
  }

  /// Path to the directory where downloaded files can be stored.
  /// This is typically only relevant on desktop operating systems.
  Future<Directory> getDownloadsDirectory() async {
    if (!_platform.isMacOS) {
      throw UnsupportedError('Functionality only available on macOS');
    }
    final String path =
        await methodChannel.invokeMethod<String>('getDownloadsDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }
}
