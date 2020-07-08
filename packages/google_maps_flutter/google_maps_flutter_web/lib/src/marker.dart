part of google_maps_flutter_web;

class MarkerController {

  gmaps.Marker _marker;
  gmaps.InfoWindow infoWindow;
  bool consumeTapEvents = false;
  ui.VoidCallback onTap;
  ui.VoidCallback onInfoWindowTap;
  LatLngCallback onDragEnd;
  bool infoWindowShown = false;
  ///
  MarkerController({
    @required gmaps.Marker marker,
    this.infoWindow,
    this.consumeTapEvents,
    this.onTap,
    this.onDragEnd,
    this.onInfoWindowTap,
  }){
    _marker = marker;
    if(consumeTapEvents) {
    }
    if(onTap !=null){
      marker.onClick.listen((event) {onTap.call(); });
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


  set marker (gmaps.Marker marker) { _marker = marker; }

  void update(gmaps.MarkerOptions options) {
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