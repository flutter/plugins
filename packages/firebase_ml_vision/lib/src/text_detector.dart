// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

class TextDetector implements FirebaseVisionDetector {
  TextDetector._();

  @override
  Future<List<TextBlock>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply =
        await FirebaseVision.channel.invokeMethod(
      'TextDetector#detectInImage',
      visionImage.image.path,
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

  final String text;
  final Rectangle<num> boundingBox;
  final List<Point<num>> cornerPoints;
}

class TextBlock extends TextContainer {
  final List<TextLine> lines;

  TextBlock._(Map<dynamic, dynamic> data)
      : lines = data['lines'] == null
            ? null
            : data['lines']
                .map<TextLine>((dynamic item) => TextLine._(item))
                .toList(),
        super._(data);
}

class TextLine extends TextContainer {
  final List<TextElement> elements;

  TextLine._(Map<dynamic, dynamic> data)
      : elements = data['elements'] == null
            ? null
            : data['elements']
                .map<TextElement>((dynamic item) => TextElement._(item))
                .toList(),
        super._(data);
}

class TextElement extends TextContainer {
  TextElement._(Map<dynamic, dynamic> data) : super._(data);
}
