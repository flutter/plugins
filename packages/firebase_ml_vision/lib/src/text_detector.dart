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
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'TextDetector#detectInImage',
      visionImage.imageFile.path,
    );

    final List<TextBlock> blocks = <TextBlock>[];
    reply.forEach((dynamic block) {
      blocks.add(new TextBlock._(block));
    });

    return blocks;
  }
}

/// Abstract class representing dimensions of recognized text in an image.
abstract class TextContainer {
  TextContainer._(Map<dynamic, dynamic> data)
      : boundingBox = Rectangle<num>(
          data['left'],
          data['top'],
          data['width'],
          data['height'],
        ),
        cornerPoints = data['points']
            .map<Point<num>>((dynamic item) => Point<num>(
                  item[0],
                  item[1],
                ))
            .toList(),
        text = data['text'];

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
  TextBlock._(Map<dynamic, dynamic> block)
      : _lines = block['lines']
            .map<TextLine>((dynamic line) => TextLine._(line))
            .toList(),
        super._(block);

  final List<TextLine> _lines;

  List<TextLine> get lines => List<TextLine>.from(_lines);
}

/// Represents a line of text.
class TextLine extends TextContainer {
  TextLine._(Map<dynamic, dynamic> line)
      : _elements = line['elements']
            .map<TextElement>((dynamic element) => TextElement._(element))
            .toList(),
        super._(line);

  final List<TextElement> _elements;

  List<TextElement> get elements => List<TextElement>.from(_elements);
}

/// Roughly equivalent to a space-separated "word."
///
/// Separates elements into words in most Latin languages, but could separate
/// by characters in others.
///
/// If a word is split between two lines by a hyphen, each part is encoded as a
/// separate element.
class TextElement extends TextContainer {
  TextElement._(Map<dynamic, dynamic> element) : super._(element);
}
