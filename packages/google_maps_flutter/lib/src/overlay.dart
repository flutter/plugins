part of google_maps_flutter;

class OverlayId{
  OverlayId(this.value);
  final String value;
}

abstract class Overlay {
  const Overlay({
    @required this.overlayId, 
    this.consumeTapEvents = false,
    this.onTap, 
    this.zIndex = 0, 
  });
  final OverlayId overlayId;
  final bool consumeTapEvents;
  final VoidCallback onTap;
  final int zIndex;

  dynamic _toJson();
} 

Map<OverlayId, Overlay> _keyByOverlayId(Iterable<Overlay> overlays) {
  if (overlays == null) {
    return <OverlayId, Overlay>{};
  }
  return Map<OverlayId, Overlay>.fromEntries(overlays.map((Overlay overlay) =>
      MapEntry<OverlayId, Overlay>(overlay.overlayId, overlay)));
}


List<Map<String, dynamic>> _serializeOverlaySet(Set<Overlay> overlay) {
  if (overlay == null) {
    return null;
  }
  return overlay
      .map<Map<String, dynamic>>((Overlay p) => p._toJson())
      .toList();
}