part of google_maps_flutter_web;

PolylineUpdates _polylineFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Polyline> current = Set<Polyline>();
    list.forEach((polyline) {
      PolylineId polylineId = PolylineId(polyline['polylineId']);
      List<LatLng> points = [];
      List<dynamic> jsonPoints = polyline['points'];
      jsonPoints.forEach((p) {
        points.add(LatLng.fromJson(p));
      });
      current.add(
          Polyline(
            polylineId: polylineId,
            consumeTapEvents: polyline['consumeTapEvents'],
            color: Color(polyline['color']),
            geodesic: polyline['geodesic'],
            visible: polyline['visible'],
            zIndex: polyline['zIndex'],
            width: polyline['width'],
            points: points,
//            endCap = Cap.buttCap,
//            jointType = JointType.mitered,
//            patterns = const <PatternItem>[],
//            startCap = Cap.buttCap,
          )
      );
    });
    return PolylineUpdates.from(null, current);
  }
  return null;
}

GoogleMap.PolylineOptions _polylineOptionsFromPolyline(GoogleMap.GMap googleMap,
    Polyline polyline) {
  List<GoogleMap.LatLng> paths = [];
  polyline.points.forEach((point) {
    paths.add(GoogleMap.LatLng(point.latitude, point.longitude));
  });
  return GoogleMap.PolylineOptions()
    ..path = paths
    ..strokeOpacity = 1.0
    ..strokeWeight = polyline.width
    ..strokeColor = '#'+polyline.color.value.toRadixString(16)
    ..visible = polyline.visible
    ..zIndex = polyline.zIndex
    ..geodesic = polyline.geodesic
  ;
}

class PolylineController {

  GoogleMap.Polyline _polyline;
  bool consumeTapEvents = false;
  ui.VoidCallback ontab;

  ///
  PolylineController({
    @required GoogleMap.Polyline polyline,
    bool consumeTapEvents,
    this.ontab
  }){
    _polyline = polyline;
    if(consumeTapEvents) {
      polyline.onClick.listen((event) {
        if(ontab !=null) ontab.call();
      });
    }
  }


  set polyline (GoogleMap.Polyline polyline) => {_polyline = polyline};

  void update(GoogleMap.PolylineOptions options) {
    _polyline.options = options;
  }

  void remove() {
    _polyline.visible = false;
    _polyline.map = null;
    _polyline = null;
    //_polyline.remove();
  }
}