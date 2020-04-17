part of google_maps_flutter_web;


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