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

// Function to get a suitable icon depending on the selected lens.
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> controlsChildren = <Widget>[];
    final List<Widget> cameraList = <Widget>[];

    if (cameras.isEmpty) {
      cameraList.add(const Text('No camera found'));
    } else {
      for (CameraDescription cameraDescription in cameras) {
        cameraList.add(
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

    // Add the cameras to the main controls widget.
    controlsChildren.add(new Row(children: cameraList));

    if (imagePath != null || videoController != null) {
      controlsChildren.add(previewWidget());
    }

    // Initialize the preview window
    final List<Widget> previewChildren = <Widget>[];

    // Depending on controller state display a message or the camera preview.
    if (controller == null || !controller.value.isInitialized) {
      previewChildren.add(new Text(
        'Tap a camera',
        style: new TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      ));
    } else if (controller.value.hasError) {
      previewChildren.add(
        new Text('Camera error ${controller.value.errorDescription}'),
      );
    } else {
      previewChildren.add(
        new Container(
          // Handle the preview depending on the aspect ratio of the camera view.
          child: new AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller),
          ),
          height: (MediaQuery.of(context).size.height - 230.0),
          color: Colors.black,
        ),
      );
    }

    // The main scaffolding of the app.
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Camera example'),
      ),
      body: new Column(children: <Widget>[
        new Container(
          child: new Padding(
            padding: const EdgeInsets.all(1.0),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Add the preview to the app.
                children: previewChildren,
              ),
            ),
          ),
          // Size of the container as wide as the device screen.
          width: MediaQuery.of(context).size.width,
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
        new Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // Add the controls to the app.
              children: controlsChildren),
        ),
      ]),

      // Bottom bar with the capture controls.
      bottomNavigationBar: (controller == null)
          ? null
          : new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.camera_alt),
                  color: Colors.blue,
                  onPressed: controller.value.isInitialized &&
                          !controller.value.isRecordingVideo
                      ? onTakePictureButtonPressed
                      : null,
                ),
                new IconButton(
                  icon: new Icon(Icons.videocam),
                  color: Colors.blue,
                  onPressed: controller.value.isInitialized &&
                          !controller.value.isRecordingVideo
                      ? onVideoRecordButtonPressed
                      : null,
                ),
                new IconButton(
                  icon: new Icon(Icons.stop),
                  color: Colors.red,
                  onPressed: controller.value.isInitialized &&
                          controller.value.isRecordingVideo
                      ? onStopButtonPressed
                      : null,
                )
              ],
            ),
    );
  }

  /// Display the thumbnail of the captured image.
  Widget previewWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: new SizedBox(
          child: (videoController == null)
              ? new Image.file(new File(imagePath))
              : new Container(
                  child: new VideoPlayer(videoController),
                  decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.pink)),
                ),
          width: 64.0,
          height: 64.0,
        ),
      ),
    );
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
        showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      showInSnackBar('Saving video to $filePath');
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
          new VideoPlayerController.network('file://$videoPath');
      vcontroller.play();
      vcontroller.setLooping(true);
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
  // Save the available cameras in this variable first before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(new CameraApp());
}
