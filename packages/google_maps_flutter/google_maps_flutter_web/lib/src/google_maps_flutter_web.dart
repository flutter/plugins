part of google_maps_flutter_web;

/// The web implementation of [GoogleMapsFlutterPlatform].
///
/// This class implements the `package:google_maps_flutter` functionality for the web.
class GoogleMapsPlugin extends GoogleMapsFlutterPlatform {

  /// Registers this class as the default instance of [GoogleMapsFlutterPlatform].
  static void registerWith(Registrar registrar) {
    GoogleMapsFlutterPlatform.instance = GoogleMapsPlugin();
  }

  // This is a cache of rendered maps <-> GoogleMapControllers
  Map _mapById = Map<int, GoogleMapController>();
  Map _optionsById = Map<int, Map<String, dynamic>>();

  final StreamController<MapEvent> _controller =
  StreamController<MapEvent>.broadcast();

  Stream<MapEvent> _events(int mapId) =>
      _controller.stream.where((event) => event.mapId == mapId);

  @override
  Future<void> init(int mapId) async {
    /* Noop */
  }

  // Updates the cache of map options for a given mapId, so we can 
  // recrate the gmaps.MapOptions object from scratch.
  Map<String, dynamic> _mergeRawMapOptions(dynamic newOptions, int mapId) {
    _optionsById[mapId] = <String, dynamic>{
      ..._optionsById[mapId] ?? {},
      ...newOptions,
    };
    return _optionsById[mapId];
  }

  @override
  Future<void> updateMapOptions(
      Map<String, dynamic> optionsUpdate, {
        @required int mapId,
      }) async {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      googleMapController.setOptions(
        _optionsFromParams(
          _mergeRawMapOptions(optionsUpdate, mapId),
        ),
      );
    } else {
      throw StateError("updateMapOptions called prior to map initialization");
    }
  }

  @override
  Future<void> updateMarkers(
      MarkerUpdates markerUpdates, {
        @required int mapId,
      }) async {
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
      }) async {
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
      }) async {
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
      }) async {
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
      }) async {
    return moveCamera(cameraUpdate, mapId: mapId);
  }

  @override
  Future<void> moveCamera(
      CameraUpdate cameraUpdate, {
        @required int mapId,
      }) async {

    GoogleMapController googleMapController = _mapById[mapId];
    if (googleMapController == null) {
      return null;
    }

    gmaps.GMap map = googleMapController.googleMap;
    // TODO: Subclass CameraUpdate so the below code is not so stringly-typed?
    dynamic json = cameraUpdate.toJson();

    switch (json[0]) {
      case 'newCameraPosition':
        map.heading = json[1]['bearing'];
        map.zoom = json[1]['zoom'];
        map.panTo(gmaps.LatLng(json[1]['target'][0], json[1]['target'][1]));
        map.tilt = json[1]['tilt'];
        break;
      case 'newLatLng':
        map.panTo(gmaps.LatLng(json[1][0], json[1][1]));
        break;
      case 'newLatLngZoom':
        map.zoom = json[2];
        map.panTo(gmaps.LatLng(json[1][0], json[1][1]));
        break;
      case 'newLatLngBounds':
        map.fitBounds(gmaps.LatLngBounds(
          gmaps.LatLng(json[1][0][0],json[1][0][1]),
          gmaps.LatLng(json[1][1][0],json[1][1][1])
        ));
        // padding = json[2];
        // Needs package:google_maps ^4.0.0 to adjust the padding in fitBounds
        break;
      case 'scrollBy':
        map.panBy(json[1], json[2]);
        break;
      case 'zoomBy':
        double zoomDelta = json[1] ?? 0;
        // Web only supports integer changes...
        int newZoomDelta = zoomDelta < 0 ? zoomDelta.floor() : zoomDelta.ceil();
        map.zoom = map.zoom + newZoomDelta;
        if (json.length == 3) {
          // With focus
          map.panTo(gmaps.LatLng(json[2][0], json[2][1]));
        }
        break;
      case 'zoomIn':
        map.zoom++;
        break;
      case 'zoomOut':
        map.zoom--;
        break;
      case 'zoomTo':
        map.zoom = json[1];
        break;
      default:
        throw UnimplementedError('moveCamera() does not implement: ${json[0]}.');
    }
  }

  @override
  Future<void> setMapStyle(
      String mapStyle, {
        @required int mapId,
      }) async {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      googleMapController.setOptions(
        _optionsFromParams(_mergeRawMapOptions({
          'styles': _mapStyles(mapStyle),
        }, mapId)),
      );
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    @required int mapId,
  }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if(googleMapController != null) {
      gmaps.LatLngBounds latLngBounds = googleMapController.googleMap
          .bounds;
      if(latLngBounds != null) {
        return Future.value(_gmLatLngBoundsTolatLngBounds(latLngBounds));
      }
    }
    return Future.value(LatLngBounds(southwest: LatLng(0,0),northeast:LatLng(0,0) ));
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
      LatLng latLng, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    if (googleMapController != null) {
      gmaps.Point point = googleMapController.googleMap.projection
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
      gmaps.LatLng latLng = googleMapController.googleMap.projection.fromPointToLatLng(
        gmaps.Point(screenCoordinate.x, screenCoordinate.y)
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
      }) async {
    GoogleMapController googleMapController = _mapById[mapId];
    googleMapController.markersController.showMarkerInfoWindow(markerId);
  }

  @override
  Future<void> hideMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) async {
    GoogleMapController googleMapController = _mapById[mapId];
    googleMapController.markersController.hideMarkerInfoWindow(markerId);
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
      MarkerId markerId, {
        @required int mapId,
      }) {
    GoogleMapController googleMapController = _mapById[mapId];
    return Future.value(
        googleMapController.markersController.isInfoWindowShown(markerId)
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
        gmaps.snapshot(
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

  // TODO: Make this method part of the interface!
  void dispose({@required int mapId}) {
    _mapById[mapId]?.dispose();
    _mapById.remove(mapId);
    _optionsById.remove(mapId);
  }

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {

    int mapId = creationParams['creationMapId'];
    creationParams.remove('creationMapId');

    if (mapId == null) {
      throw PlatformException(code: 'maps_web_missing_creation_map_id', message: 'Pass a `creationMapId` in creationParams to prevent reloads in web.',);
    }

    Map<String, dynamic> mergedRawOptions;

    // Merge the raw options now, so we can adjust the traffic layer on the cached controller, if needed.
    if (creationParams['options'] != null) {
      mergedRawOptions = _mergeRawMapOptions(creationParams['options'], mapId);
    }

    if (_mapById[mapId]?.html != null) {
      // TODO: Toggling the traffic layer here needs a repaint that isn't happening.
      // How to achieve that?
      // _mapById[mapId].setTrafficLayer(mergedRawOptions['trafficEnabled'] ?? false);
      return _mapById[mapId].html;
    }


    gmaps.MapOptions options = gmaps.MapOptions();
    CameraPosition position;

    CircleUpdates     initialCircles;
    PolygonUpdates    initialPolygons;
    PolylineUpdates   initialPolylines;
    MarkerUpdates     initialMarkers;

    creationParams.forEach((key, value) {
      if(key == 'options')    {
        _optionsFromParams(mergedRawOptions, existingOptions: options);
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
        options.center = gmaps.LatLng(
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
          initialCircles: initialCircles?.circlesToAdd,
          initialPolygons: initialPolygons?.polygonsToAdd,
          initialPolylines: initialPolylines?.polylinesToAdd,
          initialMarkers: initialMarkers?.markersToAdd,
        );

    onPlatformViewCreated.call(mapId);

    // TODO: Enable layer support, once toggling works.
    // _mapById[mapId].setTrafficLayer(mergedRawOptions['trafficEnabled'] ?? false);

    return _mapById[mapId].html;
  }
}
