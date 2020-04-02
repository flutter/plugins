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
    circlesController = CirclesController(googleMapController: this);
    polygonsController = PolygonsController(googleMapController: this);
    polylinesController = PolylinesController(googleMapController: this);
    markersController = MarkersController(googleMapController: this);
    html = HtmlElementView(
        viewType: 'plugins.flutter.io/google_maps_$mapId'
    );
//    onPlatformViewCreated.call(mapId);
    div = DivElement()
      ..id = 'plugins.flutter.io/google_maps_$mapId'
    ;
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$mapId',
          (int viewId) => div,
    );
    googleMap = GoogleMap.GMap(div, options);
    onMapReady(googleMap);

  }

  void onMapReady(GoogleMap.GMap googleMap) {
    this.googleMap = googleMap;
    //set googlemap listener
    circlesController.setGoogleMap(googleMap);
    polygonsController.setGoogleMap(googleMap);
    polylinesController.setGoogleMap(googleMap);
    markersController.setGoogleMap(googleMap);
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

  void onCircleTap(CircleId circleId) {
    streamController.add(CircleTapEvent(mapId, circleId));
  }

  void onPolygonTap(PolygonId polygonId) {
    streamController.add(PolygonTapEvent(mapId, polygonId));
  }

  void onPolylineTap(PolylineId polylineId) {
    streamController.add(PolylineTapEvent(mapId, polylineId));
  }

  void onMarkerTap(MarkerId markerId) {
    streamController.add(MarkerTapEvent(mapId, markerId));
  }
}

abstract class AbstractController {
  GoogleMap.GMap googleMap;
  void setGoogleMap(GoogleMap.GMap googleMap) {
    this.googleMap = googleMap;
  }
}