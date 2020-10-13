// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../common/camera_channel.dart';
import '../common/camera_mixins.dart';
import '../common/native_texture.dart';
import 'camera_info.dart';

/// The Camera class used to set image capture settings, start/stop preview, snap pictures, and retrieve frames for encoding for video.
///
/// This class is a client for the Camera service, which manages the actual
/// camera hardware.
///
/// This exposes the deprecated Android
/// [Camera](https://developer.android.com/reference/android/hardware/Camera)
/// API. This should only be used with Android sdk versions less than 21.
class Camera with NativeMethodCallHandler {
  Camera._();

  bool _isClosed = false;

  /// Retrieves the number of physical cameras available on this device.
  static Future<int> getNumberOfCameras() {
    return CameraChannel.channel.invokeMethod<int>(
      'Camera#getNumberOfCameras',
    );
  }

  /// Creates a new [Camera] object to access a particular hardware camera.
  ///
  /// If the same camera is opened by other applications, this will throw a
  /// [PlatformException].
  ///
  /// You must call [release] when you are done using the camera, otherwise it
  /// will remain locked and be unavailable to other applications.
  ///
  /// Your application should only have one [Camera] object active at a time for
  /// a particular hardware camera.
  static Camera open(int cameraId) {
    final Camera camera = Camera._();

    CameraChannel.channel.invokeMethod<int>(
      'Camera#open',
      <String, dynamic>{'cameraId': cameraId, 'cameraHandle': camera.handle},
    );

    return camera;
  }

  /// Retrieves information about a particular camera.
  ///
  /// If [getNumberOfCameras] returns N, the valid id is 0 to N-1.
  static Future<CameraInfo> getCameraInfo(int cameraId) async {
    final Map<String, dynamic> infoMap =
        await CameraChannel.channel.invokeMapMethod<String, dynamic>(
      'Camera#getCameraInfo',
      <String, dynamic>{'cameraId': cameraId},
    );

    return CameraInfo.fromMap(infoMap);
  }

  /// Sets the [NativeTexture] to be used for live preview.
  ///
  /// This method must be called before [startPreview].
  ///
  /// The one exception is that if the preview native texture is not set (or
  /// set to null) before [startPreview] is called, then this method may be
  /// called once with a non-null parameter to set the preview texture.
  /// (This allows camera setup and surface creation to happen in parallel,
  /// saving time.) The preview native texture may not otherwise change while
  /// preview is running.
  set previewTexture(NativeTexture texture) {
    assert(!_isClosed);

    CameraChannel.channel.invokeMethod<void>(
      'Camera#previewTexture',
      <String, dynamic>{'handle': handle, 'nativeTexture': texture?.asMap()},
    );
  }

  /// Starts capturing and drawing preview frames to the screen.
  ///
  /// Preview will not actually start until a surface is supplied with
  /// [previewTexture].
  Future<void> startPreview() {
    assert(!_isClosed);

    return CameraChannel.channel.invokeMethod<void>(
      'Camera#startPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  /// Stops capturing and drawing preview frames to the [previewTexture], and resets the camera for a future call to [startPreview].
  Future<void> stopPreview() {
    assert(!_isClosed);

    return CameraChannel.channel.invokeMethod<void>(
      'Camera#stopPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  /// Disconnects and releases the Camera object resources.
  ///
  /// You must call this as soon as you're done with the Camera object.
  Future<void> release() {
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      'Camera#release',
      <String, dynamic>{'handle': handle},
    );
  }
}
