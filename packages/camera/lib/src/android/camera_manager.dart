// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of android_camera;

class CameraManager with NativeMethodCallHandler {
  CameraManager._() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      CameraChannel.channel.invokeMethod<void>(
        '$CameraManager()',
        <String, dynamic>{'managerHandle': handle},
      );
    }
  }

  static final CameraManager instance = CameraManager._();

  Future<CameraCharacteristics> getCameraCharacteristics(
    String cameraId,
  ) async {
    assert(cameraId != null);

    final Map<String, dynamic> data =
        await CameraChannel.channel.invokeMapMethod<String, dynamic>(
      '$CameraManager#getCameraCharacteristics',
      <String, dynamic>{'cameraId': cameraId, 'handle': handle},
    );

    return CameraCharacteristics._fromMap(data);
  }

  Future<List<String>> getCameraIdList() {
    return CameraChannel.channel.invokeListMethod<String>(
      '$CameraManager#getCameraIdList',
      <String, dynamic>{'handle': handle},
    );
  }

  void openCamera(String cameraId, CameraDeviceStateCallback stateCallback) {
    assert(cameraId != null);
    assert(stateCallback != null);

    final CameraDevice device = CameraDevice._(cameraId, stateCallback);
    CameraChannel.channel.invokeMethod<void>(
      '$CameraManager#openCamera',
      <String, dynamic>{
        'handle': handle,
        'cameraId': cameraId,
        'cameraHandle': device.handle,
      },
    );
  }
}
