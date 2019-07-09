// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController _controller;
  LensDirection _lensDirection = LensDirection.back;

  @override
  void initState() {
    super.initState();
    _getCameraPermission().then((bool success) {
      if (success) _setupCamera();
    });
  }

  Future<bool> _getCameraPermission() async {
    final PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(
      PermissionGroup.camera,
    );

    if (permission == PermissionStatus.granted) {
      return true;
    }

    final Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions(
      <PermissionGroup>[PermissionGroup.camera],
    );

    return permissions[PermissionGroup.camera] == PermissionStatus.granted;
  }

  Future<void> _setupCamera() async {
    final List<CameraDescription> cameras =
        await CameraController.availableCameras();
    final CameraDescription camera = cameras.firstWhere(
      (CameraDescription desc) => desc.direction == _lensDirection,
    );

    setState(() {
      _controller = CameraController(description: camera);
    });
  }

  Future<void> _toggleLensDirection() async {
    await _controller.dispose();

    setState(() {
      _controller = null;
    });

    switch (_lensDirection) {
      case LensDirection.front:
        _lensDirection = LensDirection.back;
        break;
      case LensDirection.back:
        _lensDirection = LensDirection.front;
        break;
      case LensDirection.external:
        _lensDirection = LensDirection.front;
        break;
    }

    return _setupCamera();
  }

  Widget _buildPictureButton() {
    return InkResponse(
      onTap: () {},
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2)),
        child: Icon(
          Icons.camera,
          color: Colors.grey,
          size: 60,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: _controller != null
                  ? CameraPreview(_controller)
                  : Container(),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              bottom: 30,
              left: 10,
              right: 10,
              top: 15,
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  child: Transform.rotate(
                    angle: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _toggleLensDirection,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: _buildPictureButton(),
                )
              ],
            ),
            decoration: BoxDecoration(color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
