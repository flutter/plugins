// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

CustomPaint customPaintForResults(
    FirebaseVisionDetectorType detector, Size imageSize, List<dynamic> results) {
  CustomPainter painter;
  switch (detector) {
    case FirebaseVisionDetectorType.barcode:
      try {
        painter = new BarcodeDetectorPainter(imageSize, results.cast());
      } on CastError {
        painter = null;
      }
      break;
    case FirebaseVisionDetectorType.face:
      painter = new FaceDetectorPainter(imageSize, results);
      break;
    case FirebaseVisionDetectorType.label:
      painter = new LabelDetectorPainter(imageSize, results);
      break;
    case FirebaseVisionDetectorType.text:
      try {
        painter = new TextDetectorPainter(imageSize, results.cast());
      } on CastError {
        painter = null;
      }
      break;
    default:
      break;
  }

  return new CustomPaint(
    painter: painter,
  );
}

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(this.absoluteImageSize, this.results);

  final Size absoluteImageSize;
  final List<BarcodeContainer> results;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(BarcodeContainer container) {
      return new Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = new Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (BarcodeContainer barcode in results) {
      paint.color = Colors.red;
      canvas.drawRect(scaleRect(barcode), paint);
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.results != results;
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.results);

  final Size absoluteImageSize;
  final List<dynamic> results;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class LabelDetectorPainter extends CustomPainter {
  LabelDetectorPainter(this.absoluteImageSize, this.results);

  final Size absoluteImageSize;
  final List<dynamic> results;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

// Paints rectangles around all the text in the image.
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.textLocations);

  final Size absoluteImageSize;
  final List<TextBlock> textLocations;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return new Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = new Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (TextBlock block in textLocations) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          paint.color = Colors.green;
          canvas.drawRect(scaleRect(element), paint);
        }

        paint.color = Colors.yellow;
        canvas.drawRect(scaleRect(line), paint);
      }

      paint.color = Colors.red;
      canvas.drawRect(scaleRect(block), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.textLocations != textLocations;
  }
}
