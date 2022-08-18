// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  try {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await CameraPlatform.instance.availableCameras();
  } catch (e) {
    print(e);
  }

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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Available cameras:'),
        ),
        body: Center(
          child: _cameras.isEmpty ? const Text('RIP') : const Text('YAY'),
        ),
      ),
    );
  }
}
