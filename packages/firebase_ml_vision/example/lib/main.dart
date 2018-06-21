// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(new MaterialApp(home: _MyHomePage()));

class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  File _imageFile;
  Size _imageSize;
  List<TextBlock> _textLocations;

  Future<void> _getImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
      _textLocations = null;
    });

    final File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _scanImage() async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(_imageFile);
    final TextDetector detector = FirebaseVision.instance.getTextDetector();
    final List<TextBlock> blocks = await detector.detectInImage(visionImage);

    setState(() {
      _textLocations = blocks;
    });

    detector.close();
  }

  Future<void> _getImageSize(Image image) async {
    final Completer<Size> completer = new Completer<Size>();
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  Widget _buildImage() {
    return new Container(
      constraints: const BoxConstraints.expand(),
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: Image.file(_imageFile).image,
          fit: BoxFit.fill,
        ),
      ),
      child: _imageSize == null || _textLocations == null
          ? const Center(
              child: const Text(
              "Scanning...",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 30.0,
              ),
            ))
          : new CustomPaint(
              painter: new ScannedTextPainter(_imageSize, _textLocations),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('ML Vision Example'),
      ),
      body: _imageFile == null
          ? const Center(child: const Text("No image selected."))
          : _buildImage(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () async {
          await _getImage();
          if (_imageFile != null) {
            _getImageSize(Image.file(_imageFile));
            _scanImage();
          }
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

// Paints rectangles around all the text in the image.
class ScannedTextPainter extends CustomPainter {
  ScannedTextPainter(this.absoluteImageSize, this.textLocations);

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
  bool shouldRepaint(ScannedTextPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.textLocations != textLocations;
  }
}
