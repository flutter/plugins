// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of android_camera;

enum CameraDeviceState { closed, disconnected, error, opened }
enum Template { preview }

typedef CameraDeviceStateCallback = void Function(
  CameraDeviceState state,
  CameraDevice device,
);

class CameraDevice with NativeMethodCallHandler, CameraClosable {
  CameraDevice._(this.id, CameraDeviceStateCallback stateCallback)
      : assert(id != null),
        assert(stateCallback != null) {
    CameraChannel.registerCallback(
      handle,
      (dynamic event) {
        final String deviceState = event['$CameraDeviceState'];

        final CameraDeviceState state = CameraDeviceState.values.firstWhere(
          (CameraDeviceState state) => state.toString() == deviceState,
        );

        if (state == CameraDeviceState.closed ||
            state == CameraDeviceState.disconnected ||
            state == CameraDeviceState.error) {
          close();
        }

        stateCallback(state, this);
      },
    );
  }

  final String id;

  CaptureRequest createCaptureRequest(Template template) {
    assert(!isClosed);

    return CaptureRequest._(template: template, targets: <Surface>[]);
  }

  void createCaptureSession(
    List<Surface> outputs,
    CameraCaptureSessionStateCallback callback,
  ) {
    assert(!isClosed);
    assert(outputs != null);
    assert(outputs.isNotEmpty);
    assert(callback != null);

    final CameraCaptureSession session = CameraCaptureSession._(
      handle,
      outputs,
      callback,
    );

    final List<Map<String, dynamic>> outputData = outputs
        .map<Map<String, dynamic>>(
          (Surface surface) => surface.asMap(),
        )
        .toList();

    CameraChannel.channel.invokeMethod<void>(
      '$CameraDevice#createCaptureSession',
      <String, dynamic>{
        'handle': handle,
        'sessionHandle': session.handle,
        'outputs': outputData,
      },
    );
  }

  Future<void> close() {
    if (isClosed) return Future<void>.value();

    isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$CameraDevice#close',
      <String, dynamic>{'handle': handle},
    ).then((_) => CameraChannel.unregisterCallback(handle));
  }
}
