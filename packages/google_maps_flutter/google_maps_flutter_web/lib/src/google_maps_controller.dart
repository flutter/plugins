// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// Type used when passing an override to the _createMap function.
@visibleForTesting
typedef DebugCreateMapFunction = gmaps.GMap Function(
    HtmlElement div, gmaps.MapOptions options);

/// Encapsulates a [gmaps.GMap], its events, and where in the DOM it's rendered.
class GoogleMapController {
  /// Initializes the GMap, and the sub-controllers related to it. Wires events.
  GoogleMapController({
    required int mapId,
    required StreamController<MapEvent<Object?>> streamController,
    required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  })  : _mapId = mapId,
        _streamController = streamController,
        _initialCameraPosition = initialCameraPosition,
        _markers = markers,
        _polygons = polygons,
        _polylines = polylines,
        _circles = circles,
        _rawMapOptions = mapOptions {
    _circlesController = CirclesController(stream: _streamController);
    _polygonsController = PolygonsController(stream: _streamController);
    _polylinesController = PolylinesController(stream: _streamController);
    _markersController = MarkersController(stream: _streamController);

    // Register the view factory that will hold the `_div` that holds the map in the DOM.
    // The `_div` needs to be created outside of the ViewFactory (and cached!) so we can
    // use it to create the [gmaps.GMap] in the `init()` method of this class.
    _div = DivElement()
      ..id = _getViewType(mapId)
      ..style.width = '100%'
      ..style.height = '100%';

    ui.platformViewRegistry.registerViewFactory(
      _getViewType(mapId),
      (int viewId) => _div,
    );
  }

  // The internal ID of the map. Used to broadcast events, DOM IDs and everything where a unique ID is needed.
  final int _mapId;

  final CameraPosition _initialCameraPosition;
  final Set<Marker> _markers;
  final Set<Polygon> _polygons;
  final Set<Polyline> _polylines;
  final Set<Circle> _circles;
  // The raw options passed by the user, before converting to gmaps.
  // Caching this allows us to re-create the map faithfully when needed.
  Map<String, dynamic> _rawMapOptions = <String, dynamic>{};

  // Creates the 'viewType' for the _widget
  String _getViewType(int mapId) => 'plugins.flutter.io/google_maps_$mapId';

  // The Flutter widget that contains the rendered Map.
  HtmlElementView? _widget;
  late HtmlElement _div;

  /// The Flutter widget that will contain the rendered Map. Used for caching.
  Widget? get widget {
    if (_widget == null && !_streamController.isClosed) {
      _widget = HtmlElementView(
        viewType: _getViewType(_mapId),
      );
    }
    return _widget;
  }

  // The currently-enabled traffic layer.
  gmaps.TrafficLayer? _trafficLayer;

  /// A getter for the current traffic layer. Only for tests.
  @visibleForTesting
  gmaps.TrafficLayer? get trafficLayer => _trafficLayer;

  // The underlying GMap instance. This is the interface with the JS SDK.
  gmaps.GMap? _googleMap;

  // The StreamController used by this controller and the geometry ones.
  final StreamController<MapEvent<Object?>> _streamController;

  /// The StreamController for the events of this Map. Only for integration testing.
  @visibleForTesting
  StreamController<MapEvent<Object?>> get stream => _streamController;

  /// The Stream over which this controller broadcasts events.
  Stream<MapEvent<Object?>> get events => _streamController.stream;

  // Geometry controllers, for different features of the map.
  CirclesController? _circlesController;
  PolygonsController? _polygonsController;
  PolylinesController? _polylinesController;
  MarkersController? _markersController;
  // Keeps track if _attachGeometryControllers has been called or not.
  bool _controllersBoundToMap = false;

  // Keeps track if the map is moving or not.
  bool _mapIsMoving = false;

  /// Overrides certain properties to install mocks defined during testing.
  @visibleForTesting
  void debugSetOverrides({
    DebugCreateMapFunction? createMap,
    MarkersController? markers,
    CirclesController? circles,
    PolygonsController? polygons,
    PolylinesController? polylines,
  }) {
    _overrideCreateMap = createMap;
    _markersController = markers ?? _markersController;
    _circlesController = circles ?? _circlesController;
    _polygonsController = polygons ?? _polygonsController;
    _polylinesController = polylines ?? _polylinesController;
  }

  DebugCreateMapFunction? _overrideCreateMap;

  gmaps.GMap _createMap(HtmlElement div, gmaps.MapOptions options) {
    if (_overrideCreateMap != null) {
      return _overrideCreateMap!(div, options);
    }
    return gmaps.GMap(div, options);
  }

  /// A flag that returns true if the controller has been initialized or not.
  @visibleForTesting
  bool get isInitialized => _googleMap != null;

  /// Starts the JS Maps SDK into the target [_div] with `rawOptions`.
  ///
  /// (Also initializes the geometry/traffic layers.)
  ///
  /// The first part of this method starts the rendering of a [gmaps.GMap] inside
  /// of the target [_div], with configuration from `rawOptions`. It then stores
  /// the created GMap in the [_googleMap] attribute.
  ///
  /// Not *everything* is rendered with the initial `rawOptions` configuration,
  /// geometry and traffic layers (and possibly others in the future) have their
  /// own configuration and are rendered on top of a GMap instance later. This
  /// happens in the second half of this method.
  ///
  /// This method is eagerly called from the [GoogleMapsPlugin.buildView] method
  /// so the internal [GoogleMapsController] of a Web Map initializes as soon as
  /// possible. Check [_attachMapEvents] to see how this controller notifies the
  /// plugin of it being fully ready (through the `onTilesloaded.first` event).
  ///
  /// Failure to call this method would result in the GMap not rendering at all,
  /// and most of the public methods on this class no-op'ing.
  void init() {
    gmaps.MapOptions options = _rawOptionsToGmapsOptions(_rawMapOptions);
    // Initial position can only to be set here!
    options = _applyInitialPosition(_initialCameraPosition, options);

    // Create the map...
    final gmaps.GMap map = _createMap(_div, options);
    _googleMap = map;

    _attachMapEvents(map);
    _attachGeometryControllers(map);

    // Now attach the geometry, traffic and any other layers...
    _renderInitialGeometry(
      markers: _markers,
      circles: _circles,
      polygons: _polygons,
      polylines: _polylines,
    );

    _setTrafficLayer(map, _isTrafficLayerEnabled(_rawMapOptions));
  }

  // Funnels map gmap events into the plugin's stream controller.
  void _attachMapEvents(gmaps.GMap map) {
    map.onTilesloaded.first.then((void _) {
      // Report the map as ready to go the first time the tiles load
      _streamController.add(WebMapReadyEvent(_mapId));
    });
    map.onClick.listen((gmaps.IconMouseEvent event) {
      assert(event.latLng != null);
      _streamController.add(
        MapTapEvent(_mapId, _gmLatLngToLatLng(event.latLng!)),
      );
    });
    map.onRightclick.listen((gmaps.MapMouseEvent event) {
      assert(event.latLng != null);
      _streamController.add(
        MapLongPressEvent(_mapId, _gmLatLngToLatLng(event.latLng!)),
      );
    });
    map.onBoundsChanged.listen((void _) {
      if (!_mapIsMoving) {
        _mapIsMoving = true;
        _streamController.add(CameraMoveStartedEvent(_mapId));
      }
      _streamController.add(
        CameraMoveEvent(_mapId, _gmViewportToCameraPosition(map)),
      );
    });
    map.onIdle.listen((void _) {
      _mapIsMoving = false;
      _streamController.add(CameraIdleEvent(_mapId));
    });
  }

  // Binds the Geometry controllers to a map instance
  void _attachGeometryControllers(gmaps.GMap map) {
    // Now we can add the initial geometry.
    // And bind the (ready) map instance to the other geometry controllers.
    //
    // These controllers are either created in the constructor of this class, or
    // overriden (for testing) by the [debugSetOverrides] method. They can't be
    // null.
    assert(_circlesController != null,
        'Cannot attach a map to a null CirclesController instance.');
    assert(_polygonsController != null,
        'Cannot attach a map to a null PolygonsController instance.');
    assert(_polylinesController != null,
        'Cannot attach a map to a null PolylinesController instance.');
    assert(_markersController != null,
        'Cannot attach a map to a null MarkersController instance.');

    _circlesController!.bindToMap(_mapId, map);
    _polygonsController!.bindToMap(_mapId, map);
    _polylinesController!.bindToMap(_mapId, map);
    _markersController!.bindToMap(_mapId, map);

    _controllersBoundToMap = true;
  }

  // Renders the initial sets of geometry.
  void _renderInitialGeometry({
    Set<Marker> markers = const <Marker>{},
    Set<Circle> circles = const <Circle>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
  }) {
    assert(
        _controllersBoundToMap,
        'Geometry controllers must be bound to a map before any geometry can '
        'be added to them. Ensure _attachGeometryControllers is called first.');

    // The above assert will only succeed if the controllers have been bound to a map
    // in the [_attachGeometryControllers] method, which ensures that all these
    // controllers below are *not* null.

    _markersController!.addMarkers(markers);
    _circlesController!.addCircles(circles);
    _polygonsController!.addPolygons(polygons);
    _polylinesController!.addPolylines(polylines);
  }

  // Merges new options coming from the plugin into the _rawMapOptions map.
  //
  // Returns the updated _rawMapOptions object.
  Map<String, dynamic> _mergeRawOptions(Map<String, dynamic> newOptions) {
    _rawMapOptions = <String, dynamic>{
      ..._rawMapOptions,
      ...newOptions,
    };
    return _rawMapOptions;
  }

  /// Updates the map options from a `Map<String, dynamic>`.
  ///
  /// This method converts the map into the proper [gmaps.MapOptions]
  void updateRawOptions(Map<String, dynamic> optionsUpdate) {
    assert(_googleMap != null, 'Cannot update options on a null map.');

    final Map<String, dynamic> newOptions = _mergeRawOptions(optionsUpdate);

    _setOptions(_rawOptionsToGmapsOptions(newOptions));
    _setTrafficLayer(_googleMap!, _isTrafficLayerEnabled(newOptions));
  }

  // Sets new [gmaps.MapOptions] on the wrapped map.
  // ignore: use_setters_to_change_properties
  void _setOptions(gmaps.MapOptions options) {
    _googleMap?.options = options;
  }

  // Attaches/detaches a Traffic Layer on the passed `map` if `attach` is true/false.
  void _setTrafficLayer(gmaps.GMap map, bool attach) {
    if (attach && _trafficLayer == null) {
      _trafficLayer = gmaps.TrafficLayer()..set('map', map);
    }
    if (!attach && _trafficLayer != null) {
      _trafficLayer!.set('map', null);
      _trafficLayer = null;
    }
  }

  // _googleMap manipulation
  // Viewport

  /// Returns the [LatLngBounds] of the current viewport.
  Future<LatLngBounds> getVisibleRegion() async {
    assert(_googleMap != null, 'Cannot get the visible region of a null map.');

    final gmaps.LatLngBounds bounds =
        await Future<gmaps.LatLngBounds?>.value(_googleMap!.bounds) ??
            _nullGmapsLatLngBounds;

    return _gmLatLngBoundsTolatLngBounds(bounds);
  }

  /// Returns the [ScreenCoordinate] for a given viewport [LatLng].
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    assert(_googleMap != null,
        'Cannot get the screen coordinates with a null map.');

    final gmaps.Point point =
        toScreenLocation(_googleMap!, _latLngToGmLatLng(latLng));

    return ScreenCoordinate(x: point.x!.toInt(), y: point.y!.toInt());
  }

  /// Returns the [LatLng] for a `screenCoordinate` (in pixels) of the viewport.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    assert(_googleMap != null,
        'Cannot get the lat, lng of a screen coordinate with a null map.');

    final gmaps.LatLng latLng =
        _pixelToLatLng(_googleMap!, screenCoordinate.x, screenCoordinate.y);
    return _gmLatLngToLatLng(latLng);
  }

  /// Applies a `cameraUpdate` to the current viewport.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    assert(_googleMap != null, 'Cannot update the camera of a null map.');

    return _applyCameraUpdate(_googleMap!, cameraUpdate);
  }

  /// Returns the zoom level of the current viewport.
  Future<double> getZoomLevel() async {
    assert(_googleMap != null, 'Cannot get zoom level of a null map.');
    assert(_googleMap!.zoom != null,
        'Zoom level should not be null. Is the map correctly initialized?');

    return _googleMap!.zoom!.toDouble();
  }

  // Geometry manipulation

  /// Applies [CircleUpdates] to the currently managed circles.
  void updateCircles(CircleUpdates updates) {
    assert(
        _circlesController != null, 'Cannot update circles after dispose().');
    _circlesController?.addCircles(updates.circlesToAdd);
    _circlesController?.changeCircles(updates.circlesToChange);
    _circlesController?.removeCircles(updates.circleIdsToRemove);
  }

  /// Applies [PolygonUpdates] to the currently managed polygons.
  void updatePolygons(PolygonUpdates updates) {
    assert(
        _polygonsController != null, 'Cannot update polygons after dispose().');
    _polygonsController?.addPolygons(updates.polygonsToAdd);
    _polygonsController?.changePolygons(updates.polygonsToChange);
    _polygonsController?.removePolygons(updates.polygonIdsToRemove);
  }

  /// Applies [PolylineUpdates] to the currently managed lines.
  void updatePolylines(PolylineUpdates updates) {
    assert(_polylinesController != null,
        'Cannot update polylines after dispose().');
    _polylinesController?.addPolylines(updates.polylinesToAdd);
    _polylinesController?.changePolylines(updates.polylinesToChange);
    _polylinesController?.removePolylines(updates.polylineIdsToRemove);
  }

  /// Applies [MarkerUpdates] to the currently managed markers.
  void updateMarkers(MarkerUpdates updates) {
    assert(
        _markersController != null, 'Cannot update markers after dispose().');
    _markersController?.addMarkers(updates.markersToAdd);
    _markersController?.changeMarkers(updates.markersToChange);
    _markersController?.removeMarkers(updates.markerIdsToRemove);
  }

  /// Shows the [InfoWindow] of the marker identified by its [MarkerId].
  void showInfoWindow(MarkerId markerId) {
    assert(_markersController != null,
        'Cannot show infowindow of marker [${markerId.value}] after dispose().');
    _markersController?.showMarkerInfoWindow(markerId);
  }

  /// Hides the [InfoWindow] of the marker identified by its [MarkerId].
  void hideInfoWindow(MarkerId markerId) {
    assert(_markersController != null,
        'Cannot hide infowindow of marker [${markerId.value}] after dispose().');
    _markersController?.hideMarkerInfoWindow(markerId);
  }

  /// Returns true if the [InfoWindow] of the marker identified by [MarkerId] is shown.
  bool isInfoWindowShown(MarkerId markerId) {
    return _markersController?.isInfoWindowShown(markerId) ?? false;
  }

  // Cleanup

  /// Disposes of this controller and its resources.
  ///
  /// You won't be able to call many of the methods on this controller after
  /// calling `dispose`!
  void dispose() {
    _widget = null;
    _googleMap = null;
    _circlesController = null;
    _polygonsController = null;
    _polylinesController = null;
    _markersController = null;
    _streamController.close();
  }
}

/// A MapEvent event fired when a [mapId] on web is interactive.
class WebMapReadyEvent extends MapEvent<Object?> {
  /// Build a WebMapReady Event for the map represented by `mapId`.
  WebMapReadyEvent(int mapId) : super(mapId, null);
}
