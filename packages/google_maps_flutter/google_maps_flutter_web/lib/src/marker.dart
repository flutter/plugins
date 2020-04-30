part of google_maps_flutter_web;

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