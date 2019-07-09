// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'camera_controller.dart';
import 'common/camera_interface.dart';

/// Uses a [CameraController] to create and orient a camera preview widget.
///
/// This will automatically rotate the camera to match the rotation of the
/// device.
class CameraPreview extends StatefulWidget {
  CameraPreview(this.controller) : assert(controller != null);

  final CameraController controller;

  @override
  State<StatefulWidget> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  RotatedBox _buildPreviewWidget(int textureId) {
    return RotatedBox(
      quarterTurns: 0,
      child: Texture(textureId: textureId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CameraConfigurator configurator = widget.controller.configurator;

    if (configurator.previewTextureId != null) {
      return _buildPreviewWidget(configurator.previewTextureId);
    }

    widget.controller.stop();
    return FutureBuilder<void>(
      future: configurator.addPreviewTexture(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            widget.controller.start();
            return _buildPreviewWidget(configurator.previewTextureId);
        }
        return null; // unreachable
      },
    );
  }
}
