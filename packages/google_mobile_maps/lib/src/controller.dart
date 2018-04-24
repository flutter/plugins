// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_mobile_maps');

/// Handler of tap events on [Marker] instances.
typedef void OnMarkerTapped(Marker marker);

typedef void OnCameraMoveStarted();
typedef void OnCameraMove(CameraPosition position);
typedef void OnCameraIdle();

/// Controller for a single GoogleMaps instance.
///
/// Used for programmatically controlling a platform-specific
/// GoogleMaps view, once created.
class GoogleMapController extends ChangeNotifier {
  /// An ID identifying the GoogleMaps instance, once created.
  final Future<int> id;
  final Map<String, Marker> _markers = <String, Marker>{};
  OnMarkerTapped onMarkerTapped;
  OnCameraMoveStarted onCameraMoveStarted;
  OnCameraMove onCameraMove;
  OnCameraIdle onCameraIdle;
  GoogleMapOptions _options;

  GoogleMapController._(
    this.id,
    this._options,
  ) {
    id.then((int id) {
      _controllers[id] = this;
    });
  }

  static Map<int, GoogleMapController> _controllers =
      <int, GoogleMapController>{};

  static Future<void> init() async {
    await _channel.invokeMethod('init');
    _channel.setMethodCallHandler((MethodCall call) {
      final int mapId = call.arguments['map'];
      final GoogleMapController controller = _controllers[mapId];
      if (controller != null) {
        controller._handleMethodCall(call);
      }
    });
  }

  void _handleMethodCall(MethodCall call) {
    switch (call.method) {
      case "marker#onTap":
        if (onMarkerTapped != null) {
          final String markerId = call.arguments['marker'];
          final Marker marker = _markers[markerId];
          if (marker != null) {
            onMarkerTapped(marker);
          }
        }
        break;
      case "map#onCameraMoveStarted":
        if (onCameraMoveStarted != null) {
          onCameraMoveStarted();
        }
        break;
      case "map#onCameraMove":
        if (onCameraMove != null) {
          onCameraMove(CameraPosition._fromJson(call.arguments['position']));
        }
        break;
      case "map#onCameraIdle":
        if (onCameraIdle != null) {
          onCameraIdle();
        }
        break;
      default:
        throw new MissingPluginException();
    }
  }

  GoogleMapOptions get options => _options;

  Future<void> updateMapOptions(GoogleMapOptions options) async {
    assert(options != null);
    _options = _options._updateWith(options);
    notifyListeners();
    final int id = await this.id;
    await _channel.invokeMethod('setMapOptions', <String, dynamic>{
      'map': id,
      'options': options._toJson(),
    });
  }

  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    final int id = await this.id;
    await _channel.invokeMethod('animateCamera', <String, dynamic>{
      'map': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    final int id = await this.id;
    await _channel.invokeMethod('moveCamera', <String, dynamic>{
      'map': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<Marker> addMarker(MarkerOptions options) async {
    assert(options != null);
    assert(options.position != null);
    final int id = await this.id;
    final MarkerOptions effectiveOptions =
        MarkerOptions.defaultOptions._withChanges(options);
    final String markerId = await _channel.invokeMethod(
      'addMarker',
      <String, dynamic>{
        'map': id,
        'options': effectiveOptions._toJson(),
      },
    );
    final Marker marker = new Marker._(this, markerId, effectiveOptions);
    _markers[markerId] = marker;
    notifyListeners();
    return marker;
  }

  Future<void> _updateMarker(Marker marker, MarkerOptions changes) async {
    assert(_markers[marker.id] == marker);
    assert(changes != null);
    final int id = await this.id;
    await _channel.invokeMethod('marker#update', <String, dynamic>{
      'map': id,
      'marker': marker.id,
      'options': changes._toJson(),
    });
    marker._options = marker._options._withChanges(changes);
    notifyListeners();
  }

  Future<void> _removeMarker(Marker marker) async {
    assert(_markers[marker.id] == marker);
    final int id = await this.id;
    await _channel.invokeMethod('marker#remove', <String, dynamic>{
      'map': id,
      'marker': marker.id,
    });
    _markers.remove(marker.id);
    notifyListeners();
  }
}

/// Controller for a GoogleMap instance that is integrated as a
/// platform overlay.
///
/// *Warning*: Platform overlays cannot be freely composed with
/// other widgets. See [PlatformOverlayController] for caveats and
/// limitations.
class GoogleMapOverlayController {
  GoogleMapOverlayController._(this.mapsController, this.overlayController);

  /// Creates a controller for a GoogleMaps of the specified size in
  /// logical pixels.
  factory GoogleMapOverlayController.fromSize({
    @required double width,
    @required double height,
    GoogleMapOptions options = const GoogleMapOptions(),
  }) {
    assert(width != null);
    assert(height != null);
    assert(options != null);
    final GoogleMapOptions effectiveOptions =
        GoogleMapOptions.defaultOptions._updateWith(options);
    final _GoogleMapsPlatformOverlay overlay =
        new _GoogleMapsPlatformOverlay(effectiveOptions);
    return new GoogleMapOverlayController._(
      new GoogleMapController._(
        overlay._textureId.future,
        effectiveOptions,
      ),
      new PlatformOverlayController(width, height, overlay),
    );
  }

  /// The controller of the GoogleMaps instance.
  final GoogleMapController mapsController;

  /// The controller of the platform overlay.
  final PlatformOverlayController overlayController;

  void dispose() {
    overlayController.dispose();
  }
}

class _GoogleMapsPlatformOverlay extends PlatformOverlay {
  _GoogleMapsPlatformOverlay(this.options);

  final GoogleMapOptions options;
  Completer<int> _textureId = new Completer<int>();

  @override
  Future<int> create(Size physicalSize) {
    _textureId.complete(_channel.invokeMethod('createMap', <String, dynamic>{
      'width': physicalSize.width,
      'height': physicalSize.height,
      'options': options._toJson(),
    }).then<int>((dynamic value) => value));
    return _textureId.future;
  }

  @override
  Future<void> show(Offset physicalOffset) async {
    final int id = await _textureId.future;
    _channel.invokeMethod('showMapOverlay', <String, dynamic>{
      'map': id,
      'x': physicalOffset.dx,
      'y': physicalOffset.dy,
    });
  }

  @override
  Future<void> hide() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('hideMapOverlay', <String, dynamic>{
      'map': id,
    });
  }

  @override
  Future<void> dispose() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('disposeMap', <String, dynamic>{
      'map': id,
    });
  }
}

/// A Widget covered by a GoogleMaps platform overlay.
class GoogleMapOverlay extends StatefulWidget {
  final GoogleMapOverlayController controller;

  GoogleMapOverlay({Key key, @required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _GoogleMapOverlayState();
}

class _GoogleMapOverlayState extends State<GoogleMapOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.overlayController.attachTo(context);
  }

  @override
  void dispose() {
    widget.controller.overlayController.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      child: new FutureBuilder<int>(
        future: widget.controller.mapsController.id,
        builder: (_, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return new Texture(textureId: snapshot.data);
          } else {
            return new Container();
          }
        },
      ),
      width: widget.controller.overlayController.width,
      height: widget.controller.overlayController.height,
    );
  }
}
