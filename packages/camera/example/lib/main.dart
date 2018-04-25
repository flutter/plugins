import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return new _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Camera example'),
      ),
      body: new Column(children: <Widget>[
        new Expanded(
          child: new Container(
            child: new Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Center(
                child: _cameraPreviewWidget(),
              ),
            ),
            decoration: new BoxDecoration(
              color: Colors.black,
              border: new Border.all(
                color: controller != null && controller.value.isRecordingVideo
                    ? Colors.redAccent
                    : Colors.grey,
                width: 3.0,
              ),
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ]),
        ),
        _captureControlRowWidget(),
      ]),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new CameraPreview(controller),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: videoController == null && imagePath == null
            ? null
            : new SizedBox(
                child: (videoController == null)
                    ? new Image.file(new File(imagePath))
                    : new Container(
                        child: new Center(
                          child: new AspectRatio(
                              aspectRatio: videoController.value.size != null
                                  ? videoController.value.aspectRatio
                                  : 1.0,
                              child: new VideoPlayer(videoController)),
                        ),
                        decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.pink)),
                      ),
                width: 64.0,
                height: 64.0,
              ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        new IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        new IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        )
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
                title: new Icon(
                    getCameraLensIcon(cameraDescription.lensDirection)),
                groupValue: controller?.description,
                value: cameraDescription,
                onChanged: (CameraDescription newValue) async =>
                    onNewCameraSelected(newValue)),
          ),
        );
      }
    }

    return new Row(children: toggles);
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (imagePath != null) showInSnackBar('Picture saved to $imagePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (imagePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  Future<void> onStopButtonPressed() async {
    await stopVideoRecording();
    if (!mounted) {
      return null;
    }
    showInSnackBar('Video recorded to: $videoPath');
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';
    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      logError(e.code, e.description);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (controller.value.isRecordingVideo) {
      try {
        await controller.stopVideoRecording();
      } on CameraException catch (e) {
        logError(e.code, e.description);
      }
      final VideoPlayerController vcontroller =
          new VideoPlayerController.file(new File(videoPath));
      vcontroller.play();
      vcontroller.setLooping(true);
      videoPlayerListener = () {
        if (videoController != null && videoController.value.size != null) {
          videoController.removeListener(videoPlayerListener);
          // Refreshing the state to update video player with the correct ratio.
          if (mounted) setState(() {});
        }
      };
      vcontroller.addListener(videoPlayerListener);
      await vcontroller.initialize();
      if (!mounted) {
        return null;
      }
      setState(() {
        imagePath = null;
        videoController?.dispose();
        videoController = vcontroller;
      });
    }
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      logError(e.code, e.description);
      return null;
    }
    return filePath;
  }
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new CameraExampleHome(),
    );
  }
}

List<CameraDescription> cameras;

Future<Null> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(new CameraApp());
}
