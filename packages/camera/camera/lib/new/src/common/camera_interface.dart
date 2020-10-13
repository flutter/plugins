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
enum LensDirection { front, back, unknown }

/// Abstract class used to create a common interface to describe a camera from different platform APIs.
///
/// This provides information such as the [name] of the camera and [direction]
/// the lens face.
abstract class CameraDescription {
  /// Location of the camera on the device.
  LensDirection get direction;

  /// Identifier for this camera.
  String get name;
}

/// Abstract class used to create a common interface across platform APIs.
abstract class CameraConfigurator {
  /// Texture id that can be used to send camera frames to a [Texture] widget.
  ///
  /// You must call [addPreviewTexture] first or this will only return null.
  int get previewTextureId;

  /// Initializes the camera on the device.
  Future<void> initialize();

  /// Begins the flow of data between the inputs and outputs connected to the camera instance.
  ///
  /// This will start updating the texture with id: [previewTextureId].
  Future<void> start();

  /// Stops the flow of data between the inputs and outputs connected to the camera instance.
  Future<void> stop();

  /// Dispose all resources and disables further use of this configurator.
  Future<void> dispose();

  /// Retrieves a valid texture Id to be used with a [Texture] widget.
  Future<int> addPreviewTexture();
}
