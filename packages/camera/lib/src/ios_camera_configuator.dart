// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../ios_camera.dart';
import 'common/camera_abstraction.dart';
import 'common/camera_mixins.dart';
import 'common/native_texture.dart';

class IOSCameraConfigurator with CameraClosable implements CameraConfigurator {
  IOSCameraConfigurator(this.device)
      : _session = CaptureSession(),
        assert(device != null) {
    final CaptureDeviceInput input = CaptureDeviceInput(device: device);
    _session.addInput(input);
  }

  final CaptureSession _session;
  NativeTexture _texture;

  final CaptureDevice device;

  @override
  Future<void> addPreviewTexture() async {
    assert(!isClosed);

    if (_texture == null) _texture = await NativeTexture.allocate();

    final CaptureVideoDataOutput output = CaptureVideoDataOutput(
      delegate: CaptureVideoDataOutputSampleBufferDelegate(
        texture: _texture,
      ),
      formatType: PixelFormatType.bgra32,
    );

    _session.addOutput(output);
  }

  @override
  Future<void> dispose() {
    if (isClosed) return Future<void>.value();
    isClosed = true;

    final Completer<void> completer = Completer<void>();

    stop().then((_) => _texture?.release()).then((_) => completer.complete());
    return completer.future;
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    assert(!isClosed);
    return _session.startRunning();
  }

  @override
  Future<void> stop() {
    return _session.stopRunning();
  }
}
