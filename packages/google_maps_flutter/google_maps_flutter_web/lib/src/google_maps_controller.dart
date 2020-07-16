part of google_maps_flutter_web;

///TODO
class GoogleMapController {
  ///TODO
  final int mapId;
  ///TODO
  HtmlElementView html;

  gmaps.TrafficLayer _trafficLayer;
  
  /// TODO
  gmaps.GMap googleMap;

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
    @required gmaps.MapOptions options,
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
    DivElement div = DivElement()
      ..id = 'plugins.flutter.io/google_maps_$mapId';

    // TODO: Move the comment below to analysis-options.yaml
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$mapId',
          (int viewId) => div,
    );

    googleMap = gmaps.GMap(div, options);
    onMapReady(googleMap);
    _attachMapEvents(googleMap);
  }

  void dispose() {
    html = null;
    googleMap = null;
    circlesController = null;
    polygonsController = null;
    polylinesController = null;
    markersController = null;
    streamController.close();
  }

  /// Attaches/detaches a Traffic Layer on the current googleMap.
  void setTrafficLayer(bool attach) {
    if (attach && _trafficLayer == null) {
      _trafficLayer = gmaps.TrafficLayer();
      _trafficLayer.set('map', googleMap);
      googleMap.panBy(1, 0);
      googleMap.panBy(-1, 0);
    }
    if (!attach && _trafficLayer != null) {
      _trafficLayer.set('map', null);
      _trafficLayer = null;
      googleMap.panBy(1, 0);
      googleMap.panBy(-1, 0);
    }
  }

  void _attachMapEvents(gmaps.GMap map) {
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

  void onMapReady(gmaps.GMap googleMap) {
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

  void setOptions(gmaps.MapOptions options) {
    googleMap?.options = options;
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
  gmaps.GMap googleMap;
  int mapId;
  void bindToMap(int mapId, gmaps.GMap googleMap) {
    this.mapId = mapId;
    this.googleMap = googleMap;
  }
}