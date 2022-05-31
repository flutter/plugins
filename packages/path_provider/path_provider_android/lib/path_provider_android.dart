// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// The Android implementation of [PathProviderPlatform].
class PathProviderAndroid extends PathProviderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
      const MethodChannel('plugins.flutter.io/path_provider_android');

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderAndroid();
  }

  @override
  Future<String?> getTemporaryPath() {
    return methodChannel.invokeMethod<String>('getTemporaryDirectory');
  }

  @override
  Future<String?> getApplicationSupportPath() {
    return methodChannel.invokeMethod<String>('getApplicationSupportDirectory');
  }

  @override
  Future<String?> getLibraryPath() {
    throw UnsupportedError('getLibraryPath is not supported on Android');
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return methodChannel
        .invokeMethod<String>('getApplicationDocumentsDirectory');
  }

  @override
  Future<String?> getExternalStoragePath() {
    return methodChannel.invokeMethod<String>('getStorageDirectory');
  }

  @override
  Future<List<String>?> getExternalCachePaths() {
    return methodChannel
        .invokeListMethod<String>('getExternalCacheDirectories');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return methodChannel.invokeListMethod<String>(
      'getExternalStorageDirectories',
      <String, dynamic>{'type': type?.index},
    );
  }

  @override
  Future<String?> getDownloadsPath() {
    throw UnsupportedError('getDownloadsPath is not supported on Android');
  }
}
