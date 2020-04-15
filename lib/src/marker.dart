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

GoogleMap.InfoWindowOptions _infoWindowOPtionsFromMarker(Marker marker) {
  return GoogleMap.InfoWindowOptions()
    ..content = marker.infoWindow.snippet
    ..zIndex    = marker.zIndex
    ..position = GoogleMap.LatLng(
        marker.position.latitude,
        marker.position.longitude)
  ;
}

GoogleMap.MarkerOptions _markerOptionsFromMarker(GoogleMap.GMap googleMap,
    Marker marker) {

  dynamic iconConfig = marker.icon.toJson();
  dynamic icon;

  if(iconConfig[0] == 'defaultMarker') icon = '';
  else if(iconConfig[0] == 'fromAssetImage') {
    print('TODO:' + iconConfig);
    Image mImage = Image.asset(iconConfig[1] );
//    ui.Image image = mImage.;
  }
    return GoogleMap.MarkerOptions()
      ..position  = GoogleMap.LatLng(marker.position.latitude,
          marker.position.longitude)
      ..title     = marker.infoWindow.title
      ..zIndex    = marker.zIndex
      ..visible   = marker.visible
      ..opacity   = marker.alpha
      ..draggable = marker.draggable
      ..icon      = icon//  this.icon = BitmapDescriptor.defaultMarker,
      ..anchorPoint = GoogleMap.Point(marker.anchor.dx, marker.anchor.dy)
    //marker.rotation
    //https://stackoverflow.com/questions/6800613/rotating-image-marker-image-on-google-map-v3/28819037
//  this.flat = false,
    ;
}

class MarkerController {

  GoogleMap.Marker _marker;
  GoogleMap.InfoWindow infoWindow;
  bool consumeTapEvents = false;
  ui.VoidCallback ontab;
  ui.VoidCallback onInfoWindowTap;
  LatLngCallback onDragEnd;
  bool infoWindowShown = false;
  ///
  MarkerController({
    @required GoogleMap.Marker marker,
    this.infoWindow,
    this.consumeTapEvents,
    this.ontab,
    this.onDragEnd,
    this.onInfoWindowTap,
  }){
    _marker = marker;
    if(consumeTapEvents) {
    }
    if(ontab !=null){
      marker.onClick.listen((event) {ontab.call(); });
    }
    if(_marker.draggable) {
      marker.onDragend.listen((event) {
        if(onDragEnd !=null) onDragEnd.call(event.latLng);
      });
    }
    if(onInfoWindowTap !=null) {
      infoWindow.addListener('click', onInfoWindowTap);
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

  void hideInfoWindow() {
    if(infoWindow != null) {
      infoWindow.close();
      infoWindowShown = false;
    }
  }

  void showMarkerInfoWindow() {
    infoWindow.open(_marker.map);
    infoWindowShown = true;
  }

  bool isInfoWindowShown() {
    return infoWindowShown;
  }
}