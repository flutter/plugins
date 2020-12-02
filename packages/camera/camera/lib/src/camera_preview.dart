// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of camera;

/// A widget showing a live camera preview.
class CameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const CameraPreview(this.controller);

  /// The controller for the camera that the preview is shown for.
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Texture(textureId: controller._cameraId)
        : Container();
  }
}
