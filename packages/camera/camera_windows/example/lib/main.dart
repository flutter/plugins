// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

// App for testing.
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraId = -1;
  bool _initialized = false;
  bool _recording = false;
  bool _recordingTimed = false;
  bool _recordAudio = true;
  bool _previewPaused = false;
  Size? _previewSize;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getAvailableCameras();
  }

  @override
  void dispose() {
    disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    super.dispose();
  }

  // Fetches list of available cameras from camera_windows plugin.
  Future<void> getAvailableCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraInfo = 'Found camera: ${cameras.first.name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _cameras = cameras;
      _cameraInfo = cameraInfo;
    });
  }

  /// Initializes the camera on the device.
  Future<void> initializeFirstCamera() async {
    assert(_cameras.isNotEmpty);
    assert(!_initialized);
    final Completer<CameraInitializedEvent> _initializeCompleter =
        Completer<CameraInitializedEvent>();
    int cameraId = -1;
    try {
      final CameraDescription camera = _cameras.first;

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: _recordAudio,
      );

      _errorStreamSubscription?.cancel();
      _errorStreamSubscription =
          CameraPlatform.instance.onCameraError(cameraId).listen(onCameraError);

      unawaited(CameraPlatform.instance
          .onCameraInitialized(cameraId)
          .first
          .then((CameraInitializedEvent event) {
        _initializeCompleter.complete(event);
      }));

      await CameraPlatform.instance.initializeCamera(
        cameraId,
        imageFormatGroup: ImageFormatGroup.unknown,
      );

      _previewSize = await _initializeCompleter.future.then(
        (CameraInitializedEvent event) => Size(
          event.previewWidth,
          event.previewHeight,
        ),
      );

      setState(() {
        _initialized = true;
        _cameraId = cameraId;
        _cameraInfo = 'Capturing camera: ${camera.name}';
      });
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }
      // Reset state.
      setState(() {
        _initialized = false;
        _cameraId = -1;
        _cameraInfo = 'Camera disposed';
        _previewSize = null;
        _recording = false;
        _recordingTimed = false;
        _cameraInfo =
            'Failed to initialize camera: ${e.code}: ${e.description}';
      });
    }
  }

  Future<void> disposeCurrentCamera() async {
    assert(_cameraId > 0);
    assert(_initialized);
    try {
      await CameraPlatform.instance.dispose(_cameraId);
      setState(() {
        _initialized = false;
        _cameraId = -1;
        _cameraInfo = 'Camera disposed';
        _previewSize = null;
        _recording = false;
        _recordingTimed = false;
      });
      getAvailableCameras();
    } on CameraException catch (e) {
      setState(() {
        _cameraInfo = 'Failed to dispose camera: ${e.code}: ${e.description}';
      });
    }
  }

  Widget buildPreview() {
    return CameraPlatform.instance.buildPreview(_cameraId);
  }

  Future<void> takePicture() async {
    final XFile _file = await CameraPlatform.instance.takePicture(_cameraId);
    showInSnackBar('Picture captured to: ${_file.path}');
  }

  Future<void> recordTimed(int seconds) async {
    if (_initialized && _cameraId > 0 && !_recordingTimed) {
      CameraPlatform.instance
          .onVideoRecordedEvent(_cameraId)
          .first
          .then((VideoRecordedEvent event) async {
        if (mounted) {
          setState(() {
            _recordingTimed = false;
          });

          showInSnackBar('Video captured to: ${event.file.path}');
        }
      });

      await CameraPlatform.instance.startVideoRecording(
        _cameraId,
        maxVideoDuration: Duration(seconds: seconds),
      );

      setState(() {
        _recordingTimed = true;
      });
    }
  }

  Future<void> toggleRecord() async {
    if (_initialized && _cameraId > 0) {
      if (!_recording) {
        await CameraPlatform.instance.startVideoRecording(_cameraId);
      } else {
        final XFile _file =
            await CameraPlatform.instance.stopVideoRecording(_cameraId);

        showInSnackBar('Video captured to: ${_file.path}');
      }
      setState(() {
        _recording = !_recording;
      });
    }
  }

  Future<void> togglePreview() async {
    if (_initialized && _cameraId > 0) {
      if (!_previewPaused) {
        await CameraPlatform.instance.pausePreview(_cameraId);
      } else {
        await CameraPlatform.instance.resumePreview(_cameraId);
      }
      setState(() {
        _previewPaused = !_previewPaused;
      });
    }
  }

  void onCameraError(CameraErrorEvent event) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text('Error: ${event.description}')));
  }

  void showInSnackBar(String message) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: Text(_cameraInfo),
            ),
            if (_cameras.isEmpty)
              ElevatedButton(
                onPressed: getAvailableCameras,
                child: const Text('Re-check available cameras'),
              ),
            if (_cameras.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Audio:',
                  ),
                  Switch(
                    value: _recordAudio,
                    onChanged: !_initialized
                        ? (bool state) => setState(() {
                              _recordAudio = state;
                            })
                        : null,
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _initialized
                        ? disposeCurrentCamera
                        : initializeFirstCamera,
                    child:
                        Text(_initialized ? 'Dispose camera' : 'Create camera'),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _initialized ? takePicture : null,
                    child: const Text('Take picture'),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _initialized ? togglePreview : null,
                    child: Text(
                      _previewPaused ? 'Resume preview' : 'Pause preview',
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: (_initialized && !_recordingTimed)
                        ? toggleRecord
                        : null,
                    child: Text(
                      _recording ? 'Stop recording' : 'Record Video',
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: (_initialized && !_recording && !_recordingTimed)
                        ? () => recordTimed(5)
                        : null,
                    child: const Text(
                      'Record 5 seconds',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 5),
            if (_initialized && _cameraId > 0 && _previewSize != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                    ),
                    child: AspectRatio(
                      aspectRatio: _previewSize!.width / _previewSize!.height,
                      child: buildPreview(),
                    ),
                  ),
                ),
              ),
            if (_previewSize != null)
              Center(
                child: Text(
                  'Preview size: ${_previewSize!.width.toStringAsFixed(0)}x${_previewSize!.height.toStringAsFixed(0)}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
