part of google_maps_flutter_web;

/// The CircleController class wraps a Circle and its onTap behavior.
class CircleController {
  gmaps.Circle _circle;

  final bool _consumeTapEvents;

  /// Creates a CircleController, that wraps a Circle object and its onTap behavior.
  CircleController({
    @required gmaps.Circle circle,
    bool consumeTapEvents = false,
    ui.VoidCallback onTap,
  })  : _circle = circle,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      circle.onClick.listen((_) {
        onTap.call();
      });
    }
  }

  /// Returns [true] if this Controller will use its own onTap handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Circle] object.
  void update(gmaps.CircleOptions options) {
    _circle.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Circle].
  void remove() {
    _circle.visible = false;
    _circle.radius = 0;
    _circle.map = null;
    _circle = null;
  }
}
