part of google_maps_flutter_web;

/// The PolygonController class wraps a [gmaps.Polyline] and its onTap behavior.
class PolylineController {
  gmaps.Polyline _polyline;

  final bool _consumeTapEvents;

  /// Creates a PolylineController, that wraps a Polyline object and its onTap behavior.
  PolylineController({
    @required gmaps.Polyline polyline,
    bool consumeTapEvents = false,
    ui.VoidCallback onTap,
  })  : _polyline = polyline,
        _consumeTapEvents = consumeTapEvents {
    if (consumeTapEvents) {
      polyline.onClick.listen((event) {
        if (onTap != null) onTap.call();
      });
    }
  }

  /// Returns [true] if this Controller will use its own onTap handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped Polyline object.
  void update(gmaps.PolylineOptions options) {
    _polyline.options = options;
  }

  /// Disposes of the currently wrapped Polyline.
  void remove() {
    _polyline.visible = false;
    _polyline.map = null;
    _polyline = null;
  }
}
