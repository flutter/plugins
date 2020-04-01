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
  final GoogleMap.MapOptions options;

  CameraPosition position;


  CirclesController circlesController;

  Set<Circle> initialCircles;

  final StreamController<MapEvent> streamController;

  ///TODO
  GoogleMapController.build({
    @required this.mapId,
    @required this.streamController,
    @required this.options,
    @required this.position,
    @required this.initialCircles, onPlatformViewCreated,
  }) {
    circlesController = CirclesController(googleMapController: this);
    html = HtmlElementView(
        viewType: 'plugins.flutter.io/google_maps_$mapId'
    );
    onPlatformViewCreated.call(mapId);
    div = DivElement()
      ..id = 'plugins.flutter.io/google_maps_$mapId'
    ;
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$mapId',
          (int viewId) => div,
    );

    googleMap = GoogleMap.GMap(div, options);

    onMapReady(googleMap);
    setInitialCircles(initialCircles);
    
  }

  void updateInitialCircles() {
    if(initialCircles == null) return;
    circlesController.addCircles(initialCircles);
  }

  void onMapReady(GoogleMap.GMap googleMap) {
    this.googleMap = googleMap;
    //set googlemap listener
    circlesController.setGoogleMap(googleMap);
    updateInitialCircles();
  }

  void setInitialCircles(Set<Circle> initialCircles) {
    this.initialCircles = initialCircles;
    if (googleMap != null) {
      updateInitialCircles();
    }
  }

  void onCircleTap(CircleId circleId) {
    streamController.add(CircleTapEvent(mapId, circleId));
  }
}

