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
  File _image;

  Future<void> getImage() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextDetector detector = FirebaseVision.instance.getTextDetector();
    final List<TextBlock> blocks = await detector.detectInImage(visionImage);

    for (TextBlock block in blocks) {
      print(block.text);
    }

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Image Picker Example'),
      ),
      body: new Center(
        child: _image == null
            ? const Text('No image selected.')
            : new Image.file(_image),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
