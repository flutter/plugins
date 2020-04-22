import '../types.dart';

List<Map<String, dynamic>> serializeTileOverlays(List<TileOverlay> overlays) {
  if (overlays == null) {
    return null;
  }

  return overlays.map<Map<String, dynamic>>((e) => e.toMap()).toList();
}