import '../types.dart';

Map<CircleId, Circle> keyByCircleId(Iterable<Circle> circles) {
  if (circles == null) {
    return <CircleId, Circle>{};
  }
  return Map<CircleId, Circle>.fromEntries(circles.map((Circle circle) =>
      MapEntry<CircleId, Circle>(circle.circleId, circle.clone())));
}

List<Map<String, dynamic>> serializeCircleSet(Set<Circle> circles) {
  if (circles == null) {
    return null;
  }
  return circles.map<Map<String, dynamic>>((Circle p) => p.toJson()).toList();
}
