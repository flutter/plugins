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

/// Example app for Camera Windows plugin.
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
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
    _getAvailableCameras();
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    super.dispose();
  }

  /// Fetches list of available cameras from camera_windows plugin.
  Future<void> _getAvailableCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = _cameraIndex;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      cameraIndex = cameraIndex % cameras.length;
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _cameraIndex = cameraIndex;
      _cameras = cameras;
      _cameraInfo = cameraInfo;
    });
  }

  /// Initializes the camera on the device.
  Future<void> _initializeCamera() async {
    assert(_cameras.isNotEmpty);
    assert(!_initialized);
    final Completer<CameraInitializedEvent> _initializeCompleter =
        Completer<CameraInitializedEvent>();
    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: _recordAudio,
      );

      _errorStreamSubscription?.cancel();
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

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
        _cameraIndex = cameraIndex;
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

      /// Reset state.
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

  Future<void> _disposeCurrentCamera() async {
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
        _previewPaused = false;
      });
      await _getAvailableCameras();
    } on CameraException catch (e) {
      setState(() {
        _cameraInfo = 'Failed to dispose camera: ${e.code}: ${e.description}';
      });
    }
  }

  Widget _buildPreview() {
    return CameraPlatform.instance.buildPreview(_cameraId);
  }

  Future<void> _takePicture() async {
    final XFile _file = await CameraPlatform.instance.takePicture(_cameraId);
    _showInSnackBar('Picture captured to: ${_file.path}');
  }

  Future<void> _recordTimed(int seconds) async {
    if (_initialized && _cameraId > 0 && !_recordingTimed) {
      CameraPlatform.instance
          .onVideoRecordedEvent(_cameraId)
          .first
          .then((VideoRecordedEvent event) async {
        if (mounted) {
          setState(() {
            _recordingTimed = false;
          });

          _showInSnackBar('Video captured to: ${event.file.path}');
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

  Future<void> _toggleRecord() async {
    if (_initialized && _cameraId > 0) {
      if (_recordingTimed) {
        /// Request to stop timed recording short.
        await CameraPlatform.instance.stopVideoRecording(_cameraId);
      } else {
        if (!_recording) {
          await CameraPlatform.instance.startVideoRecording(_cameraId);
        } else {
          final XFile _file =
              await CameraPlatform.instance.stopVideoRecording(_cameraId);

          _showInSnackBar('Video captured to: ${_file.path}');
        }
        setState(() {
          _recording = !_recording;
        });
      }
    }
  }

  Future<void> _togglePreview() async {
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

  Future<void> _switchCamera() async {
    if (_cameraId > -1) {
      await _disposeCurrentCamera();
    }
    if (_cameras.isNotEmpty) {
      setState(() {
        _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      });
      await _initializeCamera();
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    _scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text('Error: ${event.description}')));
  }

  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
                onPressed: _getAvailableCameras,
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
                        ? _disposeCurrentCamera
                        : _initializeCamera,
                    child:
                        Text(_initialized ? 'Dispose camera' : 'Create camera'),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _initialized ? _takePicture : null,
                    child: const Text('Take picture'),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _initialized ? _togglePreview : null,
                    child: Text(
                      _previewPaused ? 'Resume preview' : 'Pause preview',
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _initialized ? _toggleRecord : null,
                    child: Text(
                      (_recording || _recordingTimed)
                          ? 'Stop recording'
                          : 'Record Video',
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: (_initialized && !_recording && !_recordingTimed)
                        ? () => _recordTimed(5)
                        : null,
                    child: const Text(
                      'Record 5 seconds',
                    ),
                  ),
                  if (_cameras.length > 1) ...<Widget>[
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: _switchCamera,
                      child: const Text(
                        'Switch camera',
                      ),
                    ),
                  ]
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
                      child: _buildPreview(),
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
