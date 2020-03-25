import '../types.dart';

Map<PolygonId, Polygon> keyByPolygonId(Iterable<Polygon> polygons) {
  if (polygons == null) {
    return <PolygonId, Polygon>{};
  }
  return Map<PolygonId, Polygon>.fromEntries(polygons.map((Polygon polygon) =>
      MapEntry<PolygonId, Polygon>(polygon.polygonId, polygon.clone())));
}

List<Map<String, dynamic>> serializePolygonSet(Set<Polygon> polygons) {
  if (polygons == null) {
    return null;
  }
  return polygons.map<Map<String, dynamic>>((Polygon p) => p.toJson()).toList();
}
