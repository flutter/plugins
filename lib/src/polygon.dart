part of google_maps_flutter_web;


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