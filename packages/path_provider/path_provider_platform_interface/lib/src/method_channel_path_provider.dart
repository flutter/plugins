// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Directory;

import 'enums.dart';

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

  // Ideally, this property shouldn't exist, and each platform should
  // just implement the supported methods. Once all the platforms are
  // federated, this property should be removed.
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

  Future<Directory> getLibraryDirectory() async {
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

  Future<List<Directory>> getExternalCacheDirectories() async {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    final List<String> paths = await methodChannel
        .invokeListMethod<String>('getExternalCacheDirectories');

    return paths.map((String path) => Directory(path)).toList();
  }

  Future<List<Directory>> getExternalStorageDirectories({
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
