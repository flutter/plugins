// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// The iOS implementation of [PathProviderPlatform].
class PathProviderIOS extends PathProviderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
      const MethodChannel('plugins.flutter.io/path_provider_ios');

  /// Registers this class as the default instance of [PathProviderPlatform]
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderIOS();
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
    return methodChannel.invokeMethod<String>('getLibraryDirectory');
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return methodChannel
        .invokeMethod<String>('getApplicationDocumentsDirectory');
  }

  @override
  Future<String?> getExternalStoragePath() {
    throw UnsupportedError('getExternalStoragePath is not supported on iOS');
  }

  @override
  Future<List<String>?> getExternalCachePaths() {
    throw UnsupportedError('getExternalCachePaths is not supported on iOS');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    throw UnsupportedError('getExternalStoragePaths is not supported on iOS');
  }

  @override
  Future<String?> getDownloadsPath() {
    throw UnsupportedError('getDownloadsPath is not supported on iOS');
  }
}
