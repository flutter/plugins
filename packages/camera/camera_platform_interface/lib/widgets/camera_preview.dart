// Build the UI texture view of the video data with textureId.
import 'package:flutter/widgets.dart';

import '../camera_controller.dart';

class CameraPreview extends StatelessWidget {
  const CameraPreview(this.controller);

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Texture(textureId: controller.textureId)
        : Container();
  }
}