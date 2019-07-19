// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'detector_painters.dart';
import 'utils.dart';
import 'package:flutter/material.dart';

import 'camera_preview_scanner.dart';
import 'material_barcode_scanner.dart';
import 'picture_scanner.dart';

void main() {
  runApp(
    MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => _ExampleList(),
        '/$PictureScanner': (BuildContext context) => PictureScanner(),
        '/$CameraPreviewScanner': (BuildContext context) =>
            CameraPreviewScanner(),
        '/$MaterialBarcodeScanner': (BuildContext context) =>
            const MaterialBarcodeScanner(),
      },
    ),
  );
}

class _ExampleList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExampleListState();
}

class _ExampleListState extends State<_ExampleList> {
  static final List<String> _exampleWidgetNames = <String>[
    '$PictureScanner',
    '$CameraPreviewScanner',
    '$MaterialBarcodeScanner',
  ];

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
        title: const Text('Example List'),
      ),
      body: ListView.builder(
        itemCount: _exampleWidgetNames.length,
        itemBuilder: (BuildContext context, int index) {
          final String widgetName = _exampleWidgetNames[index];

          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: ListTile(
              title: Text(widgetName),
              onTap: () => Navigator.pushNamed(context, '/$widgetName'),
            ),
          );
        },
      ),
    );
  }
}
