// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_maps');

/// Controller for a single GoogleMap instance running on the host platform.
///
/// Change listeners are notified upon changes to any of
///
/// * the [options] property
/// * the collection of [Marker]s added to this map
/// * the [isCameraMoving] property
/// * the [cameraPosition] property
///
/// Listeners are notified after changes have been applied on the platform side.
///
/// Marker tap events can be received by adding callbacks to [onMarkerTapped].
class GoogleMapController extends ChangeNotifier {
  @visibleForTesting
  GoogleMapController(this._id, GoogleMapOptions options)
      : assert(_id != null),
        assert(options != null),
        assert(options.cameraPosition != null),
        _options = options {
    _id.then((int id) {
      _controllers[id] = this;
    });
    if (options.trackCameraPosition) {
      _cameraPosition = options.cameraPosition;
    }
  }

  /// Callbacks to receive tap events for markers placed on this map.
  final ArgumentCallbacks<Marker> onMarkerTapped =
      new ArgumentCallbacks<Marker>();

  /// Callbacks to receive tap events for info windows on markers
  final ArgumentCallbacks<Marker> onInfoWindowTapped =
      new ArgumentCallbacks<Marker>();

  /// The configuration options most recently applied via controller
  /// initialization or [updateMapOptions].
  GoogleMapOptions get options => _options;
  GoogleMapOptions _options;

  /// The current set of markers on this map.
  ///
  /// The returned set will be a detached snapshot of the markers collection.
  Set<Marker> get markers => new Set<Marker>.from(_markers.values);
  final Map<String, Marker> _markers = <String, Marker>{};

  /// True if the map camera is currently moving.
  bool get isCameraMoving => _isCameraMoving;
  bool _isCameraMoving = false;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if camera position tracking is not enabled via
  /// [GoogleMapOptions].
  CameraPosition get cameraPosition => _cameraPosition;
  CameraPosition _cameraPosition;

  final Future<int> _id;

  static Map<int, GoogleMapController> _controllers =
      <int, GoogleMapController>{};

  /// Initializes the GoogleMaps plugin. Should be called from the Flutter
  /// application's main entry point.
  // Clears any existing platform-side map instances after hot restart.
  // Sets up method call handlers for receiving map events.
  static Future<void> init() async {
    await _channel.invokeMethod('init');
    _controllers.clear();
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
      case 'infoWindow#onTap':
        final String markerId = call.arguments['marker'];
        final Marker marker = _markers[markerId];
        if (marker != null) {
          onInfoWindowTapped(marker);
        }
        break;

      case 'marker#onTap':
        final String markerId = call.arguments['marker'];
        final Marker marker = _markers[markerId];
        if (marker != null) {
          onMarkerTapped(marker);
        }
        break;
      case 'camera#onMoveStarted':
        _isCameraMoving = true;
        notifyListeners();
        break;
      case 'camera#onMove':
        _cameraPosition = CameraPosition._fromJson(call.arguments['position']);
        notifyListeners();
        break;
      case 'camera#onIdle':
        _isCameraMoving = false;
        notifyListeners();
        break;
      default:
        throw new MissingPluginException();
    }
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMapOptions(GoogleMapOptions changes) async {
    assert(changes != null);
    final int id = await _id;
    final dynamic json = await _channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'map': id,
        'options': changes._toJson(),
      },
    );
    _options = _options.copyWith(changes);
    _cameraPosition = CameraPosition._fromJson(json);
    notifyListeners();
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    final int id = await _id;
    await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'map': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    final int id = await _id;
    await _channel.invokeMethod('camera#move', <String, dynamic>{
      'map': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Adds a marker to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the marker has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added marker once listeners have
  /// been notified.
  Future<Marker> addMarker(MarkerOptions options) async {
    final int id = await _id;
    final MarkerOptions effectiveOptions =
        MarkerOptions.defaultOptions.copyWith(options);
    final String markerId = await _channel.invokeMethod(
      'marker#add',
      <String, dynamic>{
        'map': id,
        'options': effectiveOptions._toJson(),
      },
    );
    final Marker marker = new Marker(markerId, effectiveOptions);
    _markers[markerId] = marker;
    notifyListeners();
    return marker;
  }

  /// Updates the specified [marker] with the given [changes]. The marker must
  /// be a current member of the [markers] set.
  ///
  /// Change listeners are notified once the marker has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateMarker(Marker marker, MarkerOptions changes) async {
    assert(marker != null);
    assert(_markers[marker._id] == marker);
    assert(changes != null);
    final int id = await _id;
    await _channel.invokeMethod('marker#update', <String, dynamic>{
      'map': id,
      'marker': marker._id,
      'options': changes._toJson(),
    });
    marker._options = marker._options.copyWith(changes);
    notifyListeners();
  }

  /// Removes the specified [marker] from the map. The marker must be a current
  /// member of the [markers] set.
  ///
  /// Change listeners are notified once the marker has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeMarker(Marker marker) async {
    assert(marker != null);
    assert(_markers[marker._id] == marker);
    final int id = await _id;
    await _channel.invokeMethod('marker#remove', <String, dynamic>{
      'map': id,
      'marker': marker._id,
    });
    _markers.remove(marker._id);
    notifyListeners();
  }
}

/// Controller pair for a GoogleMap instance that is integrated as a
/// platform overlay.
///
/// The [mapController] programmatically controls the platform GoogleMap view
/// and supports event handling.
///
/// The [overlayController] is used to hide and show the platform overlay at
/// appropriate times to avoid rendering artifacts when the necessary conditions
/// for correctly displaying a platform overlay are not met: the underlying
/// widget must be stationary and rendered on top of all other widgets within
/// bounds.
///
/// *Warning*: Platform overlays cannot be freely composed with
/// other widgets. See [PlatformOverlayController] for caveats and
/// limitations.
class GoogleMapOverlayController {
  GoogleMapOverlayController._(this.mapController, this.overlayController);

  /// Creates a controller for a GoogleMaps of the specified size and with the
  /// specified custom [options], if any.
  factory GoogleMapOverlayController.fromSize({
    @required double width,
    @required double height,
    GoogleMapOptions options,
  }) {
    assert(width != null);
    assert(height != null);
    final GoogleMapOptions effectiveOptions =
        GoogleMapOptions.defaultOptions.copyWith(options);
    final _GoogleMapsPlatformOverlay overlay =
        new _GoogleMapsPlatformOverlay(effectiveOptions);
    return new GoogleMapOverlayController._(
      new GoogleMapController(overlay._textureId.future, effectiveOptions),
      new PlatformOverlayController(width, height, overlay),
    );
  }

  /// The controller of the GoogleMaps instance.
  final GoogleMapController mapController;

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
  Future<int> create(Size size) {
    _textureId.complete(_channel.invokeMethod('map#create', <String, dynamic>{
      'width': size.width,
      'height': size.height,
      'options': options._toJson(),
    }).then<int>((dynamic value) => value));
    return _textureId.future;
  }

  @override
  Future<void> show(Offset offset) async {
    final int id = await _textureId.future;
    _channel.invokeMethod('map#show', <String, dynamic>{
      'map': id,
      'x': offset.dx,
      'y': offset.dy,
    });
  }

  @override
  Future<void> hide() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('map#hide', <String, dynamic>{
      'map': id,
    });
  }

  @override
  Future<void> dispose() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('map#dispose', <String, dynamic>{
      'map': id,
    });
  }
}

/// A widget covered by a GoogleMap platform overlay.
///
/// The overlay is intended to be shown only while the map is interactive,
/// stationary, and the widget is rendered on top of all other widgets. In all
/// other situations, the overlay should be hidden to avoid rendering artifacts.
/// While the overlay is hidden, the widget shows a Texture with the most recent
/// bitmap snapshot extracted from the GoogleMap view. That bitmap will be
/// slightly delayed compared to the actual platform view which will be visible,
/// if a map animation is started and the overlay then hidden.
///
/// *Warning*: Platform overlays cannot be freely composed with
/// other widgets. See [PlatformOverlayController] for caveats and
/// limitations.
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
        future: widget.controller.mapController._id,
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
