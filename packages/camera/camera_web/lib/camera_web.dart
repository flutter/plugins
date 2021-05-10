// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:html';
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'media_track_capabilities.dart';

class CameraInfo {
  /// Device id assigned by the plugin
  final int id;

  bool disposed = false;
  bool initialized = false;

  MediaDeviceInfo? deviceInfo;
  VideoElement? videoElement;
  MediaStream? stream;
  MediaRecorder? recorder;

  CameraInfo(this.id);
}

extension on Map<int, CameraInfo> {
  CameraInfo get(int id,
      {bool throwNotInitialized = true, bool throwDisposed = true}) {
    final e = this[id];
    if (e == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $id was found');
    }
    if (throwNotInitialized && !e.initialized) {
      throw CameraException(
          'Camera not initialized', 'Camera $id is not initialized');
    }
    if (throwDisposed && e.disposed) {
      throw CameraException('Camera disposed', 'Camera $id is disposed');
    }
    return e;
  }
}

///
class CameraPlugin extends CameraPlatform {
  int _nextId = 1;

  final _cameras = <int, CameraInfo>{};

  final _cameraEvents = StreamController<CameraEvent>.broadcast();

  final _canvas = CanvasElement();

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith(Registrar registrar) {
    CameraPlatform.instance = CameraPlugin();
  }

  static MediaTrackCapabilities? _getCapabilities(MediaStreamTrack track) {
    // In firefox 'getCapabilities' is not implemented.
    final p = js_util.getProperty(track, 'getCapabilities');
    if (p == null) {
      return null;
    }
    return MediaTrackCapabilities.fromObject(track.getCapabilities());
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    if (window.navigator.mediaDevices == null) {
      throw CameraException('The MediaDevices API is not supported!',
          'No MediaDevice found, either the browser doesn\'t support it, or you are in an un-safe context.');
    }
    final devices = (await window.navigator.mediaDevices!.enumerateDevices())
        .cast<MediaDeviceInfo>();

    return Future.wait<CameraDescription>(
        devices.where((e) => e.kind == 'videoinput').map((e) async {
      final userMedia = await window.navigator.mediaDevices!.getUserMedia({
        'video': {
          'deviceId': {'exact': e.deviceId}
        },
        'audio': false
      });

      final track = userMedia.getVideoTracks().first;

      //TODO: Use getSettings
      final settings = track.getSettings();
      var facingMode = settings['facingMode'];
      if (facingMode == null) {
        final capabilities = _getCapabilities(track)?.facingMode ?? const [];
        if (capabilities.isNotEmpty) {
          facingMode = capabilities.first;
        }
      }
      var direction = CameraLensDirection.external;
      if (facingMode != null) {
        if (facingMode == 'user') {
          direction = CameraLensDirection.front;
        } else if (facingMode == 'environment') {
          direction = CameraLensDirection.back;
        }
      }

      return CameraDescription(
          name: e.label ?? '', lensDirection: direction, sensorOrientation: 0);
    }).toList());
  }

  @override
  Widget buildPreview(int cameraId) {
    _cameras.get(cameraId);

    return HtmlElementView(viewType: 'video-view-$cameraId');
  }

  @override
  Future<int> createCamera(
      CameraDescription cameraDescription, ResolutionPreset? resolutionPreset,
      {bool enableAudio = false}) async {
    // TODO: implement enableAudio and resolutionPreset.

    if (window.navigator.mediaDevices == null) {
      throw CameraException('The MediaDevices API is not supported!',
          'No MediaDevice found, either the browser doesn\'t support it, or you are in an un-safe context.');
    }

    final devices = (await window.navigator.mediaDevices!.enumerateDevices())
        .cast<MediaDeviceInfo>();

    final l = devices.where(
        (e) => e.kind == 'videoinput' && e.label == cameraDescription.name);
    if (l.isEmpty) {
      throw CameraException('Camera not found',
          'Couldn\'t find a camera labeled: ${cameraDescription.name}');
    }

    final device = CameraInfo(_nextId++);
    device.deviceInfo = l.first;

    _cameras[device.id] = device;

    return device.id;
  }

  @override
  Future<void> dispose(int cameraId) async {
    _cameras[cameraId]?.videoElement?.remove();
    _cameras[cameraId]?.disposed = true;

    //TODO: Not sure if this is needed
    _cameras[cameraId]?.stream?.getVideoTracks().first.stop();
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    //TODO: Throw if not initialized or disposed
    final stream = _cameras.get(cameraId).stream!;

    final track = stream.getVideoTracks().first;
    final capabilities = _getCapabilities(track);

    //TODO: Not sure if exposureTime is the right property to implement this.
    return capabilities?.exposureTime?.step.toDouble() ?? 0;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    final stream = _cameras.get(cameraId).stream!;

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities = _getCapabilities(track);

    //TODO: Not sure if exposureTime is the right property to implement this.
    return capabilities?.exposureTime?.max.toDouble() ?? 0;
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    final stream = _cameras.get(cameraId).stream!;

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities = _getCapabilities(track);
    return capabilities?.zoom?.max.toDouble() ?? 0;
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    final stream = _cameras.get(cameraId).stream!;

    if (stream == null) {
      throw CameraException(
          'CameraId not found.', 'No camera with $cameraId was found');
    }

    final track = stream.getVideoTracks().first;
    final capabilities = _getCapabilities(track);
    return capabilities?.exposureTime?.min.toDouble() ?? 0;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    final stream = _cameras.get(cameraId).stream!;

    final track = stream.getVideoTracks().first;
    final capabilities = _getCapabilities(track);
    return capabilities?.zoom?.min.toDouble() ?? 0;
  }

  @override
  Future<void> initializeCamera(int cameraId,
      {ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown}) async {
    if (window.navigator.mediaDevices == null) {
      throw CameraException('The MediaDevices API is not supported!',
          'No MediaDevice found, either the browser doesn\'t support it, or you are in an un-safe context.');
    }

    final camera = _cameras.get(cameraId, throwNotInitialized: false);
    if (camera.initialized) {
      return;
    }

    late MediaStream userMedia;
    try {
      userMedia = await window.navigator.mediaDevices!.getUserMedia({
        'video': {
          'deviceId': {'exact': camera.deviceInfo!.deviceId}
        },
        'audio': false
      });
    } on OverconstrainedError catch (e) {
      throw CameraException(e.name ?? 'OverconstrainedError',
          'Invalid constraint: ${e.constraint}');
    }

    final video = VideoElement();

    // See https://github.com/flutter/flutter/issues/41563
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory('video-view-$cameraId', (int viewId) => video);
    //TODO: Does the view factory need to be disposed?

    camera.videoElement = video;
    video.srcObject = userMedia;

    try {
      await video.play();
    } catch (e) {
      // This happens only in chrome and when the code is run from the build files (flutter build).
      // Tough this can be ignored without any further issues.
      if (!e.toString().toLowerCase().contains(
          'the play() request was interrupted by a call to pause()')) {
        rethrow;
      }
    }

    camera.stream = userMedia;

    final track = userMedia.getVideoTracks().first;
    final capabilities = _getCapabilities(track);

    camera.initialized = true;

    _cameraEvents.add(CameraInitializedEvent(
        cameraId,
        capabilities?.width?.max.toDouble() ?? video.videoWidth.toDouble(),
        capabilities?.height?.max.toDouble() ?? video.videoHeight.toDouble(),
        //TODO: Maybe use settings/capabilities.exposureMode
        ExposureMode.auto,
        false,
        //TODO: Maybe use settings/capabilities.focusMode
        FocusMode.auto,
        false));
  }

  @override
  Future<void> lockCaptureOrientation(
      int cameraId, DeviceOrientation deviceOrientation) async {
    if (window.screen == null || window.screen!.orientation == null) {
      throw CameraException('Screen API not available in this browser.', '');
    }

    late final String orientation;
    switch (deviceOrientation) {
      case DeviceOrientation.portraitUp:
        orientation = 'portrait-primary';
        break;
      case DeviceOrientation.landscapeLeft:
        orientation = 'landscape-primary';
        break;
      case DeviceOrientation.portraitDown:
        orientation = 'portrait-secondary';
        break;
      case DeviceOrientation.landscapeRight:
        orientation = 'landscape-secondary';
        break;
    }
    await window.screen!.orientation!.lock(orientation);
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
    //TODO: Throw if camera id is disposed or not initialized (?)

    return _cameraEvents.stream
        .where((e) => e is CameraInitializedEvent && e.cameraId == cameraId)
        .cast<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(
      int cameraId) async* {
    // TODO: This is not really implemented
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() async* {
    // TODO: This is not really implemented
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    //TODO: Throw if camera id is disposed, not initialized or not recording(?)

    return _cameraEvents.stream
        .where((e) => e is VideoRecordedEvent && e.cameraId == cameraId)
        .cast<VideoRecordedEvent>();
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    final recorder = _cameras.get(cameraId).recorder;
    if (recorder == null) {
      throw CameraException('Recording not started', '');
    }
    recorder.pause();
  }

  /// Not needed in web
  @override
  Future<void> prepareForVideoRecording() async {}

  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    final recorder = _cameras.get(cameraId).recorder;
    if (recorder == null) {
      throw CameraException('Recording not started', '');
    }
    recorder.resume();
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
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    final stream = _cameras.get(cameraId).stream!;

    final track = stream.getVideoTracks().first;
    await track.applyConstraints({
      'advanced': [
        {'torch': mode == FlashMode.off ? false : true}
      ]
    });
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) {
    // TODO: implement setFocusMode
    throw UnimplementedError();
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    final stream = _cameras.get(cameraId).stream!;

    final track = stream.getVideoTracks().first;
    await track.applyConstraints({
      'advanced': [
        {'zoom': zoom}
      ]
    });
  }

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    final camera = _cameras.get(cameraId);
    if (camera.recorder != null) {
      throw CameraException('Recording already started.', '');
    }

    final recorder = MediaRecorder(camera.stream!, {
      'mimeType': 'video/webm;codecs=vp8',
    });
    recorder.start();

    recorder.addEventListener('dataavailable', (event) async {
      final blobEvent = event as BlobEvent;
      final fileReader = FileReader();
      fileReader.readAsArrayBuffer(blobEvent.data!);

      await fileReader.onLoad.first;
      _cameraEvents.add(VideoRecordedEvent(
          cameraId,
          XFile.fromData(fileReader.result as Uint8List,
              mimeType: 'video/webm;codecs=vp8'),
          Duration.zero));
    });

    camera.recorder = recorder;
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final recorder = _cameras.get(cameraId).recorder;
    if (recorder == null) {
      throw CameraException('Camera not initialized', '');
    }
    recorder.stop();

    final event = await onVideoRecordedEvent(cameraId).first;
    return event.file;
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final video = _cameras.get(cameraId).videoElement;

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
    return XFile.fromData(uri.data!.contentAsBytes(), mimeType: 'image/png');
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    if (window.screen == null || window.screen!.orientation == null) {
      throw CameraException('Screen API not available in this browser.', '');
    }

    window.screen!.orientation!.unlock();
  }
}
