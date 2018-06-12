// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

class FirebaseVision {
  FirebaseVision._();

  //@visibleForTesting
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/firebase_ml_vision');

  static final FirebaseVision instance = new FirebaseVision._();

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class VisionImage {

  final File _image;

  VisionImage(this._image);

  File get image => this._image;
}

abstract class VisionDetector {
  static const MethodChannel channel =
  const MethodChannel('plugins.flutter.io/firebase_ml_kit');

  Future<void> detectInImage(VisionImage visionImage);
}
