// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/* OLD
import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'type_conversion.dart';
import 'utils.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/camera_android');

*/

/// The CameraX Android implementation of [CameraPlatform].
class AndroidCameraCameraX extends CameraPlatform {
  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

/* OLD -- some still needed I'm sure, but ignoring for now.
  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

  /// The name of the channel that device events from the platform side are
  /// sent on.
  @visibleForTesting
  static const String deviceEventChannelName =
      'plugins.flutter.io/camera_android/fromPlatform';


  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to camera events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to general device events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  late final StreamController<DeviceEvent> _deviceEventStreamController =
      _createDeviceEventStreamController();

  StreamController<DeviceEvent> _createDeviceEventStreamController() {
    // Set up the method handler lazily.
    const MethodChannel channel = MethodChannel(deviceEventChannelName);
    channel.setMethodCallHandler(_handleDeviceMethodCall);
    return StreamController<DeviceEvent>.broadcast();
  }

  // The stream to receive frames from the native code.
  StreamSubscription<dynamic>? _platformImageStreamSubscription;

  // The stream for vending frames to platform interface clients.
  StreamController<CameraImageData>? _frameStreamController;

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);
*/

  /* FUNDAMENTAL OBJECTS FOR CAMERA CONSTRUCTION */
  Activity activity;
  Camera? camera;
  ProcessCameraProvider? processCameraProvider;
  Executor executor;

  /* USE CASES */
  UseCase.Preview? preview;
  UseCase.ImageAnalysis? imageAnalysis;
  UseCase.ImageCapture? imageCapture;

  /* CONFIGURATION OPTIONS */
  DeviceOrientation targetOrientation;
  Flashmode? targetFlashMode;

  //////////////////////////////////////////////////////////////////////////////
  /// Camera Lifecycle methods
  //////////////////////////////////////////////////////////////////////////////

  /// LIMITATIONS: Getting camera name, getting external cameras
  @override
  Future<List<CameraDescription>> availableCameras() {
    if (processCameraProvider == null) {
      processCameraProvider = ProcessCameraProvider(); //createProcessCameraProviderInstance(); // theoretical instantiation
    }

    List<CameraInfos> cameraInfos = processCameraProvider.getAvailableCameraInfos(); // calls identical method in CameraX
  
    return cameraInfos.map((CameraInfo info) {
      CameraSelector selector = info.getCameraSelector(); // calls identical method in CameraX
      return CameraDescription(
        name: ???, //TODO: get name???,
        lensDirection:
             selector == CameraSelector.DEFAULT_BACK_CAMERA
                ? CameraLensDirection.back
                : CameraLensDirection.front;
        sensorOrientation: info.getSensorRotationDegrees(), // calls identical method in CameraX
      );
    }).toList();
  }

  // Do these need to return Futures anymore?
  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) {
    // 1: Close any existing cameras
    if (camera != null && processCameraProvide != null) {
      processCameraProvider.unbindAll() // calls identical method in CameraX, probably can call dispose
    }
    // 2: Request permissions
    CameraPermissions cameraPermissions = new CameraPermissions();
    cameraPermissions(activity, permissionsRegistry, enableAudio, (String errCode, String errDesc) {
      // 3: instantiate camera
      if (errCode == null) {
        try {
          CameraFilter cameraFilter = createCameraFilterBasedOnParameters(); // theoretical helper method
          CameraSelector.Builder cameraSelectorBuilder = // calls identical constructor in CameraX
            new CameraSelector.Builder()
              .addCamereaFilter(cameraFilter);
              .requireLensFacing(cameraDescription.lensDirection);
          Camera camera = processCameraProvider.bindToLifecycle(preview, activity, cameraSelectorBuilder, ); // theoretical instantiation that will instantiate a camera with theoretical Preview use case
          return camera.id; // not sure where id is coming from, so theoretical parameter -- could be InstanceManager ID?
        } catch (Exception e) {
          throwException(e); // ???
        }
      } else {
        throwException(e); // ???
      }
    });
  }

  // LIMITATION: Slight behavior mismatch
  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) {
    // 1: check if they can open camera
      // Wouldn't we handle this when we create the camera? Makes more sense there since that is where we would get the error
    // 2: set up image streaming
    ImageReader pictureImageReader = ImageReader(ImageFormatGroup.jpeg); // theoretical instantiation -- probably more details here if this is needed at all
    ImageReader imageStreamReader = ImageReader(imageFormatGroup);
    imageAnalysis.setAnalyzer(executor, ImageAnalysis.Analyzer() {
      @override
      void analyze(ImageProxy imageProxy) {
        // TLDR streaming stuff
        return imageProxy.getSomeInfoAboutTheImage();
      }
    });
    // 3: open camera
      // NOT APPLICABLE
  }


  // Do we need cameraId?
  @override
  Future<void> dispose(int cameraId) async {
    processCameraProvider!.unbindAll(); // calls identical method in CameraX
    camera = null;
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Camera Event Callbacks, not sure what is happening with these right now
  //////////////////////////////////////////////////////////////////////////////

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraResolutionChangedEvent>();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraClosingEvent>();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraErrorEvent>();
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return _cameraEvents(cameraId).whereType<VideoRecordedEvent>();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return _deviceEventStreamController.stream
        .whereType<DeviceOrientationChangedEvent>();
  }


  //////////////////////////////////////////////////////////////////////////////
  /// Changing Orientation Methods
  //////////////////////////////////////////////////////////////////////////////

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    targetOrientation = orientation; // targetOrientation can be used throughout to set the orientation as locked
    // Note that this will become more complicaed assuming that transforms are needed to correct the outpate on the SurfaceTexture
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    targetOrientation = null;
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Taking Pictures, Recording Video Methods
  //////////////////////////////////////////////////////////////////////////////

  // Need cameraId?
  @override
  Future<XFile> takePicture(int cameraId) async {
        imageCapture.takePicture(outputFileOptions, cameraExecutor,
        new ImageCapture.OnImageSavedCallback() {
            @override
            void onImageSaved(ImageCapture.OutputFileResults outputFileResults) {
               return XFile(outputFileResults);
            }
            @override
            void onError(ImageCaptureException error) {
                throwException(error); // ???
            }
       }
    );
  }

  @override
  Future<void> prepareForVideoRecording() =>
      _channel.invokeMethod<void>('prepareForVideoRecording');

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    await _channel.invokeMethod<void>(
      'startVideoRecording',
      <String, dynamic>{
        'cameraId': cameraId,
        'maxVideoDuration': maxVideoDuration?.inMilliseconds,
      },
    );
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final String? path = await _channel.invokeMethod<String>(
      'stopVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );

    if (path == null) {
      throw CameraException(
        'INVALID_PATH',
        'The platform "$defaultTargetPlatform" did not return a path while reporting success. The platform should always return a valid path or report an error.',
      );
    }

    return XFile(path);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) => _channel.invokeMethod<void>(
        'pauseVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Future<void> resumeVideoRecording(int cameraId) =>
      _channel.invokeMethod<void>(
        'resumeVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(int cameraId,
      {CameraImageStreamOptions? options}) {
    _frameStreamController = StreamController<CameraImageData>(
      onListen: _onFrameStreamListen,
      onPause: _onFrameStreamPauseResume,
      onResume: _onFrameStreamPauseResume,
      onCancel: _onFrameStreamCancel,
    );
    return _frameStreamController!.stream;
  }

  void _onFrameStreamListen() {
    _startPlatformStream();
  }

  Future<void> _startPlatformStream() async {
    await _channel.invokeMethod<void>('startImageStream');
    const EventChannel cameraEventChannel =
        EventChannel('plugins.flutter.io/camera_android/imageStream');
    _platformImageStreamSubscription =
        cameraEventChannel.receiveBroadcastStream().listen((dynamic imageData) {
      _frameStreamController!
          .add(cameraImageFromPlatformData(imageData as Map<dynamic, dynamic>));
    });
  }

  FutureOr<void> _onFrameStreamCancel() async {
    await _channel.invokeMethod<void>('stopImageStream');
    await _platformImageStreamSubscription?.cancel();
    _platformImageStreamSubscription = null;
    _frameStreamController = null;
  }

  void _onFrameStreamPauseResume() {
    throw CameraException('InvalidCall',
        'Pause and resume are not supported for onStreamedFrameAvailable');
  }

  // Example of configuration
  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) {
    targetFlashMode = mode; // This will be used whenever the relevant applicable use case is performed
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) =>
      _channel.invokeMethod<void>(
        'setExposureMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': serializeExposureMode(mode),
        },
      );

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _channel.invokeMethod<void>(
      'setExposurePoint',
      <String, dynamic>{
        'cameraId': cameraId,
        'reset': point == null,
        'x': point?.x,
        'y': point?.y,
      },
    );
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    final double? minExposureOffset = await _channel.invokeMethod<double>(
      'getMinExposureOffset',
      <String, dynamic>{'cameraId': cameraId},
    );

    return minExposureOffset!;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    final double? maxExposureOffset = await _channel.invokeMethod<double>(
      'getMaxExposureOffset',
      <String, dynamic>{'cameraId': cameraId},
    );

    return maxExposureOffset!;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    final double? stepSize = await _channel.invokeMethod<double>(
      'getExposureOffsetStepSize',
      <String, dynamic>{'cameraId': cameraId},
    );

    return stepSize!;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    final double? appliedOffset = await _channel.invokeMethod<double>(
      'setExposureOffset',
      <String, dynamic>{
        'cameraId': cameraId,
        'offset': offset,
      },
    );

    return appliedOffset!;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) =>
      _channel.invokeMethod<void>(
        'setFocusMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': serializeFocusMode(mode),
        },
      );

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _channel.invokeMethod<void>(
      'setFocusPoint',
      <String, dynamic>{
        'cameraId': cameraId,
        'reset': point == null,
        'x': point?.x,
        'y': point?.y,
      },
    );
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    final double? maxZoomLevel = await _channel.invokeMethod<double>(
      'getMaxZoomLevel',
      <String, dynamic>{'cameraId': cameraId},
    );

    return maxZoomLevel!;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    final double? minZoomLevel = await _channel.invokeMethod<double>(
      'getMinZoomLevel',
      <String, dynamic>{'cameraId': cameraId},
    );

    return minZoomLevel!;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    try {
      await _channel.invokeMethod<double>(
        'setZoomLevel',
        <String, dynamic>{
          'cameraId': cameraId,
          'zoom': zoom,
        },
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    await _channel.invokeMethod<double>(
      'pausePreview',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    await _channel.invokeMethod<double>(
      'resumePreview',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

  /// Returns the flash mode as a String.
  String _serializeFlashMode(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return 'off';
      case FlashMode.auto:
        return 'auto';
      case FlashMode.always:
        return 'always';
      case FlashMode.torch:
        return 'torch';
      default:
        throw ArgumentError('Unknown FlashMode value');
    }
  }

  /// Returns the resolution preset as a String.
  String _serializeResolutionPreset(ResolutionPreset resolutionPreset) {
    switch (resolutionPreset) {
      case ResolutionPreset.max:
        return 'max';
      case ResolutionPreset.ultraHigh:
        return 'ultraHigh';
      case ResolutionPreset.veryHigh:
        return 'veryHigh';
      case ResolutionPreset.high:
        return 'high';
      case ResolutionPreset.medium:
        return 'medium';
      case ResolutionPreset.low:
        return 'low';
      default:
        throw ArgumentError('Unknown ResolutionPreset value');
    }
  }

  /// Converts messages received from the native platform into device events.
  Future<dynamic> _handleDeviceMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'orientation_changed':
        _deviceEventStreamController.add(DeviceOrientationChangedEvent(
            deserializeDeviceOrientation(
                call.arguments['orientation']! as String)));
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Converts messages received from the native platform into camera events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  Future<dynamic> handleCameraMethodCall(MethodCall call, int cameraId) async {
    switch (call.method) {
      case 'initialized':
        cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          call.arguments['previewWidth']! as double,
          call.arguments['previewHeight']! as double,
          deserializeExposureMode(call.arguments['exposureMode']! as String),
          call.arguments['exposurePointSupported']! as bool,
          deserializeFocusMode(call.arguments['focusMode']! as String),
          call.arguments['focusPointSupported']! as bool,
        ));
        break;
      case 'resolution_changed':
        cameraEventStreamController.add(CameraResolutionChangedEvent(
          cameraId,
          call.arguments['captureWidth']! as double,
          call.arguments['captureHeight']! as double,
        ));
        break;
      case 'camera_closing':
        cameraEventStreamController.add(CameraClosingEvent(
          cameraId,
        ));
        break;
      case 'video_recorded':
        cameraEventStreamController.add(VideoRecordedEvent(
          cameraId,
          XFile(call.arguments['path']! as String),
          call.arguments['maxVideoDuration'] != null
              ? Duration(
                  milliseconds: call.arguments['maxVideoDuration']! as int)
              : null,
        ));
        break;
      case 'error':
        cameraEventStreamController.add(CameraErrorEvent(
          cameraId,
          call.arguments['description']! as String,
        ));
        break;
      default:
        throw MissingPluginException();
    }
  }
}
