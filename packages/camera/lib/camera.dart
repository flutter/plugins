import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

final MethodChannel _channel = const MethodChannel('plugins.flutter.io/camera')
  ..invokeMethod('init');

enum CameraLensDirection { front, back, external }

enum ResolutionPreset { low, medium, high }

String serializeResolutionPreset(ResolutionPreset resolutionPreset) {
  switch (resolutionPreset) {
    case ResolutionPreset.high:
      return 'high';
    case ResolutionPreset.medium:
      return 'medium';
    case ResolutionPreset.low:
      return 'low';
  }
  throw new ArgumentError('Unknown ResolutionPreset value');
}

CameraLensDirection _parseCameraLensDirection(String string) {
  switch (string) {
    case 'front':
      return CameraLensDirection.front;
    case 'back':
      return CameraLensDirection.back;
    case 'external':
      return CameraLensDirection.external;
  }
  throw new ArgumentError('Unknown CameraLensDirection value');
}

/// Completes with a list of available cameras.
///
/// May throw a [CameraException].
Future<List<CameraDescription>> availableCameras() async {
  try {
    final List<dynamic> cameras = await _channel.invokeMethod('list');
    return cameras.map((dynamic camera) {
      return new CameraDescription(
        name: camera['name'],
        lensDirection: _parseCameraLensDirection(camera['lensFacing']),
      );
    }).toList();
  } on PlatformException catch (e) {
    throw new CameraException(e.code, e.message);
  }
}

class CameraDescription {
  final String name;
  final CameraLensDirection lensDirection;
  CameraDescription({this.name, this.lensDirection});

  @override
  bool operator ==(Object o) {
    return o is CameraDescription &&
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

class CameraException implements Exception {
  String code;
  String description;
  CameraException(this.code, this.description);

  @override
  String toString() => '$runtimeType($code, $description)';
}

class CameraPreview extends StatelessWidget {
  final CameraController controller;
  const CameraPreview(this.controller);

  @override
  Widget build(BuildContext context) {
    return controller.value.initialized
        ? new Texture(textureId: controller._textureId)
        : new Container();
  }
}

class CameraValue {
  /// True if the camera is on.
  final bool isStarted;

  /// True after [CameraController.initialize] has completed successfully.
  final bool initialized;

  final String errorDescription;

  /// The size of the preview in pixels.
  ///
  /// Is `null` until initialized is `true`.
  final Size previewSize;

  const CameraValue(
      {this.isStarted,
      this.initialized,
      this.errorDescription,
      this.previewSize});

  const CameraValue.uninitialized() : this(isStarted: true, initialized: false);

  /// Convenience getter for `previewSize.height / previewSize.width`.
  ///
  /// Can only be called when [initialized] is done.
  double get aspectRatio => previewSize.height / previewSize.width;

  bool get hasError => errorDescription != null;

  CameraValue copyWith({
    bool isStarted,
    bool initialized,
    String errorDescription,
    Size previewSize,
  }) {
    return new CameraValue(
      isStarted: isStarted ?? this.isStarted,
      initialized: initialized ?? this.initialized,
      errorDescription: errorDescription ?? this.errorDescription,
      previewSize: previewSize ?? this.previewSize,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'started: $isStarted, '
        'initialized: $initialized, '
        'errorDescription: $errorDescription, '
        'previewSize: $previewSize)';
  }
}

/// Controls a device camera.
///
/// Use [availableCameras] to get a list of available cameras.
///
/// Before using a [CameraController] a call to [initialize] must complete.
///
/// To show the camera preview on the screen use a [CameraPreview] widget.
class CameraController extends ValueNotifier<CameraValue> {
  final CameraDescription description;
  final ResolutionPreset resolutionPreset;
  int _textureId;
  bool _disposed = false;
  StreamSubscription<dynamic> _eventSubscription;
  Completer<Null> _creatingCompleter;

  CameraController(this.description, this.resolutionPreset)
      : super(const CameraValue.uninitialized());

  /// Initializes the camera on the device.
  ///
  /// Throws a [CameraException] if the initialization fails.
  Future<Null> initialize() async {
    if (_disposed) {
      return;
    }
    try {
      _creatingCompleter = new Completer<Null>();
      final Map<dynamic, dynamic> reply = await _channel.invokeMethod(
        'create',
        <String, dynamic>{
          'cameraName': description.name,
          'resolutionPreset': serializeResolutionPreset(resolutionPreset),
        },
      );
      _textureId = reply['textureId'];
      value = value.copyWith(
        initialized: true,
        previewSize: new Size(
          reply['previewWidth'].toDouble(),
          reply['previewHeight'].toDouble(),
        ),
      );
      _applyStartStop();
    } on PlatformException catch (e) {
      value = value.copyWith(errorDescription: e.message);
      throw new CameraException(e.code, e.message);
    }
    _eventSubscription =
        new EventChannel('flutter.io/cameraPlugin/cameraEvents$_textureId')
            .receiveBroadcastStream()
            .listen(_listener);
    _creatingCompleter.complete(null);
  }

  void _listener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (_disposed) {
      return;
    }
    if (map['eventType'] == 'error') {
      value = value.copyWith(errorDescription: event['errorDescription']);
    }
  }

  /// Captures an image and saves it to [path].
  ///
  /// A path can for example be obtained using
  /// [path_provider](https://pub.dartlang.org/packages/path_provider).
  ///
  /// Throws a [CameraException] if the capture fails.
  Future<Null> capture(String path) async {
    if (!value.initialized || _disposed) {
      throw new CameraException(
        'Uninitialized capture()',
        'capture() was called on uninitialized CameraController',
      );
    }
    try {
      await _channel.invokeMethod(
        'capture',
        <String, dynamic>{'textureId': _textureId, 'path': path},
      );
    } on PlatformException catch (e) {
      throw new CameraException(e.code, e.message);
    }
  }

  void _applyStartStop() {
    if (value.initialized && !_disposed) {
      if (value.isStarted) {
        _channel.invokeMethod(
          'start',
          <String, dynamic>{'textureId': _textureId},
        );
      } else {
        _channel.invokeMethod(
          'stop',
          <String, dynamic>{'textureId': _textureId},
        );
      }
    }
  }

  /// Starts the preview.
  ///
  /// If called before [initialize] it will take effect just after
  /// initialization is done.
  void start() {
    value = value.copyWith(isStarted: true);
    _applyStartStop();
  }

  /// Stops the preview.
  ///
  /// If called before [initialize] it will take effect just after
  /// initialization is done.
  void stop() {
    value = value.copyWith(isStarted: false);
    _applyStartStop();
  }

  /// Releases the resources of this camera.
  @override
  Future<Null> dispose() {
    if (_disposed) {
      return new Future<Null>.value(null);
    }
    _disposed = true;
    super.dispose();
    if (_creatingCompleter == null) {
      return new Future<Null>.value(null);
    } else {
      return _creatingCompleter.future.then((_) async {
        await _eventSubscription?.cancel();
        await _channel.invokeMethod(
          'dispose',
          <String, dynamic>{'textureId': _textureId},
        );
      });
    }
  }
}
