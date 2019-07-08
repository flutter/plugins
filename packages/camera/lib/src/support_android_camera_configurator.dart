// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../support_android_camera.dart';
import 'common/camera_interface.dart';
import 'common/camera_mixins.dart';
import 'common/native_texture.dart';

/// Default configurator for the [CameraApi.supportAndroid].
class SupportAndroidCameraConfigurator
    with CameraClosable
    implements CameraConfigurator {
  SupportAndroidCameraConfigurator(this.info) : assert(info != null) {
    _camera = SupportAndroidCamera.open(info.id);
  }

  NativeTexture _texture;
  SupportAndroidCamera _camera;

  final CameraInfo info;

  SupportAndroidCamera get camera => _camera;

  @override
  Future<void> addPreviewTexture() async {
    assert(!isClosed);
    if (_texture == null) _texture = await NativeTexture.allocate();
    _camera.previewTexture = _texture;
  }

  @override
  Future<void> dispose() {
    isClosed = true;

    final Completer<void> completer = Completer<void>();

    _camera
        .release()
        .then((_) => _texture?.release())
        .then((_) => completer.complete());

    return completer.future;
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    assert(!isClosed);
    return _camera.startPreview();
  }

  @override
  Future<void> stop() {
    return _camera.stopPreview();
  }
}
