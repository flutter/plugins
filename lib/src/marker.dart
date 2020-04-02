part of google_maps_flutter_web;

MarkerUpdates _markerFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Marker> current = Set<Marker>();
    list.forEach((marker) {
      MarkerId markerId = MarkerId(marker['markerId']);
      Offset offset = Offset(
          (marker['anchor'][0]),
          (marker['anchor'][1]));
      current.add(
          Marker(
            markerId: markerId,
            alpha: marker['alpha'],
            anchor: offset,
            consumeTapEvents: marker['consumeTapEvents'],
            draggable: marker['draggable'],
            flat:  marker['flat'],
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: marker['infoWindow']['title'] ?? '',
              snippet: marker['snippet'],
              anchor : offset,
            ),
            position: LatLng.fromJson(marker['position']),
            rotation: marker['rotation'],
            visible: marker['visible'],
            zIndex: marker['zIndex'],
          )
      );
    });
    return MarkerUpdates.from(null, current);
  }
  return null;
}

GoogleMap.MarkerOptions _markerOptionsFromMarker(GoogleMap.GMap googleMap,
    Marker marker) {

  final goldStar = GoogleMap.GSymbol()
    ..path =
        'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z'
    ..fillColor = 'yellow'
    ..fillOpacity = 0.8
    ..scale = 1
    ..strokeColor = 'gold'
    ..strokeWeight = 14;

  return GoogleMap.MarkerOptions()
    ..position = GoogleMap.LatLng(marker.position.latitude,
        marker.position.longitude)
    ..title = marker.infoWindow.title
    ..icon = goldStar
  ///TODO
  ;
}

class MarkerController {

  GoogleMap.Marker _marker;
  bool consumeTapEvents = false;
  ui.VoidCallback ontab;

  ///
  MarkerController({
    @required GoogleMap.Marker marker,
    bool consumeTapEvents,
    this.ontab
  }){
    _marker = marker;
    if(consumeTapEvents) {
      marker.onClick.listen((event) {
        if(ontab !=null) ontab.call();
      });
    }
  }


  set marker (GoogleMap.Marker marker) => {_marker = marker};

  void update(GoogleMap.MarkerOptions options) {
    _marker.options = options;
  }

  void remove() {
    _marker.visible = false;
    _marker.map = null;
    _marker = null;
    //_marker.remove();
  }
}