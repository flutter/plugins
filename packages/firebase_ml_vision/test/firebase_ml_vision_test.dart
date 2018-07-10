// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/services.dart';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseVision', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      FirebaseVision.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'FaceDetector#detectInImage':
            return returnValue;
          case 'TextDetector#detectInImage':
            return returnValue;
          default:
            return null;
        }
      });
      log.clear();
    });

    group('$BarcodeDetector', () {});

    group('$FaceDetector', () {
      List<dynamic> testFaces;

      setUp(() {
        testFaces = <dynamic>[
          <dynamic, dynamic>{
            'left': 0,
            'top': 1,
            'width': 2,
            'height': 3,
            'headEulerAngleY': 4.0,
            'headEulerAngleZ': 5.0,
            'leftEyeOpenProbability': 0.4,
            'rightEyeOpenProbability': 0.5,
            'smilingProbability': 0.2,
            'trackingId': 8,
            'landmarks': <dynamic, dynamic>{
              'bottomMouth': <dynamic>[0.1, 1.1],
              'leftCheek': <dynamic>[2.1, 3.1],
              'leftEar': <dynamic>[4.1, 5.1],
              'leftEye': <dynamic>[6.1, 7.1],
              'leftMouth': <dynamic>[8.1, 9.1],
              'noseBase': <dynamic>[10.1, 11.1],
              'rightCheek': <dynamic>[12.1, 13.1],
              'rightEar': <dynamic>[14.1, 15.1],
              'rightEye': <dynamic>[16.1, 17.1],
              'rightMouth': <dynamic>[18.1, 19.1],
            },
          },
        ];
      });

      test('detectInImage', () async {
        returnValue = testFaces;

        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          new FaceDetectorOptions(
            enableClassification: true,
            enableLandmarks: true,
            enableTracking: false,
            minFaceSize: 0.5,
            mode: FaceDetectorMode.accurate,
          ),
        );

        final FirebaseVisionImage image = new FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<Face> faces = await detector.detectInImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'FaceDetector#detectInImage',
            arguments: <String, dynamic>{
              'path': 'empty',
              'options': <String, dynamic>{
                'enableClassification': true,
                'enableLandmarks': true,
                'enableTracking': false,
                'minFaceSize': 0.5,
                'mode': 'accurate',
              },
            },
          ),
        ]);

        final Face face = faces[0];
        expect(face.boundingBox, const Rectangle<int>(0, 1, 2, 3));
        expect(face.headEulerAngleY, 4.0);
        expect(face.headEulerAngleZ, 5.0);
        expect(face.leftEyeOpenProbability, 0.4);
        expect(face.rightEyeOpenProbability, 0.5);
        expect(face.smilingProbability, 0.2);
        expect(face.trackingId, 8);

        for (FaceLandmarkType type in FaceLandmarkType.values) {
          expect(face.landmark(type).type, type);
        }

        Point<double> p(FaceLandmarkType type) {
          return face.landmark(type).position;
        }

        expect(p(FaceLandmarkType.bottomMouth), const Point<double>(0.1, 1.1));
        expect(p(FaceLandmarkType.leftCheek), const Point<double>(2.1, 3.1));
        expect(p(FaceLandmarkType.leftEar), const Point<double>(4.1, 5.1));
        expect(p(FaceLandmarkType.leftEye), const Point<double>(6.1, 7.1));
        expect(p(FaceLandmarkType.leftMouth), const Point<double>(8.1, 9.1));
        expect(p(FaceLandmarkType.noseBase), const Point<double>(10.1, 11.1));
        expect(p(FaceLandmarkType.rightCheek), const Point<double>(12.1, 13.1));
        expect(p(FaceLandmarkType.rightEar), const Point<double>(14.1, 15.1));
        expect(p(FaceLandmarkType.rightEye), const Point<double>(16.1, 17.1));
        expect(p(FaceLandmarkType.rightMouth), const Point<double>(18.1, 19.1));
      });

      test('detectInImage with null landmark', () async {
        testFaces[0]['landmarks']['bottomMouth'] = null;
        returnValue = testFaces;

        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          new FaceDetectorOptions(),
        );
        final FirebaseVisionImage image = new FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<Face> faces = await detector.detectInImage(image);

        expect(faces[0].landmark(FaceLandmarkType.bottomMouth), null);
      });

      test('detectInImage no faces', () async {
        returnValue = <dynamic>[];

        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          new FaceDetectorOptions(),
        );
        final FirebaseVisionImage image = new FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<Face> faces = await detector.detectInImage(image);
        expect(faces, isEmpty);
      });

      test('close', () async {
        final FaceDetector detector = FirebaseVision.instance.faceDetector(
          new FaceDetectorOptions(),
        );
        await detector.close();

        expect(log, <Matcher>[
          isMethodCall(
            'FaceDetector#close',
            arguments: null,
          ),
        ]);
      });
    });

    group('$LabelDetector', () {});

    group('$TextDetector', () {
      test('detectInImage', () async {
        final Map<dynamic, dynamic> textElement = <dynamic, dynamic>{
          'text': 'hello',
          'left': 1,
          'top': 2,
          'width': 3,
          'height': 4,
          'points': <dynamic>[
            <dynamic>[5, 6],
            <dynamic>[7, 8],
          ],
        };

        final Map<dynamic, dynamic> textLine = <dynamic, dynamic>{
          'text': 'my',
          'left': 5,
          'top': 6,
          'width': 7,
          'height': 8,
          'points': <dynamic>[
            <dynamic>[9, 10],
            <dynamic>[11, 12],
          ],
          'elements': <dynamic>[
            textElement,
          ],
        };

        final List<dynamic> textBlocks = <dynamic>[
          <dynamic, dynamic>{
            'text': 'friend',
            'left': 13,
            'top': 14,
            'width': 15,
            'height': 16,
            'points': <dynamic>[
              <dynamic>[17, 18],
              <dynamic>[19, 20],
            ],
            'lines': <dynamic>[
              textLine,
            ],
          },
        ];

        returnValue = textBlocks;

        final TextDetector detector = FirebaseVision.instance.textDetector();
        final FirebaseVisionImage image =
            new FirebaseVisionImage.fromFilePath('empty');

        final List<TextBlock> blocks = await detector.detectInImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'TextDetector#detectInImage',
            arguments: 'empty',
          ),
        ]);

        final TextBlock block = blocks[0];
        expect(block.boundingBox, const Rectangle<int>(13, 14, 15, 16));
        expect(block.text, 'friend');
        expect(block.cornerPoints, const <Point<int>>[
          Point<int>(17, 18),
          Point<int>(19, 20),
        ]);

        final TextLine line = block.lines[0];
        expect(line.boundingBox, const Rectangle<int>(5, 6, 7, 8));
        expect(line.text, 'my');
        expect(line.cornerPoints, const <Point<int>>[
          Point<int>(9, 10),
          Point<int>(11, 12),
        ]);

        final TextElement element = line.elements[0];
        expect(element.boundingBox, const Rectangle<int>(1, 2, 3, 4));
        expect(element.text, 'hello');
        expect(element.cornerPoints, const <Point<int>>[
          Point<int>(5, 6),
          Point<int>(7, 8),
        ]);
      });

      test('detectInImage no blocks', () async {
        returnValue = <dynamic>[];

        final TextDetector detector = FirebaseVision.instance.textDetector();
        final FirebaseVisionImage image =
            new FirebaseVisionImage.fromFilePath('empty');

        final List<TextBlock> blocks = await detector.detectInImage(image);
        expect(blocks, isEmpty);
      });

      test('close', () async {
        final TextDetector detector = FirebaseVision.instance.textDetector();
        await detector.close();

        expect(log, <Matcher>[
          isMethodCall(
            'TextDetector#close',
            arguments: null,
          ),
        ]);
      });

      test('detectInImage no bounding box', () async {
        returnValue = <dynamic>[
          <dynamic, dynamic>{
            'text': 'potato',
            'points': <dynamic>[
              <dynamic>[17, 18],
              <dynamic>[19, 20],
            ],
            'lines': <dynamic>[],
          },
        ];

        final TextDetector detector = FirebaseVision.instance.textDetector();
        final FirebaseVisionImage image =
            new FirebaseVisionImage.fromFilePath('empty');

        final List<TextBlock> blocks = await detector.detectInImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'TextDetector#detectInImage',
            arguments: 'empty',
          ),
        ]);

        final TextBlock block = blocks[0];
        expect(block.boundingBox, null);
        expect(block.text, 'potato');
        expect(block.cornerPoints, const <Point<int>>[
          Point<int>(17, 18),
          Point<int>(19, 20),
        ]);
      });
    });
  });
}
