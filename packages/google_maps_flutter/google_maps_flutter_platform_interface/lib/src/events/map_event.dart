import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Basic event coming from the native side of Maps.
///
/// All MapEvents contain the `mapId` that originated the event.
class MapEvent<T> {
  /// The ID of the Map this event is associated to.
  final int mapId;

  /// The value wrapped by this event
  final T value;

  /// Constructor
  MapEvent(this.mapId, this.value);
}

/// A `MapEvent` associated to a `position`.
class _PositionedMapEvent<T> extends MapEvent<T> {
  /// The position where this event happened.
  final LatLng position;

  /// Constructor
  _PositionedMapEvent(int mapId, this.position, T value) : super(mapId, value);
}

/// An event fired when the Camera of a [mapId] starts moving.
class CameraMoveStartedEvent extends MapEvent<void> {
  /// Constructor
  CameraMoveStartedEvent(int mapId) : super(mapId, null);
}

/// An event fired while the Camera of a [mapId] moves.
class CameraMoveEvent extends MapEvent<CameraPosition> {
  /// Constructor
  CameraMoveEvent(int mapId, CameraPosition position) : super(mapId, position);
}

/// An event fired when the Camera of a [mapId] becomes idle.
class CameraIdleEvent extends MapEvent<void> {
  /// Constructor
  CameraIdleEvent(int mapId) : super(mapId, null);
}

/// An event fired when a [Marker] is tapped.
class MarkerTapEvent extends MapEvent<MarkerId> {
  /// Constructor
  MarkerTapEvent(int mapId, MarkerId markerId) : super(mapId, markerId);
}

/// An event fired when an [InfoWindow] is tapped.
class InfoWindowTapEvent extends MapEvent<MarkerId> {
  /// Constructor
  InfoWindowTapEvent(int mapId, MarkerId markerId) : super(mapId, markerId);
}

/// An event fired when a [Marker] is dragged to a new [LatLng].
class MarkerDragEndEvent extends _PositionedMapEvent<MarkerId> {
  /// Constructor
  MarkerDragEndEvent(int mapId, LatLng position, MarkerId markerId)
      : super(mapId, position, markerId);
}

/// An event fired when a [Polyline] is tapped.
class PolylineTapEvent extends MapEvent<PolylineId> {
  /// Constructor
  PolylineTapEvent(int mapId, PolylineId polylineId) : super(mapId, polylineId);
}

/// An event fired when a [Polygon] is tapped.
class PolygonTapEvent extends MapEvent<PolygonId> {
  /// Constructor
  PolygonTapEvent(int mapId, PolygonId polygonId) : super(mapId, polygonId);
}

/// An event fired when a [Circle] is tapped.
class CircleTapEvent extends MapEvent<CircleId> {
  /// Constructor
  CircleTapEvent(int mapId, CircleId circleId) : super(mapId, circleId);
}

/// An event fired when a Map is tapped.
class MapTapEvent extends _PositionedMapEvent<void> {
  /// Constructor
  MapTapEvent(int mapId, LatLng position) : super(mapId, position, null);
}

/// An event fired when a Map is long pressed.
class MapLongPressEvent extends _PositionedMapEvent<void> {
  /// Constructor
  MapLongPressEvent(int mapId, LatLng position) : super(mapId, position, null);
}
