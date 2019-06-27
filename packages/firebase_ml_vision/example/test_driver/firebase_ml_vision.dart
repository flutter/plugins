// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseVision', () {
    final FirebaseVision vision = FirebaseVision.instance;

    group('$BarcodeDetector', () {
      test('detectInImage', () async {
        final String tmpFilename = await _loadImage('assets/test_barcode.jpg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final BarcodeDetector detector = vision.barcodeDetector();
        final List<Barcode> barcodes = await detector.detectInImage(
          visionImage,
        );

        expect(barcodes.length, 1);
      });
    });

    group('$FaceDetector', () {
      test('processImage', () async {
        final String tmpFilename = await _loadImage('assets/test_face.jpg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final FaceDetector detector = vision.faceDetector();
        final List<Face> faces = await detector.processImage(visionImage);

        expect(faces.length, 1);
      });
    });

    group('$ImageLabeler', () {
      test('processImage', () async {
        final String tmpFilename = await _loadImage('assets/test_barcode.jpg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final ImageLabeler labeler = vision.imageLabeler();
        final List<ImageLabel> labels = await labeler.processImage(visionImage);

        expect(labels.length, greaterThan(0));
      });
    });

    group('$TextRecognizer', () {
      test('processImage', () async {
        final String tmpFilename = await _loadImage('assets/test_text.png');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final TextRecognizer recognizer = vision.textRecognizer();
        final VisionText text = await recognizer.processImage(visionImage);

        expect(text.text, 'TEXT');
      });
    });
  });
}

int nextHandle = 0;

// Since there is no way to get the full asset filename, this method loads the
// image into a temporary file.
Future<String> _loadImage(String assetFilename) async {
  final Directory directory = await getTemporaryDirectory();

  final String tmpFilename = path.join(
    directory.path,
    "tmp${nextHandle++}.jpg",
  );

  final ByteData data = await rootBundle.load(assetFilename);
  final Uint8List bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );

  await File(tmpFilename).writeAsBytes(bytes);

  return tmpFilename;
}
