// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Detector for performing optical character recognition(OCR) on an input image.
///
/// A text detector is created via getVisionTextDetector() in [FirebaseVision]:
///
/// ```dart
/// TextDetector textDetector = FirebaseVision.instance.getTextDetector();
/// ```
class TextDetector implements FirebaseVisionDetector {
  TextDetector._();

  /// Detects text in the input image.
  ///
  /// The OCR is performed asynchronously.
  @override
  Future<List<TextBlock>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply =
        await FirebaseVision.channel.invokeMethod(
      'TextDetector#detectInImage',
      visionImage.imageFile.path,
    );

    final List<TextBlock> blocks = <TextBlock>[];
    reply.forEach((dynamic data) {
      blocks.add(new TextBlock._(data));
    });

    return blocks;
  }
}

abstract class TextContainer {
  TextContainer._(Map<dynamic, dynamic> data)
      : text = data['text'],
        boundingBox = Rectangle<num>(
          data['left'],
          data['top'],
          data['width'],
          data['height'],
        ),
        cornerPoints = data['points'] == null
            ? null
            : data['points']
                .map<Point<num>>((dynamic item) => Point<num>(
                      item[0],
                      item[1],
                    ))
                .toList();

  /// Axis-aligned bounding rectangle of the detected text.
  final Rectangle<num> boundingBox;

  /// The four corner points in clockwise direction starting with top-left.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a
  /// rectangle. Parts of the region could be outside of the image.
  final List<Point<num>> cornerPoints;

  /// The recognized text as a string.
  ///
  /// Returned in reading order for the language. For Latin, this is top to
  /// bottom within a Block, and left-to-right within a Line.
  final String text;
}

/// A block of text (think of it as a paragraph) as deemed by the OCR engine.
class TextBlock extends TextContainer {
  TextBlock._(Map<dynamic, dynamic> data)
      : _lines = data['lines'] == null
      ? null
      : data['lines']
      .map<TextLine>((dynamic item) => TextLine._(item))
      .toList(),
        super._(data);

  final List<TextLine> _lines;

  List<TextLine> get lines => List<TextLine>.from(_lines);
}


class TextLine extends TextContainer {
  TextLine._(Map<dynamic, dynamic> data)
      : _elements = data['elements'] == null
      ? null
      : data['elements']
      .map<TextElement>((dynamic item) => TextElement._(item))
      .toList(),
        super._(data);

  final List<TextElement> _elements;

  List<TextElement> get elements => List<TextElement>.from(_elements);
}

class TextElement extends TextContainer {
  TextElement._(Map<dynamic, dynamic> data) : super._(data);
}
