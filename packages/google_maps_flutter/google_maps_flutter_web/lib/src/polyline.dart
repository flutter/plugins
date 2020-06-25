part of google_maps_flutter_web;


class PolylineController {

  GoogleMap.Polyline _polyline;
  bool consumeTapEvents = false;
  ui.VoidCallback onTap;

  ///
  PolylineController({
    @required GoogleMap.Polyline polyline,
    bool consumeTapEvents,
    this.onTap
  }){
    _polyline = polyline;
    if(consumeTapEvents) {
      polyline.onClick.listen((event) {
        if(onTap !=null) onTap.call();
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