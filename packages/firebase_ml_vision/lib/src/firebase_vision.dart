// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// The Firebase machine learning vision API.
///
/// You can get an instance by calling [FirebaseVision.instance] and then get
/// a detector from the instance:
///
/// ```dart
/// TextDetector textDetector = FirebaseVision.instance.getTextDetector();
/// ```
class FirebaseVision {
  FirebaseVision._();

  @visibleForTesting
  static const MethodChannel channel =
      const MethodChannel('plugins.flutter.io/firebase_ml_vision');

  /// Singleton of [FirebaseVision].
  ///
  /// Use this get an instance of a detector:
  ///
  /// ```dart
  /// TextDetector textDetector = FirebaseVision.instance.getTextDetector();
  /// ```
  static final FirebaseVision instance = new FirebaseVision._();

  /// Creates an instance of [TextDetector];
  TextDetector getTextDetector() => new TextDetector._();
}

/// Represents an image object used for both on-device and cloud API detectors.
///
/// Create an instance by calling one of the factory constructors.
class FirebaseVisionImage {
  FirebaseVisionImage._(this.imageFile);

  factory FirebaseVisionImage.fromFile(File imageFile) {
    return FirebaseVisionImage._(imageFile);
  }

  factory FirebaseVisionImage.fromFilePath(String imagePath) {
    return FirebaseVisionImage._(new File(imagePath));
  }

  final File imageFile;
}

/// Abstract class for detectors in [FirebaseVision] API.
abstract class FirebaseVisionDetector {
  Future<dynamic> detectInImage(FirebaseVisionImage visionImage);
}
