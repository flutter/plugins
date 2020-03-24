import '../types.dart';

Map<PolylineId, Polyline> keyByPolylineId(Iterable<Polyline> polylines) {
  if (polylines == null) {
    return <PolylineId, Polyline>{};
  }
  return Map<PolylineId, Polyline>.fromEntries(polylines.map(
      (Polyline polyline) => MapEntry<PolylineId, Polyline>(
          polyline.polylineId, polyline.clone())));
}

List<Map<String, dynamic>> serializePolylineSet(Set<Polyline> polylines) {
  if (polylines == null) {
    return null;
  }
  return polylines
      .map<Map<String, dynamic>>((Polyline p) => p.toJson())
      .toList();
}
