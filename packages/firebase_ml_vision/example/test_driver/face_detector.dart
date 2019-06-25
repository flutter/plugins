// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void faceDetectorTests() {
  group('$FaceDetector', () {
    final FaceDetector sharedDetector = FirebaseVision.instance.faceDetector();

    test('processImage 1 face', () async {
      final String tmpFilename = await _loadImage('assets/test_face.jpeg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      final List<Face> faces = await sharedDetector.processImage(visionImage);

      expect(faces, hasLength(1));
    });

    test('close', () async {
      await expectLater(sharedDetector.close(), completes);
    });

    group('$FaceDetectorOptions', () {
      test('processImage default $FaceDetectorOptions', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(),
        );

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

      test('enableClassification', () async {
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

        detector.close();
      });

      test('enableLandmarks', () async {
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

        detector.close();
      });

      test('enableTracking', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(enableTracking: true),
        );

        final String tmpFilename = await _loadImage('assets/test_face.jpeg');
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        final List<Face> faces = await detector.processImage(visionImage);
        final Face face = faces[0];

        expect(face.trackingId, 0);

        detector.close();
      });

      // TODO(bparrishMines): Get this test to pass on iOS. Potentially a MLKit bug.
      test('minFaceSize', () async {
        final String tmpFilename = await _loadImage(
          'assets/test_face_small.png',
        );

        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFilePath(tmpFilename);

        FaceDetector detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(),
        );

        await expectLater(await detector.processImage(visionImage), isNotEmpty);

        detector.close();

        detector = FirebaseVision.instance.faceDetector(
          const FaceDetectorOptions(minFaceSize: 0.9),
        );

        await expectLater(await detector.processImage(visionImage), isEmpty);

        detector.close();
      }, skip: defaultTargetPlatform == TargetPlatform.iOS);
    });
  });
}
