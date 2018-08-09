import 'dart:async';

import 'package:camera/camera.dart' as camera;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_ml_vision_example/detector_painters.dart';
import 'package:flutter/material.dart';

class LivePreview extends StatefulWidget {
  final FirebaseVisionDetectorType detector;

  const LivePreview(
    this.detector, {
    Key key,
  }) : super(key: key);

  @override
  LivePreviewState createState() {
    return new LivePreviewState();
  }
}

class LivePreviewState extends State<LivePreview> {
  LiveViewCameraLoadStateReady _readyLoadState;

  Stream<LiveViewCameraLoadState> _prepareCameraPreview() async* {
    if (_readyLoadState != null) {
      await setLiveViewDetector();
      yield _readyLoadState;
    } else {
      yield new LiveViewCameraLoadStateLoading();
      final List<camera.CameraDescription> cameras =
          await camera.availableCameras();
      final camera.CameraDescription backCamera = cameras.firstWhere(
          (camera.CameraDescription cameraDescription) =>
              cameraDescription.lensDirection ==
              camera.CameraLensDirection.back);
      if (backCamera != null) {
        yield new LiveViewCameraLoadStateLoaded(backCamera);
        try {
          final camera.CameraController controller =
              new camera.CameraController(
                  backCamera, camera.ResolutionPreset.high);
          await controller.initialize();
          await setLiveViewDetector();
          yield new LiveViewCameraLoadStateReady(controller);
        } on LiveViewCameraException catch (e) {
          yield new LiveViewCameraLoadStateFailed(
              "error initializing camera controller: ${e.toString()}");
        }
      } else {
        yield new LiveViewCameraLoadStateFailed("Could not find device camera");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setLiveViewDetector();
  }

  Future<Null> setLiveViewDetector() async {
    VisionOptions options;
    if (widget.detector == FirebaseVisionDetectorType.barcode) {
      options = const BarcodeDetectorOptions();
    } else if (widget.detector == FirebaseVisionDetectorType.label) {
      options = const LabelDetectorOptions();
    } else if (widget.detector == FirebaseVisionDetectorType.face) {
      options = const FaceDetectorOptions();
    }
    FirebaseVision.instance.setLiveViewDetector(widget.detector, options);
  }

  @override
  void dispose() {
    super.dispose();
    _readyLoadState?.controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<LiveViewCameraLoadState>(
      stream: _prepareCameraPreview(),
      initialData: new LiveViewCameraLoadStateLoading(),
      builder: (BuildContext context,
          AsyncSnapshot<LiveViewCameraLoadState> snapshot) {
        final LiveViewCameraLoadState loadState = snapshot.data;
        if (loadState != null) {
          if (loadState is LiveViewCameraLoadStateLoading ||
              loadState is LiveViewCameraLoadStateLoaded) {
            return const Text("loading camera preview…");
          }
          if (loadState is LiveViewCameraLoadStateReady) {
            if (_readyLoadState != loadState) {
              _readyLoadState?.dispose();
              _readyLoadState = loadState;
            }
            return new AspectRatio(
              aspectRatio: _readyLoadState.controller.value.aspectRatio,
              child: Stack(children: <Widget>[
                new camera.CameraPreview(loadState.controller),
                Container(
                  constraints: const BoxConstraints.expand(),
                  child: StreamBuilder<LiveViewDetectionResult>(
                    builder: (BuildContext context,
                        AsyncSnapshot<LiveViewDetectionResult> snapshot) {
                      print("update: ${snapshot}");
                      if (snapshot == null || snapshot.data == null) {
                        return Text("No DATA!!!");
                      }
                      print("size: ${snapshot.data.size}");
                      print("data: ${snapshot.data.data}");
                      return customPaintForResults(snapshot.data);
                    },
                    stream: FirebaseVision.instance.liveViewStream,
                  ),
                )
              ]),
            );
          } else if (loadState is LiveViewCameraLoadStateFailed) {
            return new Text("error loading camera ${loadState.errorMessage}");
          } else {
            return const Text("Unknown Camera error");
          }
        } else {
          return new Text("Camera error: ${snapshot.error.toString()}");
        }
      },
    );
  }
}

abstract class LiveViewCameraLoadState {}

class LiveViewCameraLoadStateLoading extends LiveViewCameraLoadState {}

class LiveViewCameraLoadStateLoaded extends LiveViewCameraLoadState {
  final camera.CameraDescription cameraDescription;

  LiveViewCameraLoadStateLoaded(this.cameraDescription);
}

class LiveViewCameraLoadStateReady extends LiveViewCameraLoadState {
  final camera.CameraController controller;

  LiveViewCameraLoadStateReady(this.controller);

  void dispose() {
    controller.dispose();
  }
}

class LiveViewCameraLoadStateFailed extends LiveViewCameraLoadState {
  final String errorMessage;

  LiveViewCameraLoadStateFailed(this.errorMessage);
}
