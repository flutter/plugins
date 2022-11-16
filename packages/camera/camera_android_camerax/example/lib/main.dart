// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;
late int _cameraId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // _cameras = await CameraPlatform.instance.availableCameras();
  _cameraId = await CameraPlatform.instance.createCamera(const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90), ResolutionPreset.medium);
  print("CAMILLE, camera id : $_cameraId");
  runApp(const MyApp());
}

/// Example app
class MyApp extends StatefulWidget {
  /// App instantiation
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  IconData currButtonIcon = Icons.pause_circle; // THIS NEEDS TO BE A STATEFUL WIDGET FOR THIS TO WORK
  bool buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    // String availableCameraNames = 'Available cameras:';
    // for (final CameraDescription cameraDescription in _cameras) {
    //   availableCameraNames = '$availableCameraNames ${cameraDescription.name},';
    // }

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
                      )
                    )
                  ),
                ),
                IconButton(
                  icon: Icon(currButtonIcon),
                  onPressed: () {
                    buttonPressed = !buttonPressed;
                    if (buttonPressed) {
                      CameraPlatform.instance.pausePreview(_cameraId);
                      currButtonIcon = Icons.play_circle;
                    } else {
                      CameraPlatform.instance.resumePreview(_cameraId);
                      currButtonIcon = Icons.pause_circle;
                    }
                  }
                ),
              ],
            ),
            // child: CameraPlatform.instance.buildPreview(_cameraId),
          // child: Text(availableCameraNames.substring(
          //     0, availableCameraNames.length - 1)),
        ),
    );
  }
}
