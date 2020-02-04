// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'camera_channel.dart';
import 'camera_mixins.dart';

/// Used to allocate a buffer for displaying a preview camera texture.
///
/// This is used to for a developer to have a control over the
/// `TextureRegistry.SurfaceTextureEntry` (Android) and FlutterTexture (iOS).
/// This gives direct access to the textureId and can be reused with separate
/// camera instances.
///
/// The [textureId] can be passed to a [Texture] widget.
class NativeTexture with CameraMappable {
  NativeTexture._({@required int handle, @required this.textureId})
      : _handle = handle,
        assert(handle != null),
        assert(textureId != null);

  final int _handle;

  bool _isClosed = false;

  /// Id that can be passed to a [Texture] widget.
  final int textureId;

  static Future<NativeTexture> allocate() async {
    final int handle = CameraChannel.nextHandle++;

    final int textureId = await CameraChannel.channel.invokeMethod<int>(
      '$NativeTexture#allocate',
      <String, dynamic>{'textureHandle': handle},
    );

    return NativeTexture._(handle: handle, textureId: textureId);
  }

  /// Deallocate this texture.
  Future<void> release() {
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$NativeTexture#release',
      <String, dynamic>{'handle': _handle},
    );
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{'handle': _handle};
  }
}
