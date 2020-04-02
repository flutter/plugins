part of google_maps_flutter_web;

PolygonUpdates _polygonFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Polygon> current = Set<Polygon>();
    list.forEach((polygon) {
      PolygonId polygonId = PolygonId(polygon['polygonId']);
      List<LatLng> points = [];
      List<dynamic> jsonPoints = polygon['points'];
      jsonPoints.forEach((p) {
        points.add(LatLng.fromJson(p));
      });
      current.add(
          Polygon(
            polygonId: polygonId,
            consumeTapEvents: polygon['consumeTapEvents'],
            fillColor: Color(polygon['fillColor']),
            geodesic: polygon['geodesic'],
            strokeColor: Color(polygon['strokeColor']),
            strokeWidth: polygon['strokeWidth'],
            visible: polygon['visible'],
            zIndex: polygon['zIndex'],
            points: points,
          )
      );
    });
    return PolygonUpdates.from(null, current);
  }
  return null;
}

GoogleMap.PolygonOptions _polygonOptionsFromPolygon(GoogleMap.GMap googleMap,
    Polygon polygon) {
  List<GoogleMap.LatLng> paths = [];
  polygon.points.forEach((point) {
    paths.add(GoogleMap.LatLng(point.latitude, point.longitude));
  });
  return GoogleMap.PolygonOptions()
    ..paths = paths
    ..strokeColor = '#'+polygon.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = polygon.strokeWidth
    ..fillColor = '#'+polygon.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.35
    ..visible = polygon.visible
    ..zIndex = polygon.zIndex
    ..geodesic = polygon.geodesic
  ;
}


///
class PolygonController {

  GoogleMap.Polygon _polygon;
  bool consumeTapEvents = false;
  ui.VoidCallback ontab;

  ///
  PolygonController({
    @required GoogleMap.Polygon polygon,
    bool consumeTapEvents,
    this.ontab
  }){
    _polygon = polygon;
    if(consumeTapEvents) {
      polygon.onClick.listen((event) {
        if(ontab !=null) ontab.call();
      });
    }
  }


  set polygon (GoogleMap.Polygon polygon) => {_polygon = polygon};

  void update(GoogleMap.PolygonOptions options) {
    _polygon.options = options;
  }

  void remove() {
    _polygon.visible = false;
    _polygon.map = null;
    _polygon = null;
    //_polygon.remove();
  }
}