// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

class FirebaseVision {
  FirebaseVision._();

  @visibleForTesting
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/firebase_ml_vision');

  static final FirebaseVision instance = new FirebaseVision._();
}

class FirebaseVisionImage {
  FirebaseVisionImage(this._image);

  final File _image;

  File get image => _image;
}

abstract class FirebaseVisionDetector {
  Future<dynamic> detectInImage(FirebaseVisionImage visionImage);
}
