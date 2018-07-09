import 'dart:async';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum LiveViewCameraLensDirection { front, back, external }

enum LiveViewResolutionPreset { low, medium, high }

/// Returns the resolution preset as a String.
String serializeResolutionPreset(LiveViewResolutionPreset resolutionPreset) {
  switch (resolutionPreset) {
    case LiveViewResolutionPreset.high:
      return 'high';
    case LiveViewResolutionPreset.medium:
      return 'medium';
    case LiveViewResolutionPreset.low:
      return 'low';
  }
  throw new ArgumentError('Unknown ResolutionPreset value');
}

LiveViewCameraLensDirection _parseCameraLensDirection(String string) {
  switch (string) {
    case 'front':
      return LiveViewCameraLensDirection.front;
    case 'back':
      return LiveViewCameraLensDirection.back;
    case 'external':
      return LiveViewCameraLensDirection.external;
  }
  throw new ArgumentError('Unknown CameraLensDirection value');
}

/// Completes with a list of available cameras.
///
/// May throw a [LiveViewCameraException].
Future<List<LiveViewCameraDescription>> availableCameras() async {
  try {
    final List<dynamic> cameras =
        await FirebaseVision.channel.invokeMethod('availableCameras');
    return cameras.map((dynamic camera) {
      return new LiveViewCameraDescription(
        name: camera['name'],
        lensDirection: _parseCameraLensDirection(camera['lensFacing']),
      );
    }).toList();
  } on PlatformException catch (e) {
    throw new LiveViewCameraException(e.code, e.message);
  }
}

class LiveViewCameraDescription {
  final String name;
  final LiveViewCameraLensDirection lensDirection;

  LiveViewCameraDescription({this.name, this.lensDirection});

  @override
  bool operator ==(Object o) {
    return o is LiveViewCameraDescription &&
        o.name == name &&
        o.lensDirection == lensDirection;
  }

  @override
  int get hashCode {
    return hashValues(name, lensDirection);
  }

  @override
  String toString() {
    return '$runtimeType($name, $lensDirection)';
  }
}

/// This is thrown when the plugin reports an error.
class LiveViewCameraException implements Exception {
  String code;
  String description;

  LiveViewCameraException(this.code, this.description);

  @override
  String toString() => '$runtimeType($code, $description)';
}

// Build the UI texture view of the video data with textureId.
class LiveView extends StatelessWidget {
  final LiveViewCameraController controller;

  const LiveView(this.controller);

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? new Texture(textureId: controller._textureId)
        : new Container();
  }
}

/// The state of a [LiveViewCameraController].
class LiveViewCameraValue {
  /// True after [LiveViewCameraController.initialize] has completed successfully.
  final bool isInitialized;

  final String errorDescription;

  /// The size of the preview in pixels.
  ///
  /// Is `null` until  [isInitialized] is `true`.
  final Size previewSize;

  const LiveViewCameraValue({
    this.isInitialized,
    this.errorDescription,
    this.previewSize,
  });

  const LiveViewCameraValue.uninitialized()
      : this(
          isInitialized: false,
        );

  /// Convenience getter for `previewSize.height / previewSize.width`.
  ///
  /// Can only be called when [initialize] is done.
  double get aspectRatio => previewSize.height / previewSize.width;

  bool get hasError => errorDescription != null;

  LiveViewCameraValue copyWith({
    bool isInitialized,
    bool isRecordingVideo,
    bool isTakingPicture,
    String errorDescription,
    Size previewSize,
  }) {
    return new LiveViewCameraValue(
      isInitialized: isInitialized ?? this.isInitialized,
      errorDescription: errorDescription,
      previewSize: previewSize ?? this.previewSize,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'isInitialized: $isInitialized, '
        'errorDescription: $errorDescription, '
        'previewSize: $previewSize)';
  }
}

/// Controls a device camera live view.
///
/// Use [availableCameras] to get a list of available cameras.
///
/// Before using a [LiveViewCameraController] a call to [initialize] must complete.
///
/// To show the camera preview on the screen use a [LiveView] widget.
class LiveViewCameraController extends ValueNotifier<LiveViewCameraValue> {
  final LiveViewCameraDescription description;
  final LiveViewResolutionPreset resolutionPreset;

  int _textureId;
  bool _isDisposed = false;
  StreamSubscription<dynamic> _eventSubscription;
  Completer<Null> _creatingCompleter;

  LiveViewCameraController(this.description, this.resolutionPreset)
      : super(const LiveViewCameraValue.uninitialized());

  /// Initializes the camera on the device.
  ///
  /// Throws a [LiveViewCameraException] if the initialization fails.
  Future<Null> initialize() async {
    if (_isDisposed) {
      return new Future<Null>.value(null);
    }
    try {
      _creatingCompleter = new Completer<Null>();
      final Map<dynamic, dynamic> reply = await FirebaseVision.channel.invokeMethod(
        'initialize',
        <String, dynamic>{
          'cameraName': description.name,
          'resolutionPreset': serializeResolutionPreset(resolutionPreset),
        },
      );
      _textureId = reply['textureId'];
      value = value.copyWith(
        isInitialized: true,
        previewSize: new Size(
          reply['previewWidth'].toDouble(),
          reply['previewHeight'].toDouble(),
        ),
      );
    } on PlatformException catch (e) {
      throw new LiveViewCameraException(e.code, e.message);
    }
    _eventSubscription =
        new EventChannel('flutter.io/cameraPlugin/cameraEvents$_textureId')
            .receiveBroadcastStream()
            .listen(_listener);
    _creatingCompleter.complete(null);
    return _creatingCompleter.future;
  }

  /// Listen to events from the native plugins.
  ///
  /// A "cameraClosing" event is sent when the camera is closed automatically by the system (for example when the app go to background). The plugin will try to reopen the camera automatically but any ongoing recording will end.
  void _listener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (_isDisposed) {
      return;
    }

    switch (map['eventType']) {
      case 'error':
        value = value.copyWith(errorDescription: event['errorDescription']);
        break;
      case 'cameraClosing':
        value = value.copyWith(isRecordingVideo: false);
        break;
    }
  }

  /// Releases the resources of this camera.
  @override
  Future<Null> dispose() async {
    if (_isDisposed) {
      return new Future<Null>.value(null);
    }
    _isDisposed = true;
    super.dispose();
    if (_creatingCompleter == null) {
      return new Future<Null>.value(null);
    } else {
      return _creatingCompleter.future.then((_) async {
        await FirebaseVision.channel.invokeMethod(
          'dispose',
          <String, dynamic>{'textureId': _textureId},
        );
        await _eventSubscription?.cancel();
      });
    }
  }
}
