// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await CameraPlatform.instance.availableCameras();

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
  @override
  Widget build(BuildContext context) {
    String availableCameraNames = 'Available cameras:';
    for (final CameraDescription cameraDescription in _cameras) {
      availableCameraNames = '$availableCameraNames ${cameraDescription.name},';
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Example'),
        ),
        body: Center(
          child: Text(availableCameraNames.substring(
              0, availableCameraNames.length - 1)),
        ),
      ),
    );
  }
}
