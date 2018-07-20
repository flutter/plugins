import 'dart:async';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_ml_vision/live_view.dart';
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
  bool _isShowingPreview = false;
  LiveViewCameraLoadStateReady _readyLoadState;
  GlobalKey<LiveViewState> _liveViewKey = new GlobalKey();

  Stream<LiveViewCameraLoadState> _prepareCameraPreview() async* {
    if (_readyLoadState != null) {
      await setLiveViewDetector();
      yield _readyLoadState;
    } else {
      yield new LiveViewCameraLoadStateLoading();
      final List<LiveViewCameraDescription> cameras = await availableCameras();
      final LiveViewCameraDescription backCamera = cameras.firstWhere(
          (LiveViewCameraDescription cameraDescription) =>
              cameraDescription.lensDirection ==
              LiveViewCameraLensDirection.back);
      if (backCamera != null) {
        yield new LiveViewCameraLoadStateLoaded(backCamera);
        try {
          final LiveViewCameraController controller =
              new LiveViewCameraController(
                  backCamera, LiveViewResolutionPreset.high);
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
    return _readyLoadState?.controller?.setDetector(widget.detector);
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
              child: new LiveView(
                controller: _readyLoadState.controller,
                overlayBuilder: (BuildContext context, Size previewSize,
                    LiveViewDetectionList data) {
                  return data == null
                      ? new Container()
                      : customPaintForResults(previewSize, data);
                },
              ),
            );
          } else if (loadState is LiveViewCameraLoadStateFailed) {
            return new Text("error loading camera ${loadState
                .errorMessage}");
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
  final LiveViewCameraDescription cameraDescription;

  LiveViewCameraLoadStateLoaded(this.cameraDescription);
}

class LiveViewCameraLoadStateReady extends LiveViewCameraLoadState {
  final LiveViewCameraController controller;

  LiveViewCameraLoadStateReady(this.controller);

  void dispose() {
    controller.dispose();
  }
}

class LiveViewCameraLoadStateFailed extends LiveViewCameraLoadState {
  final String errorMessage;

  LiveViewCameraLoadStateFailed(this.errorMessage);
}
