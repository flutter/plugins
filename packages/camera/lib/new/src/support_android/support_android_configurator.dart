// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../common/camera_interface.dart';
import '../common/native_texture.dart';
import 'camera.dart';
import 'camera_info.dart';

/// Default [CameraConfigurator] for [CameraApi.supportAndroid].
///
/// This is used as the default [CameraConfigurator] for Android sdks below 21
/// when using [CameraController].
///
/// This can also be used independently of [CameraController] when one needs
/// greater control of a camera on Android sdks below 21.
class SupportAndroidConfigurator implements CameraConfigurator {
  SupportAndroidConfigurator(this.info) : assert(info != null);

  static const String _isDisposedMessage = 'This controller has been disposed.';

  NativeTexture _texture;
  Camera _camera;
  bool _isDisposed = false;

  final CameraInfo info;

  Camera get camera => _camera;

  @override
  Future<int> addPreviewTexture() {
    assert(!_isDisposed, _isDisposedMessage);

    final Completer<int> completer = Completer<int>();

    if (_texture == null) {
      NativeTexture.allocate().then((NativeTexture texture) {
        _texture = texture;
        _camera.previewTexture = _texture;
        completer.complete(_texture.textureId);
      });

      return completer.future;
    } else {
      return Future<int>.value(_texture.textureId);
    }
  }

  @override
  Future<void> dispose() {
    _isDisposed = true;

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
    assert(!_isDisposed, _isDisposedMessage);
    return _camera.startPreview();
  }

  @override
  Future<void> stop() {
    assert(!_isDisposed, _isDisposedMessage);
    return _camera.stopPreview();
  }

  @override
  // ignore: missing_return
  Future<void> initialize() {
    assert(!_isDisposed, _isDisposedMessage);
    _camera = Camera.open(info.id);
  }
}
