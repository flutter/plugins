// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_ml_vision_example/detector_painters.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(new MaterialApp(home: _MyHomePage()));

class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  File _imageFile;
  Size _imageSize;
  List<dynamic> _scanResults;
  Detector _currentDetector = Detector.text;

  Future<void> _getAndScanImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = new Completer<Size>();

    final Image image = new Image.file(imageFile);
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

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    FirebaseVisionDetector detector;
    switch (_currentDetector) {
      case Detector.barcode:
        detector = FirebaseVision.instance.barcodeDetector();
        break;
      case Detector.face:
        detector = FirebaseVision.instance.faceDetector();
        break;
      case Detector.label:
        detector = FirebaseVision.instance.labelDetector();
        break;
      case Detector.text:
        detector = FirebaseVision.instance.textDetector();
        break;
      default:
        return;
    }

    final List<dynamic> results =
        await detector.detectInImage(visionImage) ?? <dynamic>[];

    setState(() {
      _scanResults = results;
    });
  }

  CustomPaint _buildResults(Size imageSize, List<dynamic> results) {
    CustomPainter painter;

    switch (_currentDetector) {
      case Detector.barcode:
        painter = new BarcodeDetectorPainter(_imageSize, results);
        break;
      case Detector.face:
        painter = new FaceDetectorPainter(_imageSize, results);
        break;
      case Detector.label:
        painter = new LabelDetectorPainter(_imageSize, results);
        break;
      case Detector.text:
        painter = new TextDetectorPainter(_imageSize, results);
        break;
      default:
        break;
    }

    return new CustomPaint(
      painter: painter,
    );
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
      child: _imageSize == null || _scanResults == null
          ? const Center(
              child: const Text(
                'Scanning...',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : _buildResults(_imageSize, _scanResults),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('ML Vision Example'),
        actions: <Widget>[
          new PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
              if (_imageFile != null) _scanImage(_imageFile);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
                  const PopupMenuItem<Detector>(
                    child: const Text('Detect Barcode'),
                    value: Detector.barcode,
                  ),
                  const PopupMenuItem<Detector>(
                    child: const Text('Detect Face'),
                    value: Detector.face,
                  ),
                  const PopupMenuItem<Detector>(
                    child: const Text('Detect Label'),
                    value: Detector.label,
                  ),
                  const PopupMenuItem<Detector>(
                    child: const Text('Detect Text'),
                    value: Detector.text,
                  ),
                ],
          ),
        ],
      ),
      body: _imageFile == null
          ? const Center(child: const Text('No image selected.'))
          : _buildImage(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _getAndScanImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
