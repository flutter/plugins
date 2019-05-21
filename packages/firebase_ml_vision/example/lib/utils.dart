import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';

typedef HandleDetection = Future<dynamic> Function(FirebaseVisionImage image);

Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
    (List<CameraDescription> cameras) => cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == dir,
        ),
  );
}

Uint8List concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

FirebaseVisionImageMetadata buildMetaData(
  CameraImage image,
  ImageRotation rotation,
) {
  return FirebaseVisionImageMetadata(
    rawFormat: image.format.raw,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    planeData: image.planes.map(
      (Plane plane) {
        return FirebaseVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList(),
  );
}

Future<dynamic> detect(
  CameraImage image,
  HandleDetection handleDetection,
  ImageRotation rotation,
) async {
  return handleDetection(
    FirebaseVisionImage.fromBytes(
      concatenatePlanes(image.planes),
      buildMetaData(image, rotation),
    ),
  );
}

ImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return ImageRotation.rotation0;
    case 90:
      return ImageRotation.rotation90;
    case 180:
      return ImageRotation.rotation180;
    default:
      assert(rotation == 270);
      return ImageRotation.rotation270;
  }
}
