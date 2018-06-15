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
  Image _image;
  List<TextBlock> _blocks;

  Future<void> _getImage() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextDetector detector = FirebaseVision.instance.getTextDetector();
    final List<TextBlock> blocks = await detector.detectInImage(visionImage);

    setState(() {
      _image = Image.file(image);
      _blocks = blocks;
    });
  }

  Future<Size> _getImageSize(Image image) {
    final Completer<Size> completer = new Completer<Size>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener((ImageInfo info, bool _) => completer.complete(Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            )));
    return completer.future;
  }

  List<Widget> buildTextDetectionStack(Size imageSize) {
    final List<Widget> textDetection = <Widget>[];
    textDetection.add(_image);

    final Size screenSize = MediaQuery.of(context).size;
    final Size scale = new Size(
      screenSize.width / imageSize.width,
      screenSize.height / imageSize.height,
    );

    for (TextBlock block in _blocks) {
      print('Text block text: ${block.text}');

      textDetection.add(new Positioned(
        left: block.boundingBox.left * scale.width,
        top: block.boundingBox.top * scale.height,
        right: screenSize.width - (block.boundingBox.right * scale.width),
        bottom: screenSize.height - (block.boundingBox.bottom * scale.height),
        child: new Container(
          decoration: new BoxDecoration(
            color: Colors.transparent,
            border: new Border.all(
              width: 2.0,
              color: Colors.red,
            ),
          ),
        ),
      ));
    }

    return textDetection;
  }

  Future<Stack> _buildStack() async {
    final Size size = await _getImageSize(_image);

    return new Stack(
      children: buildTextDetectionStack(size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Image Picker Example'),
      ),
      body: _image == null
          ? const Center(
              child: const Text("No image selected."),
            )
          : new FutureBuilder<Stack>(
              future: _buildStack(),
              builder: (BuildContext context, AsyncSnapshot<Stack> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else {
                  return const Center(
                    child: const Text("Scanning for text..."),
                  );
                }
              },
            ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
