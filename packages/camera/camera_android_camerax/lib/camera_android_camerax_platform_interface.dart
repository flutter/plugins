// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'camera_android_camerax_method_channel.dart';

/// The platform interface for the Android Camera implemented with CameraX.
abstract class CameraAndroidCameraxPlatform extends PlatformInterface {
  /// Constructs a CameraAndroidCameraxPlatform.
  CameraAndroidCameraxPlatform() : super(token: _token);

  static final Object _token = Object();

  static CameraAndroidCameraxPlatform _instance =
      MethodChannelCameraAndroidCamerax();

  /// The default instance of [CameraAndroidCameraxPlatform] to use.
  ///
  /// Defaults to [MethodChannelCameraAndroidCamerax].
  static CameraAndroidCameraxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CameraAndroidCameraxPlatform] when
  /// they register themselves.
  static set instance(CameraAndroidCameraxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the platform version of this isntance.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
