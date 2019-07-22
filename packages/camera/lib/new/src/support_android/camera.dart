part of support_android_camera;

class Camera with NativeMethodCallHandler {
  Camera._();

  bool _isClosed = false;

  static Future<int> getNumberOfCameras() {
    return CameraChannel.channel.invokeMethod<int>(
      'Camera#getNumberOfCameras',
    );
  }

  static Camera open(int cameraId) {
    final Camera camera = Camera._();

    CameraChannel.channel.invokeMethod<int>(
      'Camera#open',
      <String, dynamic>{'cameraId': cameraId, 'cameraHandle': camera.handle},
    );

    return camera;
  }

  static Future<CameraInfo> getCameraInfo(int cameraId) async {
    final Map<String, dynamic> infoMap =
        await CameraChannel.channel.invokeMapMethod<String, dynamic>(
      'Camera#getCameraInfo',
      <String, dynamic>{'cameraId': cameraId},
    );

    return CameraInfo._fromMap(infoMap);
  }

  set previewTexture(NativeTexture texture) {
    assert(!_isClosed);

    CameraChannel.channel.invokeMethod<void>(
      'Camera#previewTexture',
      <String, dynamic>{'handle': handle, 'nativeTexture': texture?.asMap()},
    );
  }

  Future<void> startPreview() {
    assert(!_isClosed);

    return CameraChannel.channel.invokeMethod<void>(
      'Camera#startPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  Future<void> stopPreview() {
    if (_isClosed) return Future<void>.value();

    return CameraChannel.channel.invokeMethod<void>(
      'Camera#stopPreview',
      <String, dynamic>{'handle': handle},
    );
  }

  Future<void> release() {
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      'Camera#release',
      <String, dynamic>{'handle': handle},
    );
  }
}
