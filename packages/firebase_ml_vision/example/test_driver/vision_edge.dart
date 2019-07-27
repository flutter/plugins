// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void visionEdgeTests() {
  group('$VisionEdgeImageLabeler', () {
    final VisionEdgeImageLabeler visionEdgeLabeler = FirebaseVision.instance
        .visionEdgeImageLabeler('potholes', ModelLocation.Local);

    test('processImage', () async {
      final String tmpFilename = await _loadImage('assets/test_barcode.jpg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);
      final List<VisionEdgeImageLabel> labels =
          await visionEdgeLabeler.processImage(visionImage);

      expect(labels.length, greaterThan(0));
    });
  });
}
