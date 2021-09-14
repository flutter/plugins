import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of [GroundOverlay] in a Map of
/// [GroundOverlayId] -> [GroundOverlay].
Map<GroundOverlayId, GroundOverlay> keyGroundOverlayId(
    Iterable<GroundOverlay> groundOverlays) {
  return keyByMapsObjectId<GroundOverlay>(groundOverlays)
      .cast<GroundOverlayId, GroundOverlay>();
}

/// Converts a Set of [GroundOverlay]s into something serializable in JSON.
Object serializeGroundOverlaySet(Set<GroundOverlay> groundOverlays) {
  return serializeMapsObjectSet(groundOverlays);
}
