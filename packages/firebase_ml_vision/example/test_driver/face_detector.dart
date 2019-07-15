// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void faceDetectorTests() {
  group('$FaceDetector', () {
    final FaceDetector detector = FirebaseVision.instance.faceDetector();

    test('processImage', () async {
      final String tmpFilename = await _loadImage('assets/test_face.jpg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      final List<Face> faces = await detector.processImage(visionImage);

      expect(faces.length, 1);
    });

    test('close', () {
      expect(detector.close(), completes);
    });
  });
}
