// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of android_camera;

typedef CameraCaptureSessionStateCallback = Function(
  CameraCaptureSessionState state,
  CameraCaptureSession session,
);

enum CameraCaptureSessionState { configured, configureFailed, closed }

class CameraCaptureSession with NativeMethodCallHandler, CameraClosable {
  CameraCaptureSession._(
    this._cameraDeviceHandle,
    List<Surface> outputs,
    CameraCaptureSessionStateCallback stateCallback,
  )   : outputs = List<Surface>.unmodifiable(outputs),
        assert(_cameraDeviceHandle != null),
        assert(outputs != null),
        assert(outputs.isNotEmpty),
        assert(stateCallback != null) {
    CameraChannel.registerCallback(
      handle,
      (dynamic event) {
        final String deviceState = event['$CameraCaptureSessionState'];

        final CameraCaptureSessionState state =
            CameraCaptureSessionState.values.firstWhere(
          (CameraCaptureSessionState state) => state.toString() == deviceState,
        );

        if (state == CameraCaptureSessionState.configureFailed ||
            state == CameraCaptureSessionState.closed) {
          close();
        }
        stateCallback(state, this);
      },
    );
  }

  final int _cameraDeviceHandle;

  final List<Surface> outputs;

  Future<void> setRepeatingRequest({@required CaptureRequest request}) {
    assert(!isClosed);
    assert(request != null);
    assert(request.targets.isNotEmpty);
    assert(request.targets.every(
      (Surface surface) => outputs.contains(surface),
    ));

    return CameraChannel.channel.invokeMethod<void>(
      '$CameraCaptureSession#setRepeatingRequest',
      <String, dynamic>{
        'handle': handle,
        'cameraDeviceHandle': _cameraDeviceHandle,
        'captureRequest': request.asMap(),
      },
    );
  }

  Future<void> close() {
    if (isClosed) return Future<void>.value();

    isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$CameraCaptureSession#close',
      <String, dynamic>{'handle': handle},
    ).then((_) => CameraChannel.unregisterCallback(handle));
  }
}
