part of google_maps_flutter_web;

class PolylineController {
  gmaps.Polyline _polyline;
  bool consumeTapEvents = false;
  ui.VoidCallback onTap;

  ///
  PolylineController(
      {@required gmaps.Polyline polyline, bool consumeTapEvents, this.onTap}) {
    _polyline = polyline;
    if (consumeTapEvents) {
      polyline.onClick.listen((event) {
        if (onTap != null) onTap.call();
      });
    }
  }

  set polyline(gmaps.Polyline polyline) {
    _polyline = polyline;
  }

  void update(gmaps.PolylineOptions options) {
    _polyline.options = options;
  }

  void remove() {
    _polyline.visible = false;
    _polyline.map = null;
    _polyline = null;
    //_polyline.remove();
  }
}
