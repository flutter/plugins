part of google_maps_flutter_web;

/// Encapsulates a [gmaps.GMap], its events, and where in the DOM it's rendered.
class GoogleMapController {
  // The internal ID of the map. Used to broadcast events, DOM IDs and everything where a unique ID is needed.
  final int _mapId;

  // The raw options passed by the user, before converting to gmaps.
  // Caching this allows us to re-create the map faithfully when needed.
  Map<String, dynamic> _rawOptions = {
    'options': {},
  };

  // The Flutter widget that contains the rendered Map.
  HtmlElementView _widget;
  HtmlElement _div;

  /// The Flutter widget that contains the rendered Map. Used for caching.
  HtmlElementView get widget => _widget;

  // The currently-enabled traffic layer.
  gmaps.TrafficLayer _trafficLayer;

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
    @required Map<String, dynamic> rawOptions,
  })  : this._mapId = mapId,
        this._streamController = streamController,
        this._rawOptions = rawOptions {
    _circlesController = CirclesController(stream: this._streamController);
    _polygonsController = PolygonsController(stream: this._streamController);
    _polylinesController = PolylinesController(stream: this._streamController);
    _markersController = MarkersController(stream: this._streamController);

    // Create the widget. Note that we need to "leak" the div, so it can be used
    // to build the gmaps.GMap object.
    _widget =
        HtmlElementView(viewType: 'plugins.flutter.io/google_maps_$mapId');
    _div = DivElement()..id = 'plugins.flutter.io/google_maps_$mapId';
    // TODO: Move the comment below to analysis-options.yaml
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$mapId',
      (int viewId) => _div,
    );
  }

  /// Initializes the [gmaps.GMap] instance from the stored `rawOptions`.
  void init() {
    var options = _rawOptionsToGmapsOptions(_rawOptions);
    // Initial position can only to be set here!
    options = _setInitialPosition(_rawOptions, options);

    // Create the map...
    _googleMap = gmaps.GMap(_div, options);

    _attachMapEvents(_googleMap);
    _attachGeometryControllers(_googleMap);

    _renderInitialGeometry(
      markers: _rawOptionsToInitialMarkers(_rawOptions),
      circles: _rawOptionsToInitialCircles(_rawOptions),
      polygons: _rawOptionsToInitialPolygons(_rawOptions),
      polylines: _rawOptionsToInitialPolylines(_rawOptions),
    );

    _setTrafficLayer(_isTrafficLayerEnabled(_rawOptions));
  }

  // Funnels map gmap events into the plugin's stream controller.
  void _attachMapEvents(gmaps.GMap map) {
    map.onClick.listen((event) {
      _streamController.add(
        MapTapEvent(_mapId, _gmLatlngToLatlng(event.latLng)),
      );
    });
    map.onRightclick.listen((event) {
      _streamController.add(
        MapLongPressEvent(_mapId, _gmLatlngToLatlng(event.latLng)),
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

  // Merges new options coming from the plugin into the 'options' entry of the
  // _rawOptions map.
  // Returns the updated _rawOptions object.
  Map<String, dynamic> _mergeRawOptions(Map<String, dynamic> newOptions) {
    _rawOptions['options'] = <String, dynamic>{
      ..._rawOptions['options'],
      ...newOptions,
    };
    return _rawOptions;
  }

  /// Updates the map options from a `Map<String, dynamic>`.
  ///
  /// This method converts the map into the proper [gmaps.MapOptions]
  void updateRawOptions(Map<String, dynamic> optionsUpdate) {
    final newOptions = _mergeRawOptions(optionsUpdate);

    _setOptions(_rawOptionsToGmapsOptions(newOptions));
    _setTrafficLayer(_isTrafficLayerEnabled(newOptions));
  }

  /// Sets new [gmaps.MapOptions] on the wrapped map.
  void _setOptions(gmaps.MapOptions options) {
    _googleMap?.options = options;
  }

  /// Attaches/detaches a Traffic Layer on the current googleMap.
  void _setTrafficLayer(bool attach) {
    if (attach && _trafficLayer == null) {
      _trafficLayer = gmaps.TrafficLayer();
      _trafficLayer.set('map', _googleMap);
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
        _googleMap.projection.fromLatLngToPoint(_latlngToGmLatlng(latLng));
    return ScreenCoordinate(x: point.x, y: point.y);
  }

  /// Returns the [LatLng] for a `screenCoordinate` (in pixels) of the viewport.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    final latLng = _googleMap.projection.fromPointToLatLng(
      gmaps.Point(screenCoordinate.x, screenCoordinate.y),
    );
    return _gmLatlngToLatlng(latLng);
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
  Future<bool> isInfoWindowShown(MarkerId markerId) async {
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

/// The base class for all "geometry" controllers.
///
/// This lets all Geometry controllers be bound to a given mapID and GMap.
abstract class AbstractController {
  /// The GMap instance that this controller operates on.
  gmaps.GMap googleMap;

  /// The map ID for events.
  int mapId;

  /// Binds a mapId and its instance to this controller.
  void bindToMap(int mapId, gmaps.GMap googleMap) {
    this.mapId = mapId;
    this.googleMap = googleMap;
  }
}
