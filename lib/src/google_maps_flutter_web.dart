part of google_maps_flutter_web;

/// The web implementation of [GoogleMapsFlutterPlatform].
///
/// This class implements the `package:google_maps_flutter` functionality for the web.
class GoogleMapsPlugin extends GoogleMapsFlutterPlatform {

  /// Registers this class as the default instance of [GoogleMapsFlutterPlatform].
  static void registerWith(Registrar registrar) {
    GoogleMapsFlutterPlatform.instance = GoogleMapsPlugin();
  }

  static Future<String> get platformVersion async {
    return "1.0";
  }

  int _id = 0 ;
  HashMap _mapById = HashMap<int, GoogleMapController>();
  final StreamController<MapEvent> _controller =
  StreamController<MapEvent>.broadcast();

  Stream<MapEvent> _events(int mapId) =>
      _controller.stream.where((event) => event.mapId == mapId);

  @override
  Future<void> init(int mapId) {
    mapId = _id;
    print('init $mapId');
//    throw Exception('>>');
  }

  @override
  Future<void> updateMapOptions(
      Map<String, dynamic> optionsUpdate, {
        @required int mapId,
      }) {
    print('mapId:$mapId');
//    _mapById[mapId].googleMap.options(options);
//    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  @override
  Future<void> updateMarkers(
      MarkerUpdates markerUpdates, {
        @required int mapId,
      }) {
    _mapById[mapId].markersController
        .addMarkers(markerUpdates.markersToAdd);
    _mapById[mapId].markersController
        .changeMarkers(markerUpdates.markersToChange);
    _mapById[mapId].markersController
        .removeMarkers(markerUpdates.markerIdsToRemove);
  }

  @override
  Future<void> updatePolygons(
      PolygonUpdates polygonUpdates, {
        @required int mapId,
      }) {
    _mapById[mapId].polygonsController
        .addPolygons(polygonUpdates.polygonsToAdd);
    _mapById[mapId].polygonsController
        .changePolygons(polygonUpdates.polygonsToChange);
    _mapById[mapId].polygonsController
        .removePolygons(polygonUpdates.polygonIdsToRemove);
  }

  @override
  Future<void> updatePolylines(
      PolylineUpdates polylineUpdates, {
        @required int mapId,
      }) {
    _mapById[mapId].polylinesController
        .addPolylines(polylineUpdates.polylinesToAdd);
    _mapById[mapId].polylinesController
        .changePolylines(polylineUpdates.polylinesToChange);
    _mapById[mapId].polylinesController
        .removePolylines(polylineUpdates.polylineIdsToRemove);
  }

  @override
  Future<void> updateCircles(
      CircleUpdates circleUpdates, {
        @required int mapId,
      }) {
    _mapById[mapId].circlesController
        .addCircles(circleUpdates.circlesToAdd);
    _mapById[mapId].circlesController
        .changeCircles(circleUpdates.circlesToChange);
    _mapById[mapId].circlesController
        .removeCircles(circleUpdates.circleIdsToRemove);
  }

  @override
  Future<void> animateCamera(
      CameraUpdate cameraUpdate, {
        @required int mapId,
      }) {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  @override
  Future<void> moveCamera(
      CameraUpdate cameraUpdate, {
        @required int mapId,
      }) {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  @override
  Future<void> setMapStyle(
      String mapStyle, {
        @required int mapId,
      }) {
    throw UnimplementedError('setMapStyle() has not been implemented.');
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    @required int mapId,
  }) {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
      LatLng latLng, {
        @required int mapId,
      }) {
    throw UnimplementedError('getScreenCoordinate() has not been implemented.');
  }

  @override
  Future<LatLng> getLatLng(
      ScreenCoordinate screenCoordinate, {
        @required int mapId,
      }) {
    throw UnimplementedError('getLatLng() has not been implemented.');
  }

  @override
  Future<void> showMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) {
    throw UnimplementedError(   'showMarkerInfoWindow() has not been implemented.');
  }

  @override
  Future<void> hideMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) {
    throw UnimplementedError(    'hideMarkerInfoWindow() has not been implemented.');
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
      MarkerId markerId, {
        @required int mapId,
      }) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  @override
  Future<double> getZoomLevel({
    @required int mapId,
  }) {
    throw UnimplementedError('getZoomLevel() has not been implemented.');
  }

  // The following are the 11 possible streams of data from the native side
  // into the plugin

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({@required int mapId}) {
    return _events(mapId).whereType<CameraMoveStartedEvent>();
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({@required int mapId}) {
    return _events(mapId).whereType<CameraMoveEvent>();
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({@required int mapId}) {
    return _events(mapId).whereType<CameraIdleEvent>();
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({@required int mapId}) {
    return _events(mapId).whereType<MarkerTapEvent>();
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({@required int mapId}) {
    return _events(mapId).whereType<InfoWindowTapEvent>();
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({@required int mapId}) {
    return _events(mapId).whereType<MarkerDragEndEvent>();
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({@required int mapId}) {
    return _events(mapId).whereType<PolylineTapEvent>();
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({@required int mapId}) {
    return _events(mapId).whereType<PolygonTapEvent>();
  }

  @override
  Stream<CircleTapEvent> onCircleTap({@required int mapId}) {
    return _events(mapId).whereType<CircleTapEvent>();
  }

  @override
  Stream<MapTapEvent> onTap({@required int mapId}) {
    return _events(mapId).whereType<MapTapEvent>();
  }

  @override
  Stream<MapLongPressEvent> onLongPress({@required int mapId}) {
    return _events(mapId).whereType<MapLongPressEvent>();
  }

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {
    GoogleMap.MapOptions options = GoogleMap.MapOptions();
    CameraPosition position;

    CircleUpdates     initialCircles    = null;
    PolygonUpdates    initialPolygons   = null;
    PolylineUpdates   initialPolylines  = null;
    MarkerUpdates     initialMarkers    = null;

    creationParams.forEach((key, value) {
      if(key == 'options')    {
        _optionsFromParams(options, value);
      } else if(key == 'markersToAdd') {
        initialMarkers = _markerFromParams(value);
      } else if(key == 'polygonsToAdd') {
        initialPolygons = _polygonFromParams(value);
      } else if(key == 'polylinesToAdd') {
        initialPolylines = _polylineFromParams(value);
      } else if(key == 'circlesToAdd') {
        initialCircles = _circleFromParams(value);
      } else if(key == 'initialCameraPosition') {
        position = CameraPosition.fromMap(value);
        options.zoom = position.zoom;
        options.center = GoogleMap.LatLng(
            position.target.latitude,
            position.target.longitude
        );
      } else {
        print('un-handle >>$key');
      }
    });



      _mapById[_id] =
          GoogleMapController.build(
            mapId: _id,
            streamController: _controller,
            onPlatformViewCreated: onPlatformViewCreated,
            options: options,
            position: position,
            initialCircles: initialCircles != null
                ? initialCircles.circlesToAdd
                : null,
            initialPolygons: initialPolygons != null ? initialPolygons
                .polygonsToAdd : null,
            initialPolylines: initialPolylines != null ? initialPolylines
                .polylinesToAdd : null,
            initialMarkers: initialMarkers != null ? initialMarkers
                .markersToAdd : null,
          )
      ;
    onPlatformViewCreated.call(_id);
      ///TODO not create redundent view.
    return _mapById[_id++].html;
  }
}

