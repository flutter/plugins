part of google_maps_flutter_web;

/// The PolygonController class wraps a Polygon and its onTap behavior.
class PolygonController {
  gmaps.Polygon _polygon;

  final bool _consumeTapEvents;

  /// Creates a PolygonController, that wraps a Polygon object and its onTap behavior.
  PolygonController({
    @required gmaps.Polygon polygon,
    bool consumeTapEvents = false,
    ui.VoidCallback onTap,
  })  : _polygon = polygon,
        _consumeTapEvents = consumeTapEvents {
    if (_consumeTapEvents) {
      polygon.onClick.listen((event) {
        if (onTap != null) onTap.call();
      });
    }
  }

  /// Returns [true] if this Controller will use its own onTap handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Polygon] object.
  void update(gmaps.PolygonOptions options) {
    _polygon.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Polygon].
  void remove() {
    _polygon.visible = false;
    _polygon.map = null;
    _polygon = null;
  }
}
