// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of support_android_camera;

/// Class used to control the camera for [CameraApi.supportAndroid].
///
/// This class is used to set image capture settings, start/stop preview, snap
/// pictures, and retrieve frames for encoding for video. This class is a client
/// for the Camera service, which manages the actual camera hardware.
class SupportAndroidCamera with NativeMethodCallHandler, CameraClosable {
  SupportAndroidCamera._();

  /// The number of physical cameras available on this device.
  ///
  /// The return value of this method might change dynamically if the device
  /// supports external cameras and an external camera is connected or
  /// disconnected.
  ///
  /// If there is a logical multi-camera in the system, to maintain app backward
  /// compatibility, this method will only expose one camera per facing for all
  /// logical camera and physical camera groups. Use [CameraApi.android]
  /// API to see all cameras.
  static Future<int> getNumberOfCameras() {
    return CameraChannel.channel.invokeMethod<int>(
      '$SupportAndroidCamera#getNumberOfCameras',
    );
  }

  /// Creates a new [SupportAndroidCamera] object to access a hardware camera.
  ///
  /// If the same camera is opened by other applications, this will throw a
  /// [PlatformException].
  ///
  /// You must call [release] when you are done using the camera, otherwise it
  /// will remain locked and be unavailable to other applications.
  ///
  /// Your application should only have one Camera object active at a time for a
  /// particular hardware camera.
  static SupportAndroidCamera open(int cameraId) {
    final SupportAndroidCamera camera = SupportAndroidCamera._();

    CameraChannel.channel.invokeMethod<int>(
      '$SupportAndroidCamera#open',
      <String, dynamic>{'cameraId': cameraId, 'cameraHandle': camera.handle},
    );

    return camera;
  }

  /// Returns the information about a particular camera.
  ///
  /// If [getNumberOfCameras] returns N, the valid id is 0 to N-1.
  static Future<CameraInfo> getCameraInfo(int cameraId) async {
    final Map<String, dynamic> infoMap =
        await CameraChannel.channel.invokeMapMethod<String, dynamic>(
      '$SupportAndroidCamera#getCameraInfo',
      <String, dynamic>{'cameraId': cameraId},
    );

    return CameraInfo._fromMap(infoMap);
  }

  /// Sets the [NativeTexture] to be used for live preview.
  ///
  /// This method must be called before [startPreview].
  set previewTexture(NativeTexture texture) {
    assert(!isClosed);

    CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#previewTexture',
      <String, dynamic>{'handle': handle, 'nativeTexture': texture?.asMap()},
    );
  }

  /// Starts capturing and drawing preview frames to the screen.
  ///
  /// Preview will not actually start until a [NativeTexture] is supplied with
  /// [previewTexture].
  Future<void> startPreview() {
    assert(!isClosed);

    return CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#startPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  /// Stops capturing and drawing preview frames to the [previewTexture].
  Future<void> stopPreview() {
    if (isClosed) return Future<void>.value();

    return CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#stopPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  /// Disconnects and releases the Camera object resources.
  ///
  /// You must call this as soon as you're done with the Camera object.
  Future<void> release() {
    if (isClosed) return Future<void>.value();

    isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#release',
      <String, dynamic>{'handle': handle},
    );
  }
}
