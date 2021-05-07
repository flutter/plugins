import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:tuple/tuple.dart';

import 'media_track_capabilities.dart';

///
class CameraPlugin extends CameraPlatform {
  int _nextId = 1;

  // Maybe use a tuple for these values as well.
  final _devices = <int, MediaDeviceInfo>{};
  final _previewEl = <int, VideoElement>{};
  final _mediaStreams = <int, MediaStream>{};

  final _camInitializer =
      StreamController<Tuple2<int, MediaStream>>.broadcast();

  final _canvas = CanvasElement();

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith(Registrar registrar) {
    CameraPlatform.instance = CameraPlugin();
  }

  // This is needed before every call to ensure to have the devices description.
  Future<void> _requestPermission() async {
    try {
      await window.navigator.mediaDevices!.getUserMedia({'video': true});
    } on DomException catch (e) {
      throw CameraException(e.name, e.message);
    }
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    await _requestPermission();

    final devices = (await window.navigator.mediaDevices!.enumerateDevices())
        .cast<MediaDeviceInfo>();

    //TODO: Call 'getCapabilities' to get lensDirection.
    return devices
        .where((e) => e.kind == 'videoinput')
        .map((e) => CameraDescription(
            name: e.label ?? '',
            lensDirection: CameraLensDirection.external,
            sensorOrientation: 0))
        .toList();
  }

  @override
  Widget buildPreview(int cameraId) {
    //TODO: Throw if not initialized.

    return HtmlElementView(viewType: 'video-view-$cameraId');
  }

  @override
  Future<int> createCamera(
      CameraDescription cameraDescription, ResolutionPreset? resolutionPreset,
      {bool enableAudio = false}) async {
    // TODO: implement enableAudio and resolutionPreset.
    await _requestPermission();

    final devices = (await window.navigator.mediaDevices!.enumerateDevices())
        .cast<MediaDeviceInfo>();

    final l = devices.where(
        (e) => e.kind == 'videoinput' && e.label == cameraDescription.name);
    if (l.isEmpty) {
      throw CameraException('Camera not found',
          'Couldn\'t find a camera labeled: ${cameraDescription.name}');
    }

    final device = l.first;
    final id = _nextId++;
    _devices[id] = device;

    return id;
  }

  @override
  Future<void> dispose(int cameraId) async {
    _devices.remove(cameraId);
    _mediaStreams.remove(cameraId);
    _previewEl.remove(cameraId)?.remove();
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    //TODO: Throw if not initialized
    final stream = _mediaStreams[cameraId];

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities =
    MediaTrackCapabilities.fromObject(track.getCapabilities());

    //TODO: Not sure if exposureTime is the right property to implement this.
    return capabilities?.exposureTime?.step.toDouble() ?? 0;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    //TODO: Throw if not initialized
    final stream = _mediaStreams[cameraId];

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities =
    MediaTrackCapabilities.fromObject(track.getCapabilities());

    //TODO: Not sure if exposureTime is the right property to implement this.
    return capabilities?.exposureTime?.max.toDouble() ?? 0;
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    //TODO: Throw if not initialized

    final stream = _mediaStreams[cameraId];

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities =
        MediaTrackCapabilities.fromObject(track.getCapabilities());
    return capabilities?.zoom?.max.toDouble() ?? 0;
  }


  @override
  Future<double> getMinExposureOffset(int cameraId) async{
    //TODO: Throw if not initialized
    final stream = _mediaStreams[cameraId];

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities =
    MediaTrackCapabilities.fromObject(track.getCapabilities());

    //TODO: Not sure if exposureTime is the right property to implement this.
    return capabilities?.exposureTime?.min.toDouble() ?? 0;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    //TODO: Throw if not initialized
    final stream = _mediaStreams[cameraId];

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities =
        MediaTrackCapabilities.fromObject(track.getCapabilities());
    return capabilities?.zoom?.min.toDouble() ?? 0;
  }

  @override
  Future<void> initializeCamera(int cameraId,
      {ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown}) async {
    final device = _devices[cameraId];
    if (device == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    if (_previewEl[cameraId] != null) {
      return;
    }

    late MediaStream userMedia;
    try {
      userMedia = await window.navigator.mediaDevices!.getUserMedia({
        'video': {
          'deviceId': {'exact': device.deviceId}
        },
        'audio': false
      });
    } on OverconstrainedError catch (e) {
      throw CameraException(e.name ?? 'OverconstrainedError',
          'Invalid constraint: ${e.constraint}');
    }

    final video = VideoElement();
    ui.platformViewRegistry
        .registerViewFactory('video-view-$cameraId', (int viewId) => video);

    _previewEl[cameraId] = video;

    video.srcObject = userMedia;
    await video.play();

    _mediaStreams[cameraId] = userMedia;
    _camInitializer.add(Tuple2(cameraId, userMedia));
  }

  @override
  Future<void> lockCaptureOrientation(
      int cameraId, DeviceOrientation orientation) {
    // TODO: implement lockCaptureOrientation
    throw UnimplementedError();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    // TODO: implement onCameraClosing
    throw UnimplementedError();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    // TODO: implement onCameraError
    throw UnimplementedError();
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    final device = _devices[cameraId];
    if (device == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    return _camInitializer.stream.where((e) => e.item1 == cameraId).map((e) {
      final userMedia = e.item2;

      final videoTrack = userMedia.getVideoTracks().first;
      final capabilities =
          MediaTrackCapabilities.fromObject(videoTrack.getCapabilities());
      return CameraInitializedEvent(
          cameraId,
          //TODO: Not sure if using width and height .max is correct here.
          capabilities?.width?.max.toDouble() ?? 1,
          capabilities?.height?.max.toDouble() ?? 1,
          //TODO: Maybe use capabilities.exposureMode
          ExposureMode.auto,
          false,
          //TODO: Maybe use capabilities.focusMode
          FocusMode.auto,
          false);
    });
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) async* {
    // TODO: This is not really implemented
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() async* {
    // TODO: This is not really implemented
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    // TODO: implement onVideoRecordedEvent
    throw UnimplementedError();
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) {
    // TODO: implement pauseVideoRecording
    throw UnimplementedError();
  }

  @override
  Future<void> prepareForVideoRecording() {
    // TODO: implement prepareForVideoRecording
    throw UnimplementedError();
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) {
    // TODO: implement resumeVideoRecording
    throw UnimplementedError();
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) {
    // TODO: implement setExposureMode
    throw UnimplementedError();
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) {
    // TODO: implement setExposureOffset
    throw UnimplementedError();
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    // TODO: implement setExposurePoint
    throw UnimplementedError();
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) {
    // TODO: implement setFlashMode
    throw UnimplementedError();
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) {
    // TODO: implement setFocusMode
    throw UnimplementedError();
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    // TODO: implement setFocusPoint
    throw UnimplementedError();
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    final stream = _mediaStreams[cameraId];
    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    await track.applyConstraints({
      'advanced': [
        {'zoom': zoom}
      ]
    });
  }

  @override
  Future<void> startVideoRecording(int cameraId, {Duration? maxVideoDuration}) {
    // TODO: implement startVideoRecording
    throw UnimplementedError();
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) {
    // TODO: implement stopVideoRecording
    throw UnimplementedError();
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    //TODO: Throw if not initialized

    final video = _previewEl[cameraId];

    if (video == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    _canvas.width = video.videoWidth;
    _canvas.height = video.videoHeight;
    final context = _canvas.context2D;
    context.drawImage(video, 0, 0);

    final data = _canvas.toDataUrl('image/png');
    final uri = Uri.parse(data);
    return XFile('picture.png', bytes: uri.data!.contentAsBytes());
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) {
    // TODO: implement unlockCaptureOrientation
    throw UnimplementedError();
  }
}
