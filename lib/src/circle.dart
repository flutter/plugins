part of google_maps_flutter_web;

GoogleMap.CircleOptions _circleOptionsFromCircle(Circle circle) {
  final populationOptions = GoogleMap.CircleOptions()
    ..strokeColor = '#'+circle.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = circle.strokeWidth
    ..fillColor = '#'+circle.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.6
    ..center = GoogleMap.LatLng(circle.center.latitude,circle.center.longitude)
    ..radius = circle.radius
    ..visible = circle.visible
  ;
  return populationOptions;
}

CircleUpdates _circleFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Circle> current = Set<Circle>();
    list.forEach((circle) {
      CircleId circleId = CircleId(circle['circleId']);
      current.add(
          Circle(
              circleId: circleId,
              consumeTapEvents: circle['consumeTapEvents'],
              fillColor: Color(circle['fillColor']),
              center: LatLng.fromJson(circle['center']),
              radius: circle['radius'],
              strokeColor: Color(circle['strokeColor']),
              strokeWidth: circle['strokeWidth'],
              visible: circle['visible'],
              zIndex: circle['zIndex'],
          )
      );
    });
    return CircleUpdates.from(null, current);
  }
  return null;
}

///
class CircleController {

   GoogleMap.Circle _circle;

  bool consumeTapEvents = false;

  ui.VoidCallback ontab;

  ///
  CircleController({@required GoogleMap.Circle circle, this.consumeTapEvents, this.ontab}){
    _circle = circle;
   if(consumeTapEvents) {
     circle.onClick.listen((event) {
       if(ontab !=null) ontab.call();
     });
   }
  }

  set circle (GoogleMap.Circle circle) => {_circle = circle};

  ///TODO
  void update(GoogleMap.CircleOptions options) {
    _circle.options = options;
  }

  void remove() {
    _circle.visible = false;
    _circle.radius = 0;
    _circle.map = null;
    _circle = null;
    //_circle.remove();
  }
}