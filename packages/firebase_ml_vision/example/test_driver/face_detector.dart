// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void faceDetectorTests() {
  group('$FaceDetector', () {
    final FaceDetector detector = FirebaseVision.instance.faceDetector();

    test('processImage', () async {
      final String tmpFilename = await _loadImage('assets/test_face.jpeg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      expectLater(detector.processImage(visionImage), completes);
    });

    test('processImage 1 face', () async {
      final String tmpFilename = await _loadImage('assets/test_face.jpeg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      final List<Face> faces = await detector.processImage(visionImage);

      expect(faces, hasLength(1));
    });

    group('$FaceDetectorOptions', () {
      test('processImage default $FaceDetectorOptions', () async {
        final String tmpFilename = await _loadImage('assets/test_face.jpeg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final List<Face> faces = await detector.processImage(visionImage);

        final Face face = faces[0];
        for (FaceLandmarkType type in FaceLandmarkType.values) {
          expect(face.getLandmark(type), isNull);
        }

        expect(face.smilingProbability, isNull);
        expect(face.leftEyeOpenProbability, isNull);
        expect(face.rightEyeOpenProbability, isNull);
        expect(face.trackingId, isNull);
      });

      test('processImage enableClassification', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(enableClassification: true),
        );

        final String tmpFilename = await _loadImage('assets/test_face.jpeg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final List<Face> faces = await detector.processImage(visionImage);
        final Face face = faces[0];

        expect(face.smilingProbability, isNotNull);
        expect(face.leftEyeOpenProbability, isNotNull);
        expect(face.rightEyeOpenProbability, isNotNull);
      });

      test('processImage enableLandmarks', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(enableLandmarks: true),
        );

        final String tmpFilename = await _loadImage('assets/test_face.jpeg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final List<Face> faces = await detector.processImage(visionImage);
        final Face face = faces[0];

        final List<dynamic> landmarks = List<dynamic>.generate(
          FaceLandmarkType.values.length,
          (int index) => face.getLandmark(FaceLandmarkType.values[index]),
        );

        expect(landmarks, anyElement(isNotNull));
      });

      test('processImage enableTracking', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(enableTracking: true),
        );

        final String tmpFilename = await _loadImage('assets/test_face.jpeg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final List<Face> faces = await detector.processImage(visionImage);
        final Face face = faces[0];

        expect(face.trackingId, 0);
      });

      test('processImage minFaceSize', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(minFaceSize: 0.9),
        );

        final String tmpFilename = await _loadImage(
          'assets/test_face_small.jpg',
        );
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final List<Face> faces = await detector.processImage(visionImage);

        expect(faces, isEmpty);
      });

      test('close', () {
        expect(detector.close(), completes);
      });
    });
  });
}
