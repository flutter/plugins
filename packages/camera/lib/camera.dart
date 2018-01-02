import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

final MethodChannel _channel = const MethodChannel('camera')
  ..invokeMethod('init');

enum CameraLensDirection { front, back, external, unknown }

CameraLensDirection _parseCameraLensDirection(String string) {
  switch (string) {
    case 'front':
      return CameraLensDirection.front;
    case 'back':
      return CameraLensDirection.back;
    case 'external':
      return CameraLensDirection.external;
    default:
      return CameraLensDirection.unknown;
  }
}

Future<List<CameraConfiguration>> availableCameras() async {
  Size parseSize(Map<String, Object> m) {
    return new Size((m["width"] as int).toDouble(), (m["height"] as int).toDouble());
  }
  try {
    List<Map<String, String>> cameras = await _channel.invokeMethod('list');
    var v = cameras.map((Map<String, dynamic> camera) {
      return new CameraConfiguration(
          name: camera['name'],
          lensDirection: _parseCameraLensDirection(camera['lensFacing']),
      previewSize: parseSize(camera['previewFormat']),
      captureSize: parseSize(camera['captureFormat']));
    }).toList();
    return v;
  } on PlatformException catch (e) {
    throw new CameraException(e.code, e.message);
  }
}

class CameraConfiguration {
  final String name;
  final CameraLensDirection lensDirection;
  final Size captureSize;
  final Size previewSize;
  CameraConfiguration({this.name, this.lensDirection, this.previewSize, this.captureSize});

  @override
  bool operator ==(Object o) {
    return o is CameraConfiguration &&
        o.lensDirection == lensDirection &&
        o.previewSize == previewSize &&
        o.captureSize == previewSize;
  }

  @override
  int get hashCode {
    return hashValues(previewSize, captureSize);
  }

  @override
  String toString() {
    return "$runtimeType(${previewSize}x$captureSize)";
  }
}

enum CameraEvent { error, disconnected }

CameraEvent _parseCameraEvent(String string) {
  switch (string) {
    case 'error':
      return CameraEvent.error;
    case 'disconnected':
      return CameraEvent.disconnected;
    default:
      throw new ArgumentError("$string is not a valid camera event");
  }
}

class CameraException implements Exception {
  String code;
  String description;
  CameraException(this.code, this.description);
  String toString() => "$runtimeType($code, $description)";
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
  final bool isPlaying;
  final bool initialized;
  final String errorDescription;
  bool get isErroneous => errorDescription != null;

  CameraValue({this.isPlaying, this.initialized, this.errorDescription});

  CameraValue.uninitialized() : this(isPlaying: false, initialized: false);

  CameraValue copyWith({bool isPlaying, bool initialized, String errorDescription}) {
    return new CameraValue(
      isPlaying: isPlaying ?? this.isPlaying,
      initialized: initialized ?? this.initialized,
      errorDescription: errorDescription ?? this.errorDescription
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'playing: $isPlaying, '
        'initialized: $initialized, '
        'errorDescription: $errorDescription)';
  }
}

class CameraController extends ValueNotifier<CameraValue> {
  final CameraConfiguration configuration;
  int _textureId;
  bool _disposed = false;
  StreamSubscription<CameraEvent> _eventSubscription;
  Completer<Null> _creatingCompleter;

  CameraController(this.configuration)
      : super(new CameraValue.uninitialized());

  Future<Null> initialize() async {
    if (_disposed) {
      return;
    }
    try {
      _creatingCompleter = new Completer<Null>();
      _textureId = await _channel.invokeMethod('create', {
        'cameraName': configuration.name,
        'previewWidth': configuration.previewSize.width.toInt(),
        'previewHeight': configuration.previewSize.height.toInt(),
        'captureWidth': configuration.captureSize.width.toInt(),
        'captureHeight': configuration.captureSize.height.toInt(),
      });
      value = value.copyWith(initialized: true);
      _applyStartStop();
    } on PlatformException catch (e) {
      throw new CameraException(e.code, e.message);
    }
    _eventSubscription = new EventChannel('cameraPlugin/cameraEvents$_textureId')
            .receiveBroadcastStream()
            .map(_parseCameraEvent).listen(_listener);
    _creatingCompleter.complete(null);
  }

  void _listener(CameraEvent event) {
    switch (event) {
      case CameraEvent.disconnected:

      case CameraEvent.error:
    }
  }

  Future<Null> dispose() async {

    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_disposed) {
        _disposed = true;
        await _eventSubscription?.cancel();
        await _channel.invokeMethod(
          'dispose',
          <String, dynamic>{'textureId': _textureId},
        );
      }
    }
    _disposed = true;
    super.dispose();
  }

  /// Captures an image and saves it to [filename].
  Future<String> capture(String filename) async {
    if (!value.initialized || _disposed) {
      throw new CameraException('Uninitialized capture()',
          'capture() was called on uninitialized CameraController');
    }
    try {
      return await _channel.invokeMethod(
          'capture', {'textureId': _textureId, 'filename': filename});
    } on PlatformException catch (e) {
      throw new CameraException(e.code, e.message);
    }
  }

  void _applyStartStop() {
    if (value.initialized && !_disposed) {
      if (value.isPlaying) {
        _channel
            .invokeMethod('start', {'textureId': _textureId}).catchError(print);
      } else {
        _channel.invokeMethod('stop', {'textureId': _textureId});
      }
    }
  }

  /// Starts the preview.
  Future<Null> start() async {
    value = value.copyWith(isPlaying: true);
    _applyStartStop();
  }

  /// Stops the preview.
  Future<Null> stop() async {
    value = value.copyWith(isPlaying: false);
    _applyStartStop();
  }
}
