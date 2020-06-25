part of google_maps_flutter_web;

///TODO
class GoogleMapController {
  ///TODO
  final int mapId;
  ///TODO
  HtmlElementView html;
  ///TODO
  GoogleMap.GMap googleMap;
  ///TODO
  DivElement div;
  ///TODO
  final GoogleMap.MapOptions        options;
  final StreamController<MapEvent>  streamController;
  CameraPosition                    position;
  CirclesController                 circlesController;
  PolygonsController                polygonsController;
  PolylinesController               polylinesController;
  MarkersController               markersController;


  Set<Circle>     initialCircles;
  Set<Polygon>    initialPolygons;
  Set<Polyline>   initialPolylines;
  Set<Marker>     initialMarkers;

  bool _mapIsMoving = false;

  ///TODO
  GoogleMapController.build({
    @required this.mapId,
    @required this.streamController,
    @required this.options,
    @required this.position,
    @required onPlatformViewCreated,
    @required this.initialCircles,
    @required this.initialPolygons,
    @required this.initialPolylines,
    @required this.initialMarkers,
  }) {
    circlesController = CirclesController(stream: this.streamController);
    polygonsController = PolygonsController(stream: this.streamController);
    polylinesController = PolylinesController(stream: this.streamController);
    markersController = MarkersController(stream: this.streamController);
    html = HtmlElementView(
        viewType: 'plugins.flutter.io/google_maps_$mapId'
    );
//    onPlatformViewCreated.call(mapId);
    div = DivElement()
      ..id = 'plugins.flutter.io/google_maps_$mapId'
    ;
    // TODO: Move the comment below to analysis-options.yaml
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$mapId',
          (int viewId) => div,
    );
    googleMap = GoogleMap.GMap(div, options);
    onMapReady(googleMap);
    _attachMapEvents(googleMap);
  }

  void _attachMapEvents(GoogleMap.GMap map) {
    map.onClick.listen((event) {
      streamController.add(
          MapTapEvent(mapId, _gmLatlngToLatlng(event.latLng)),);
    });
    map.onRightclick.listen((event) {
      streamController.add(
          MapLongPressEvent(mapId, _gmLatlngToLatlng(event.latLng)),);
    });
    map.onBoundsChanged.listen((event) {
      if (!_mapIsMoving) {
        _mapIsMoving = true;
        streamController.add(CameraMoveStartedEvent(mapId));
      }
      streamController.add(CameraMoveEvent(mapId, _gmViewportToCameraPosition(map)),);
    });
    map.onIdle.listen((event) {
      _mapIsMoving = false;
      streamController.add(CameraIdleEvent(mapId));
    });
  }

  void onMapReady(GoogleMap.GMap googleMap) {
    this.googleMap = googleMap;
    // Bind map instance to the other geometry controllers.
    circlesController.bindToMap(mapId, googleMap);
    polygonsController.bindToMap(mapId, googleMap);
    polylinesController.bindToMap(mapId, googleMap);
    markersController.bindToMap(mapId, googleMap);
    updateInitialCircles();
    updateInitialPolygons();
    updateInitialPolylines();
    updateInitialMarkers();
  }

  void setInitialCircles(Set<Circle> initialCircles) {
    this.initialCircles = initialCircles;
    if (googleMap != null) {
      updateInitialCircles();
    }
  }

  void updateInitialCircles() {
    if(initialCircles == null) return;
    circlesController.addCircles(initialCircles);
  }

  void setInitialPolygons(Set<Polygon> initialPolygons) {
    this.initialPolygons = initialPolygons;
    if (googleMap != null) {
      updateInitialPolygons();
    }
  }

  void setInitialPolylines(Set<Polyline> initialPolylines) {
    this.initialPolylines = initialPolylines;
    if (googleMap != null) {
      updateInitialPolylines();
    }
  }

  void setInitialMarkers(Set<Marker> initialMarkers) {
    this.initialMarkers = initialMarkers;
    if (googleMap != null) {
      updateInitialMarkers();
    }
  }

  void updateInitialPolygons() {
    if(initialPolygons == null) return;
    polygonsController.addPolygons(initialPolygons);
  }

  void updateInitialPolylines() {
    if(initialPolylines == null) return;
    polylinesController.addPolylines(initialPolylines);
  }

  void updateInitialMarkers() {
    if(initialMarkers == null) return;
    markersController.addMarkers(initialMarkers);
  }
}

abstract class AbstractController {
  GoogleMap.GMap googleMap;
  int mapId;
  void bindToMap(int mapId, GoogleMap.GMap googleMap) {
    this.mapId = mapId;
    this.googleMap = googleMap;
  }
}