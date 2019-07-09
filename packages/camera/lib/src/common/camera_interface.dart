// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// Available APIs compatible with [CameraController].
enum CameraApi {
  /// [Camera2](https://developer.android.com/reference/android/hardware/camera2/package-summary)
  android,

  /// [AVFoundation](https://developer.apple.com/av-foundation/)
  iOS,

  /// [Camera](https://developer.android.com/reference/android/hardware/Camera)
  supportAndroid,
}

/// Location of the camera on the device.
enum LensDirection { front, back, external }

/// Abstract class that describes a camera. See [CameraInfo].
abstract class CameraDescription {
  /// Location of the camera on the device.
  LensDirection get direction;

  /// Identifier or name for this camera. This will be either an [int] or a [String].
  dynamic get id;
}

/// Abstract class used to create a common interface across APIs. See [SupportAndroidCameraConfigurator].
abstract class CameraConfigurator {
  /// Texture id that can be used to send camera frames to a [Texture] widget.
  ///
  /// You must call [addPreviewTexture] first or this will only return null.
  int get previewTextureId;

  /// Begin processing for the camera this configurator controls.
  ///
  /// This will start updating the texture with id: [previewTextureId].
  Future<void> start();

  /// Stop all processing for the camera this configurator controls.
  Future<void> stop();

  /// Dispose all resources and disables further use of this configurator.
  Future<void> dispose();

  /// Retrieves a valid texture Id to be used with a [Texture] widget.
  Future<int> addPreviewTexture();
}
