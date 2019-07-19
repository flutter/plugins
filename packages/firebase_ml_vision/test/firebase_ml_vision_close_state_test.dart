// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseVision', () {
    test('Barcode Detector', () async {
      final BarcodeDetector detector =
          FirebaseVision.instance.barcodeDetector();
      expect(detector.isClosed, isFalse);
      await detector.close();
      expect(detector.isClosed, isTrue);
    });

    test('Face Detector', () async {
      final FaceDetector detector = FirebaseVision.instance.faceDetector();
      expect(detector.isClosed, isFalse);
      await detector.close();
      expect(detector.isClosed, isTrue);
    });

    test('Text Recognizer', () async {
      final TextRecognizer detector = FirebaseVision.instance.textRecognizer();
      expect(detector.isClosed, isFalse);
      await detector.close();
      expect(detector.isClosed, isTrue);
    });

    test('Image Labeler', () async {
      final ImageLabeler detector = FirebaseVision.instance.imageLabeler();
      expect(detector.isClosed, isFalse);
      await detector.close();
      expect(detector.isClosed, isTrue);
    });
  });
}
