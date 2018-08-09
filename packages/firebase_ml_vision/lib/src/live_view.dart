part of firebase_ml_vision;

enum LiveViewCameraLensDirection { front, back }

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

typedef Widget OverlayBuilder(
    BuildContext context, Size previewImageSize, LiveViewDetectionList data);

// Build the UI texture view of the video data with textureId.
class LiveView extends StatefulWidget {
  final LiveViewCameraController controller;
  final OverlayBuilder overlayBuilder;

  const LiveView({this.controller, this.overlayBuilder});

  @override
  LiveViewState createState() {
    return new LiveViewState();
  }
}

class LiveViewState extends State<LiveView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller.value.isInitialized
        ? new Stack(
            children: <Widget>[
              new Texture(textureId: widget.controller._textureId),
              new Container(
                constraints: const BoxConstraints.expand(),
                child: widget.overlayBuilder(
                  context,
                  widget.controller.value.previewSize,
                  widget.controller.value.detectedData,
                ),
              )
            ],
          )
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

  final LiveViewDetectionList detectedData;

  const LiveViewCameraValue({
    this.isInitialized,
    this.errorDescription,
    this.previewSize,
    this.detectedData,
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
    LiveViewDetectionList detectedData,
  }) {
    return new LiveViewCameraValue(
      isInitialized: isInitialized ?? this.isInitialized,
      errorDescription: errorDescription,
      previewSize: previewSize ?? this.previewSize,
      detectedData: detectedData ?? this.detectedData,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'isInitialized: $isInitialized, '
        'errorDescription: $errorDescription, '
        'previewSize: $previewSize, '
        'scannedBarcodes: $detectedData)';
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
      final Map<dynamic, dynamic> reply =
          await FirebaseVision.channel.invokeMethod(
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
    _eventSubscription = new EventChannel(
            'plugins.flutter.io/firebase_ml_vision/liveViewEvents$_textureId')
        .receiveBroadcastStream()
        .listen(_listener);
    _creatingCompleter.complete(null);
    return _creatingCompleter.future;
  }

  Future<Null> setDetector(FirebaseVisionDetectorType detectorType,
      [VisionOptions options]) async {
    if (detectorType == FirebaseVisionDetectorType.face && options == null) {
      options = const FaceDetectorOptions();
    }
    await FirebaseVision.instance.setLiveViewDetector(detectorType, options);
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
      case 'detection':
        final String detectionType = event['detectionType'];
        final List<dynamic> reply = event['data'];
        LiveViewDetectionList dataList;
        if (detectionType == "barcode") {
          final List<Barcode> barcodes = <Barcode>[];
          reply.forEach((dynamic barcodeMap) {
            barcodes.add(new Barcode(barcodeMap));
          });
          dataList = new LiveViewBarcodeDetectionList(barcodes);
        } else if (detectionType == "text") {
          final List<TextBlock> texts = <TextBlock>[];
          reply.forEach((dynamic block) {
            texts.add(TextBlock.fromBlockData(block));
          });
          dataList = new LiveViewTextDetectionList(texts);
        } else if (detectionType == "face") {
          final List<Face> faces = <Face>[];
          reply.forEach((dynamic f) {
            faces.add(new Face(f));
          });
          dataList = new LiveViewFaceDetectionList(faces);
        } else if (detectionType == "label") {
          final List<Label> labels = <Label>[];
          reply.forEach((dynamic l) {
            labels.add(new Label(l));
          });
          dataList = new LiveViewLabelDetectionList(labels);
        }

        value = value.copyWith(
          detectedData: dataList,
        );
        break;
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

abstract class LiveViewDetectionList {}

class LiveViewTextDetectionList extends LiveViewDetectionList {
  final List<TextBlock> data;

  LiveViewTextDetectionList(this.data);
}

class LiveViewBarcodeDetectionList extends LiveViewDetectionList {
  final List<Barcode> data;

  LiveViewBarcodeDetectionList(this.data);
}

class LiveViewFaceDetectionList extends LiveViewDetectionList {
  final List<Face> data;

  LiveViewFaceDetectionList(this.data);
}

class LiveViewLabelDetectionList extends LiveViewDetectionList {
  final List<Label> data;

  LiveViewLabelDetectionList(this.data);
}
