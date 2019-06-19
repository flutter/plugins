// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void imageLabelerTests() {
  group('$ImageLabeler', () {
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();

    test('processImage', () async {
      final String tmpFilename = await _loadImage('assets/test_barcode.jpg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      final List<ImageLabel> labels = await labeler.processImage(visionImage);

      expect(labels.length, greaterThan(0));
    });

    test('close', () {
      expect(labeler.close(), completes);
    });
  });
}
