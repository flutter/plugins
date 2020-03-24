import '../types.dart';

Map<MarkerId, Marker> keyByMarkerId(Iterable<Marker> markers) {
  if (markers == null) {
    return <MarkerId, Marker>{};
  }
  return Map<MarkerId, Marker>.fromEntries(markers.map((Marker marker) =>
      MapEntry<MarkerId, Marker>(marker.markerId, marker.clone())));
}

List<Map<String, dynamic>> serializeMarkerSet(Set<Marker> markers) {
  if (markers == null) {
    return null;
  }
  return markers.map<Map<String, dynamic>>((Marker m) => m.toJson()).toList();
}
