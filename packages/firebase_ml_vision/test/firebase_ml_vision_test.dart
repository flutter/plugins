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
      test('detectInImage', () async {
        returnValue = <dynamic>[
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
              'bottomMouth': <dynamic>[0, 1],
              'leftCheek': <dynamic>[2, 3],
              'leftEar': <dynamic>[4, 5],
              'leftEye': <dynamic>[6, 7],
              'leftMouth': <dynamic>[8, 9],
              'noseBase': <dynamic>[10, 11],
              'rightCheek': <dynamic>[12, 13],
              'rightEar': <dynamic>[14, 15],
              'rightEye': <dynamic>[16, 17],
              'rightMouth': <dynamic>[18, 19],
            },
          },
        ];

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
              'enableClassification': true,
              'enableLandmarks': true,
              'enableTracking': false,
              'minFaceSize': 0.5,
              'mode': 'accurate',
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

        expect(
          face.landmark(FaceLandmarkType.bottomMouth).type,
          FaceLandmarkType.bottomMouth,
        );
        expect(
          face.landmark(FaceLandmarkType.bottomMouth).position,
          const Point<int>(0, 1),
        );

        expect(
          face.landmark(FaceLandmarkType.leftCheek).type,
          FaceLandmarkType.leftCheek,
        );
        expect(
          face.landmark(FaceLandmarkType.leftCheek).position,
          const Point<int>(2, 3),
        );

        expect(
          face.landmark(FaceLandmarkType.leftEar).type,
          FaceLandmarkType.leftEar,
        );
        expect(
          face.landmark(FaceLandmarkType.leftEar).position,
          const Point<int>(4, 5),
        );

        expect(
          face.landmark(FaceLandmarkType.leftEye).type,
          FaceLandmarkType.leftEye,
        );
        expect(
          face.landmark(FaceLandmarkType.leftEye).position,
          const Point<int>(6, 7),
        );

        expect(
          face.landmark(FaceLandmarkType.leftMouth).type,
          FaceLandmarkType.leftMouth,
        );
        expect(
          face.landmark(FaceLandmarkType.leftMouth).position,
          const Point<int>(8, 9),
        );

        expect(
          face.landmark(FaceLandmarkType.noseBase).type,
          FaceLandmarkType.noseBase,
        );
        expect(
          face.landmark(FaceLandmarkType.noseBase).position,
          const Point<int>(10, 11),
        );

        expect(
          face.landmark(FaceLandmarkType.rightCheek).type,
          FaceLandmarkType.rightCheek,
        );
        expect(
          face.landmark(FaceLandmarkType.rightCheek).position,
          const Point<int>(12, 13),
        );

        expect(
          face.landmark(FaceLandmarkType.rightEar).type,
          FaceLandmarkType.rightEar,
        );
        expect(
          face.landmark(FaceLandmarkType.rightEar).position,
          const Point<int>(14, 15),
        );

        expect(
          face.landmark(FaceLandmarkType.rightEye).type,
          FaceLandmarkType.rightEye,
        );
        expect(
          face.landmark(FaceLandmarkType.rightEye).position,
          const Point<int>(16, 17),
        );

        expect(
          face.landmark(FaceLandmarkType.rightMouth).type,
          FaceLandmarkType.rightMouth,
        );
        expect(
          face.landmark(FaceLandmarkType.rightMouth).position,
          const Point<int>(18, 19),
        );
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
        expect(block.cornerPoints, <Point<int>>[
          const Point<int>(17, 18),
          const Point<int>(19, 20),
        ]);

        final TextLine line = block.lines[0];
        expect(line.boundingBox, const Rectangle<int>(5, 6, 7, 8));
        expect(line.text, 'my');
        expect(line.cornerPoints, <Point<int>>[
          const Point<int>(9, 10),
          const Point<int>(11, 12),
        ]);

        final TextElement element = line.elements[0];
        expect(element.boundingBox, const Rectangle<int>(1, 2, 3, 4));
        expect(element.text, 'hello');
        expect(element.cornerPoints, <Point<int>>[
          const Point<int>(5, 6),
          const Point<int>(7, 8),
        ]);
      });

      test('detectInImage no blocks', () async {
        returnValue = <dynamic>[];

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
        expect(block.cornerPoints, <Point<int>>[
          const Point<int>(17, 18),
          const Point<int>(19, 20),
        ]);
      });
    });
  });
}
