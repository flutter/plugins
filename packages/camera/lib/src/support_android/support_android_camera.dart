// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of support_android_camera;

class SupportAndroidCamera with NativeMethodCallHandler, CameraClosable {
  SupportAndroidCamera._();

  static Future<int> getNumberOfCameras() {
    return CameraChannel.channel.invokeMethod<int>(
      '$SupportAndroidCamera#getNumberOfCameras',
    );
  }

  static SupportAndroidCamera open(int cameraId) {
    final SupportAndroidCamera camera = SupportAndroidCamera._();

    CameraChannel.channel.invokeMethod<int>(
      '$SupportAndroidCamera#open',
      <String, dynamic>{'cameraId': cameraId, 'cameraHandle': camera.handle},
    );

    return camera;
  }

  static Future<CameraInfo> getCameraInfo(int cameraId) async {
    final Map<String, dynamic> infoMap =
        await CameraChannel.channel.invokeMapMethod<String, dynamic>(
      '$SupportAndroidCamera#getCameraInfo',
      <String, dynamic>{'cameraId': cameraId},
    );

    return CameraInfo._fromMap(infoMap);
  }

  set previewTexture(NativeTexture texture) {
    assert(!isClosed);

    CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#previewTexture',
      <String, dynamic>{'handle': handle, 'nativeTexture': texture?.asMap()},
    );
  }

  Future<void> startPreview() {
    assert(!isClosed);

    return CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#startPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  Future<void> stopPreview() {
    if (isClosed) return Future<void>.value();

    return CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#stopPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  Future<void> release() {
    if (isClosed) return Future<void>.value();

    isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$SupportAndroidCamera#release',
      <String, dynamic>{'handle': handle},
    );
  }
}
