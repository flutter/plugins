// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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

  Future<String> getTemporaryPath() {
    return methodChannel.invokeMethod<String>('getTemporaryDirectory');
  }

  Future<String> getApplicationSupportPath() {
    return methodChannel.invokeMethod<String>('getApplicationSupportDirectory');
  }

  Future<String> getLibraryPath() {
    if (!_platform.isIOS && !_platform.isMacOS) {
      throw UnsupportedError('Functionality only available on iOS/macOS');
    }
    return methodChannel.invokeMethod<String>('getLibraryDirectory');
  }

  Future<String> getApplicationDocumentsPath() {
    return methodChannel
        .invokeMethod<String>('getApplicationDocumentsDirectory');
  }

  Future<String> getExternalStoragePath() {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    return methodChannel.invokeMethod<String>('getStorageDirectory');
  }

  Future<List<String>> getExternalCachePaths() {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    return methodChannel
        .invokeListMethod<String>('getExternalCacheDirectories');
  }

  Future<List<String>> getExternalStoragePaths({
    StorageDirectory type,
  }) async {
    if (!_platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    return methodChannel.invokeListMethod<String>(
      'getExternalStorageDirectories',
      <String, dynamic>{'type': type?.index},
    );
  }

  Future<String> getDownloadsPath() {
    if (!_platform.isMacOS) {
      throw UnsupportedError('Functionality only available on macOS');
    }
    return methodChannel.invokeMethod<String>('getDownloadsDirectory');
  }
}
