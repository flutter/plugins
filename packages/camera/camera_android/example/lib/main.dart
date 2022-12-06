// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;
late int _cameraId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await CameraPlatform.instance.availableCameras();
  print(_cameras);
  _cameraId = await CameraPlatform.instance.createCamera(_cameras[1],
      ResolutionPreset.medium);
  await CameraPlatform.instance.initializeCamera(_cameraId, imageFormatGroup: ImageFormatGroup.jpeg);
  runApp(const MyApp());
}

/// Example app
class MyApp extends StatefulWidget {
  /// App instantiation
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Example'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.redAccent,
                      width: 3.0,
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Center(
                        child: CameraPlatform.instance.buildPreview(_cameraId),
                      ))),
            ),
            IconButton(
                // TODO(camsim99): change to stateful widget to change this
                icon: Icon(Icons.pause_circle),
                onPressed: () {
                  buttonPressed = !buttonPressed;
                  if (buttonPressed) {
                    CameraPlatform.instance.pausePreview(_cameraId);
                  } else {
                    CameraPlatform.instance.resumePreview(_cameraId);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
