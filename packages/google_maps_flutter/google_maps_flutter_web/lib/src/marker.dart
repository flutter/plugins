part of google_maps_flutter_web;

typedef LatLngCallback = void Function(gmaps.LatLng latLng);

/// This class wraps a [gmaps.Marker], how it handles events, and its associated [gmaps.InfoWindow] widget (optional).
class MarkerController {
  gmaps.Marker _marker;

  final bool _consumeTapEvents;

  final gmaps.InfoWindow _infoWindow;

  bool _infoWindowShown = false;

  /// Creates a MarkerController, that wraps a Marker object, its onTap/Drag behavior, and its associated InfoWindow.
  MarkerController({
    @required gmaps.Marker marker,
    gmaps.InfoWindow infoWindow,
    bool consumeTapEvents = false,
    LatLngCallback onDragEnd,
    ui.VoidCallback onTap,
  })  : _marker = marker,
        _infoWindow = infoWindow,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      _marker.onClick.listen((event) {
        onTap.call();
      });
    }
    if (onDragEnd != null) {
      _marker.onDragend.listen((event) {
        _marker.position = event.latLng;
        onDragEnd.call(event.latLng);
      });
    }
  }

  /// Returns [true] if this Controller will use its own onTap handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Returns [true] if the InfoWindow associated to this marker is being shown.
  bool get infoWindowShown => _infoWindowShown;

  /// Updates the options of the wrapped [gmaps.Polygon] object.
  void update(gmaps.MarkerOptions options) {
    _marker.options = options;
  }

  /// Disposes of the currently wrapped Marker.
  void remove() {
    _marker.visible = false;
    _marker.map = null;
    _marker = null;
  }

  /// Hide the associated InfoWindow.
  void hideInfoWindow() {
    if (_infoWindow != null) {
      _infoWindow.close();
      _infoWindowShown = false;
    }
  }

  /// Show the associated InfoWindow.
  void showInfoWindow() {
    if (_infoWindow != null) {
      _infoWindow.open(_marker.map);
      _infoWindowShown = true;
    }
  }
}
