// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'enums.dart';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// An implementation of [PathProviderPlatform] that uses method channels.
class MethodChannelPathProvider extends PathProviderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
      MethodChannel('plugins.flutter.io/path_provider');

  Future<String?> getTemporaryPath() {
    return methodChannel.invokeMethod<String>('getTemporaryDirectory');
  }

  Future<String?> getApplicationSupportPath() {
    return methodChannel.invokeMethod<String>('getApplicationSupportDirectory');
  }

  Future<String?> getLibraryPath() {
    return methodChannel.invokeMethod<String>('getLibraryDirectory');
  }

  Future<String?> getApplicationDocumentsPath() {
    return methodChannel
        .invokeMethod<String>('getApplicationDocumentsDirectory');
  }

  Future<String?> getExternalStoragePath() {
    return methodChannel.invokeMethod<String>('getStorageDirectory');
  }

  Future<List<String>?> getExternalCachePaths() {
    return methodChannel
        .invokeListMethod<String>('getExternalCacheDirectories');
  }

  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return methodChannel.invokeListMethod<String>(
      'getExternalStorageDirectories',
      <String, dynamic>{'type': type?.index},
    );
  }

  Future<String?> getDownloadsPath() {
    return methodChannel.invokeMethod<String>('getDownloadsDirectory');
  }
}
