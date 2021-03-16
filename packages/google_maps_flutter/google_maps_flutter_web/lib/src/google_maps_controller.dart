// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// Type used when passing an override to the _createMap function.
@visibleForTesting
typedef DebugCreateMapFunction = gmaps.GMap Function(
    HtmlElement div, gmaps.MapOptions options);

/// Encapsulates a [gmaps.GMap], its events, and where in the DOM it's rendered.
class GoogleMapController {
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
  HtmlElementView _widget;
  HtmlElement _div;

  /// The Flutter widget that will contain the rendered Map. Used for caching.
  HtmlElementView get widget {
    if (_widget == null && !_streamController.isClosed) {
      _widget = HtmlElementView(
        viewType: _getViewType(_mapId),
      );
    }
    return _widget;
  }

  // The currently-enabled traffic layer.
  gmaps.TrafficLayer _trafficLayer;

  /// A getter for the current traffic layer. Only for tests.
  @visibleForTesting
  gmaps.TrafficLayer get trafficLayer => _trafficLayer;

  // The underlying GMap instance. This is the interface with the JS SDK.
  gmaps.GMap _googleMap;

  // The StreamController used by this controller and the geometry ones.
  final StreamController<MapEvent> _streamController;

  /// The Stream over which this controller broadcasts events.
  Stream<MapEvent> get events => _streamController.stream;

  // Geometry controllers, for different features of the map.
  CirclesController _circlesController;
  PolygonsController _polygonsController;
  PolylinesController _polylinesController;
  MarkersController _markersController;
  // Keeps track if _attachGeometryControllers has been called or not.
  bool _controllersBoundToMap = false;

  // Keeps track if the map is moving or not.
  bool _mapIsMoving = false;

  /// Initializes the GMap, and the sub-controllers related to it. Wires events.
  GoogleMapController({
    @required int mapId,
    @required StreamController<MapEvent> streamController,
    @required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  })  : _mapId = mapId,
        _streamController = streamController,
        _initialCameraPosition = initialCameraPosition,
        _markers = markers,
        _polygons = polygons,
        _polylines = polylines,
        _circles = circles,
        _rawMapOptions = mapOptions {
    _circlesController = CirclesController(stream: this._streamController);
    _polygonsController = PolygonsController(stream: this._streamController);
    _polylinesController = PolylinesController(stream: this._streamController);
    _markersController = MarkersController(stream: this._streamController);

    // Register the view factory that will hold the `_div` that holds the map in the DOM.
    // The `_div` needs to be created outside of the ViewFactory (and cached!) so we can
    // use it to create the [gmaps.GMap] in the `init()` method of this class.
    _div = DivElement()..id = _getViewType(mapId);

    ui.platformViewRegistry.registerViewFactory(
      _getViewType(mapId),
      (int viewId) => _div,
    );
  }

  /// Overrides certain properties to install mocks defined during testing.
  @visibleForTesting
  void debugSetOverrides({
    DebugCreateMapFunction createMap,
    MarkersController markers,
    CirclesController circles,
    PolygonsController polygons,
    PolylinesController polylines,
  }) {
    _overrideCreateMap = createMap;
    _markersController = markers ?? _markersController;
    _circlesController = circles ?? _circlesController;
    _polygonsController = polygons ?? _polygonsController;
    _polylinesController = polylines ?? _polylinesController;
  }

  DebugCreateMapFunction _overrideCreateMap;

  gmaps.GMap _createMap(HtmlElement div, gmaps.MapOptions options) {
    if (_overrideCreateMap != null) {
      return _overrideCreateMap(div, options);
    }
    return gmaps.GMap(div, options);
  }

  /// Initializes the [gmaps.GMap] instance from the stored `rawOptions`.
  ///
  /// This method actually renders the GMap into the cached `_div`. This is
  /// called by the [GoogleMapsPlugin.init] method when appropriate.
  ///
  /// Failure to call this method would result in the GMap not rendering at all,
  /// and most of the public methods on this class no-op'ing.
  void init() {
    var options = _rawOptionsToGmapsOptions(_rawMapOptions);
    // Initial position can only to be set here!
    options = _applyInitialPosition(_initialCameraPosition, options);

    // Create the map...
    _googleMap = _createMap(_div, options);

    _attachMapEvents(_googleMap);
    _attachGeometryControllers(_googleMap);

    _renderInitialGeometry(
      markers: _markers,
      circles: _circles,
      polygons: _polygons,
      polylines: _polylines,
    );

    _setTrafficLayer(_googleMap, _isTrafficLayerEnabled(_rawMapOptions));
  }

  // Funnels map gmap events into the plugin's stream controller.
  void _attachMapEvents(gmaps.GMap map) {
    map.onClick.listen((event) {
      _streamController.add(
        MapTapEvent(_mapId, _gmLatLngToLatLng(event.latLng)),
      );
    });
    map.onRightclick.listen((event) {
      _streamController.add(
        MapLongPressEvent(_mapId, _gmLatLngToLatLng(event.latLng)),
      );
    });
    map.onBoundsChanged.listen((event) {
      if (!_mapIsMoving) {
        _mapIsMoving = true;
        _streamController.add(CameraMoveStartedEvent(_mapId));
      }
      _streamController.add(
        CameraMoveEvent(_mapId, _gmViewportToCameraPosition(map)),
      );
    });
    map.onIdle.listen((event) {
      _mapIsMoving = false;
      _streamController.add(CameraIdleEvent(_mapId));
    });
  }

  // Binds the Geometry controllers to a map instance
  void _attachGeometryControllers(gmaps.GMap map) {
    // Now we can add the initial geometry.
    // And bind the (ready) map instance to the other geometry controllers.
    _circlesController.bindToMap(_mapId, map);
    _polygonsController.bindToMap(_mapId, map);
    _polylinesController.bindToMap(_mapId, map);
    _markersController.bindToMap(_mapId, map);
    _controllersBoundToMap = true;
  }

  // Renders the initial sets of geometry.
  void _renderInitialGeometry({
    Set<Marker> markers,
    Set<Circle> circles,
    Set<Polygon> polygons,
    Set<Polyline> polylines,
  }) {
    assert(
        _controllersBoundToMap,
        'Geometry controllers must be bound to a map before any geometry can ' +
            'be added to them. Ensure _attachGeometryControllers is called first.');
    _markersController.addMarkers(markers);
    _circlesController.addCircles(circles);
    _polygonsController.addPolygons(polygons);
    _polylinesController.addPolylines(polylines);
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
    final newOptions = _mergeRawOptions(optionsUpdate);

    _setOptions(_rawOptionsToGmapsOptions(newOptions));
    _setTrafficLayer(_googleMap, _isTrafficLayerEnabled(newOptions));
  }

  // Sets new [gmaps.MapOptions] on the wrapped map.
  void _setOptions(gmaps.MapOptions options) {
    _googleMap?.options = options;
  }

  // Attaches/detaches a Traffic Layer on the passed `map` if `attach` is true/false.
  void _setTrafficLayer(gmaps.GMap map, bool attach) {
    if (attach && _trafficLayer == null) {
      _trafficLayer = gmaps.TrafficLayer();
      _trafficLayer.set('map', map);
    }
    if (!attach && _trafficLayer != null) {
      _trafficLayer.set('map', null);
      _trafficLayer = null;
    }
  }

  // _googleMap manipulation
  // Viewport

  /// Returns the [LatLngBounds] of the current viewport.
  Future<LatLngBounds> getVisibleRegion() async {
    return _gmLatLngBoundsTolatLngBounds(await _googleMap.bounds);
  }

  /// Returns the [ScreenCoordinate] for a given viewport [LatLng].
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    final point =
        _googleMap.projection.fromLatLngToPoint(_latLngToGmLatLng(latLng));
    return ScreenCoordinate(x: point.x, y: point.y);
  }

  /// Returns the [LatLng] for a `screenCoordinate` (in pixels) of the viewport.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    final gmaps.LatLng latLng =
        _pixelToLatLng(_googleMap, screenCoordinate.x, screenCoordinate.y);
    return _gmLatLngToLatLng(latLng);
  }

  /// Applies a `cameraUpdate` to the current viewport.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    return _applyCameraUpdate(_googleMap, cameraUpdate);
  }

  /// Returns the zoom level of the current viewport.
  Future<double> getZoomLevel() async => _googleMap.zoom.toDouble();

  // Geometry manipulation

  /// Applies [CircleUpdates] to the currently managed circles.
  void updateCircles(CircleUpdates updates) {
    _circlesController?.addCircles(updates.circlesToAdd);
    _circlesController?.changeCircles(updates.circlesToChange);
    _circlesController?.removeCircles(updates.circleIdsToRemove);
  }

  /// Applies [PolygonUpdates] to the currently managed polygons.
  void updatePolygons(PolygonUpdates updates) {
    _polygonsController?.addPolygons(updates.polygonsToAdd);
    _polygonsController?.changePolygons(updates.polygonsToChange);
    _polygonsController?.removePolygons(updates.polygonIdsToRemove);
  }

  /// Applies [PolylineUpdates] to the currently managed lines.
  void updatePolylines(PolylineUpdates updates) {
    _polylinesController?.addPolylines(updates.polylinesToAdd);
    _polylinesController?.changePolylines(updates.polylinesToChange);
    _polylinesController?.removePolylines(updates.polylineIdsToRemove);
  }

  /// Applies [MarkerUpdates] to the currently managed markers.
  void updateMarkers(MarkerUpdates updates) {
    _markersController?.addMarkers(updates.markersToAdd);
    _markersController?.changeMarkers(updates.markersToChange);
    _markersController?.removeMarkers(updates.markerIdsToRemove);
  }

  /// Shows the [InfoWindow] of the marker identified by its [MarkerId].
  void showInfoWindow(MarkerId markerId) {
    _markersController?.showMarkerInfoWindow(markerId);
  }

  /// Hides the [InfoWindow] of the marker identified by its [MarkerId].
  void hideInfoWindow(MarkerId markerId) {
    _markersController?.hideMarkerInfoWindow(markerId);
  }

  /// Returns true if the [InfoWindow] of the marker identified by [MarkerId] is shown.
  bool isInfoWindowShown(MarkerId markerId) {
    return _markersController?.isInfoWindowShown(markerId);
  }

  // Cleanup

  /// Disposes of this controller and its resources.
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
