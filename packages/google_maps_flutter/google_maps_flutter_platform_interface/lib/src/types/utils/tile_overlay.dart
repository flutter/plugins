import '../types.dart';

/// Converts an [Iterable] of TileOverlay in a Map of TileOverlayId -> TileOverlay.
Map<TileOverlayId, TileOverlay> keyTileOverlayId(
    Iterable<TileOverlay> tileOverlays) {
  if (tileOverlays == null) {
    return <TileOverlayId, TileOverlay>{};
  }
  return Map<TileOverlayId, TileOverlay>.fromEntries(tileOverlays.map(
      (TileOverlay tileOverlay) => MapEntry<TileOverlayId, TileOverlay>(
          tileOverlay.tileOverlayId, tileOverlay)));
}

/// Converts a Set of TileOverlays into something serializable in JSON.
List<Map<String, dynamic>> serializeTileOverlaySet(
    Set<TileOverlay> tileOverlays) {
  if (tileOverlays == null) {
    return null;
  }
  return tileOverlays
      .map<Map<String, dynamic>>((TileOverlay p) => p.toJson())
      .toList();
}
