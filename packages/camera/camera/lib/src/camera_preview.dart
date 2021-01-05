// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        ? AspectRatio(
            aspectRatio: _isLandscape()
                ? controller.value.aspectRatio
                : (1 / controller.value.aspectRatio),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RotatedBox(
                  quarterTurns: _getQuarterTurns(),
                  child:
                      CameraPlatform.instance.buildPreview(controller.cameraId),
                ),
                child ?? Container(),
                Container(color: Colors.white.withOpacity(0.5)),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.value.deviceOrientation.toString()),
                      Text(controller.value.lockedCaptureOrientation
                              ?.toString() ??
                          'NO LOCK'),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  bool _isLandscape() {
    return [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        .contains(controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }

  int _getQuarterTurns() {
    int platformOffset = defaultTargetPlatform == TargetPlatform.iOS ? 1 : 0;
    Map<DeviceOrientation, int> turns = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeRight: 3,
    };
    return turns[controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation] +
        platformOffset;
  }
}
