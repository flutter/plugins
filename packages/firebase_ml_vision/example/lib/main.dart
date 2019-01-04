// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

import 'detector_painters.dart';
import 'utils.dart';

void main() => runApp(MaterialApp(home: _MyHomePage()));

class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  dynamic _scanResults;
  CameraController _camera;

  Detector _currentDetector = Detector.text;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _camera = CameraController(
      await getCamera(_direction),
      ResolutionPreset.low,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;

      final Detector currentDetector = _currentDetector;
      detect(image, _getDetectionMethod()).then(
        (dynamic result) {
          if (currentDetector == _currentDetector) {
            _scanResults = result;
          } else {
            _scanResults = null;
          }

          setState(() {});

          _isDetecting = false;
        },
      ).catchError(
        () {
          _isDetecting = false;
        },
      );
    });
  }

  HandleDetection _getDetectionMethod() {
    final FirebaseVision mlVision = FirebaseVision.instance;

    switch (_currentDetector) {
      case Detector.text:
        return mlVision.textRecognizer().processImage;
      case Detector.barcode:
        return mlVision.barcodeDetector().detectInImage;
      case Detector.label:
        return mlVision.labelDetector().detectInImage;
      case Detector.cloudLabel:
        return mlVision.cloudLabelDetector().detectInImage;
      default:
        assert(_currentDetector == Detector.face);
        return mlVision.faceDetector().detectInImage;
    }
  }

  Widget _buildResults() {
    if (_scanResults == null || _camera == null) {
      return const Text('No results!');
    }

    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );

    switch (_currentDetector) {
      case Detector.barcode:
        painter = BarcodeDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.face:
        painter = FaceDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.label:
        painter = LabelDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.cloudLabel:
        painter = LabelDetectorPainter(imageSize, _scanResults);
        break;
      default:
        assert(_currentDetector == Detector.text);
        painter = TextDetectorPainter(imageSize, _scanResults);
    }

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Vision Example'),
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Barcode'),
                    value: Detector.barcode,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Face'),
                    value: Detector.face,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Label'),
                    value: Detector.label,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Cloud Label'),
                    value: Detector.cloudLabel,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Text'),
                    value: Detector.text,
                  ),
                ],
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }
}
