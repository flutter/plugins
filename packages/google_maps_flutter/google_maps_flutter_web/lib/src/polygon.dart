part of google_maps_flutter_web;

///
class PolygonController {
  gmaps.Polygon _polygon;
  bool consumeTapEvents = false;
  ui.VoidCallback onTap;

  ///
  PolygonController(
      {@required gmaps.Polygon polygon, bool consumeTapEvents, this.onTap}) {
    _polygon = polygon;
    if (consumeTapEvents) {
      polygon.onClick.listen((event) {
        if (onTap != null) onTap.call();
      });
    }
  }

  set polygon(gmaps.Polygon polygon) {
    _polygon = polygon;
  }

  void update(gmaps.PolygonOptions options) {
    _polygon.options = options;
  }

  void remove() {
    _polygon.visible = false;
    _polygon.map = null;
    _polygon = null;
    //_polygon.remove();
  }
}
