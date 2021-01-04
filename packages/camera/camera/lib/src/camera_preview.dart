// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget showing a live camera preview.
class CameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const CameraPreview(this.controller, {this.child});

  /// The controller for the camera that the preview is shown for.
  final CameraController controller;

  /// A widget to overlay on top of the camera preview
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? RotatedBox(
            quarterTurns: _getQuarterTurns(),
            child: AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: CameraPlatform.instance.buildPreview(controller.cameraId),
            ),
          )
        : Container();
  }

  int _getQuarterTurns() {
    int platformOffset = defaultTargetPlatform == TargetPlatform.iOS ? 1 : 0;
    return platformOffset;
  }
}
