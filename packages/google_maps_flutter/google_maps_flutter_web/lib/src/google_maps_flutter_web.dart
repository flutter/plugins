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

  // This is a cache of rendered maps <-> GoogleMapControllers
  HashMap _mapById = HashMap<int, GoogleMapController>();

  final StreamController<MapEvent> _controller =
  StreamController<MapEvent>.broadcast();

  Stream<MapEvent> _events(int mapId) =>
      _controller.stream.where((event) => event.mapId == mapId);

  @override
  Future<void> init(int mapId) async {
    /* Noop */
  }

  @override
  Future<void> updateMapOptions(
      Map<String, dynamic> optionsUpdate, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      _optionsFromParams(googleMapController.options, optionsUpdate);
    } else {
      throw StateError("updateMapOptions called prior to map initialization");
    }
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
    moveCamera(cameraUpdate, mapId: mapId);
  }


  @override
  Future<void> moveCamera(
      CameraUpdate cameraUpdate, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      GoogleMap.GMap map = googleMapController.googleMap;
      dynamic json = cameraUpdate.toJson();
      print(json);
      if('newLatLng' == json[0]
      || 'newLatLngZoom' == json[0]) {
        map.panTo(GoogleMap.LatLng(json[1][0],json[1][1]));
      } else if('newLatLngBounds' == json[0]) {
        map.panToBounds(GoogleMap.LatLngBounds(
            GoogleMap.LatLng(json[1][0][0],json[1][0][1]),
            GoogleMap.LatLng(json[1][1][0],json[1][1][1])
        ));
      } else {
        throw UnimplementedError(json[0]+' has not been implemented.');
      }
    }
//    try { throw Error();  } catch (error, stacktrace) { print(stacktrace.toString());  }
//    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  @override
  Future<void> setMapStyle(
      String mapStyle, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      googleMapController.options.styles = _mapStyles(mapStyle);
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    @required int mapId,
  }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      GoogleMap.LatLngBounds latLngBounds = googleMapController.googleMap
          .bounds;
      if(latLngBounds != null) {
        return Future.value(_gmLatLngBoundsTolatLngBounds(latLngBounds));
      }
    }
//    try { throw Error();  } catch (error, stacktrace) { print(stacktrace.toString());  }
//    return Future.error(
//        StateError("getVisibleRegion called prior to map initialization")
//    );
    return Future.value(LatLngBounds(southwest: LatLng(0,0),northeast:LatLng(0,0) ));
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
      LatLng latLng, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if (googleMapController != null) {
      GoogleMap.Point point = googleMapController.googleMap.projection
          .fromLatLngToPoint(_latlngToGmLatlng(latLng));
      return Future.value(ScreenCoordinate(x: point.x, y: point.y));
    }
    return Future.error(
        StateError("getScreenCoordinate called prior to map initialization")
    );
  }

  @override
  Future<LatLng> getLatLng(
      ScreenCoordinate screenCoordinate, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      GoogleMap.LatLng latLng = googleMapController.googleMap.projection.fromPointToLatLng(
        GoogleMap.Point(screenCoordinate.x, screenCoordinate.y)
      );
      return Future.value(_gmLatlngToLatlng(latLng));
    }
    return Future.error(
        StateError("getLatLng called prior to map initialization")
    );
  }

  @override
  Future<void> showMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    googleMapController.markersController.showMarkerInfoWindow(
        markerId.value.toString()
    );
  }

  @override
  Future<void> hideMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    googleMapController.markersController.hideMarkerInfoWindow(
        markerId.value.toString()
    );
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
      MarkerId markerId, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    return Future.value(
        googleMapController.markersController.isInfoWindowShown(
            markerId.value.toString()
        )
    );
  }

  @override
  Future<double> getZoomLevel({
    @required int mapId,
  }) {
    GoogleMapController googleMapController = _mapById[mapId];
    return Future.value(googleMapController.googleMap.zoom.toDouble());
  }

  @override
  Future<Uint8List> takeSnapshot({
    @required int mapId,
  }) {
    throw UnimplementedError('takeSnapshot() has not been implemented.');
    /**takeSnapshot
     *  if (googleMap != null) {
        final MethodChannel.Result _result = result;
        googleMap.snapshot(
        new SnapshotReadyCallback() {
        @Override
        public void onSnapshotReady(Bitmap bitmap) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
        byte[] byteArray = stream.toByteArray();
        bitmap.recycle();
        _result.success(byteArray);
        }
        });
        } else {
        result.error("GoogleMap uninitialized", "takeSnapshot", null);
        }
     */
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

  // TODO: Add a new dispose(int mapId) method to clear the cache of Controllers
  // that the `buildView` method is creating!

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {

    int mapId = creationParams['creationMapId'];

    if (mapId == null) {
      throw PlatformException(code: 'maps_web_missing_creation_map_id', message: 'Pass a `creationMapId` in creationParams to prevent reloads in web.',);
    }

    if (_mapById[mapId]?.html != null) {
      print('Map ID $mapId already exists, returning cached...');
      return _mapById[mapId].html;
    }

    creationParams.remove('creationMapId');

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

    _mapById[mapId] =
        GoogleMapController.build(
          mapId: mapId,
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


    /** trafficEnabled
     * var trafficLayer = new google.maps.TrafficLayer();
        trafficLayer.setMap(map);
     */


//    try {throw Error();  } catch (error, stacktrace) { print(stacktrace.toString());  }
    onPlatformViewCreated.call(mapId);

    return _mapById[mapId].html;
  }
}
