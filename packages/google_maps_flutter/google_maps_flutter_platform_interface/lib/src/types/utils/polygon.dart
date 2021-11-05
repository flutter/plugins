// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';

/// Converts an [Iterable] of Polygons in a Map of PolygonId -> Polygon.
Map<PolygonId, Polygon> keyByPolygonId(Iterable<Polygon> polygons) {
  if (polygons == null) {
    return <PolygonId, Polygon>{};
  }
  return Map<PolygonId, Polygon>.fromEntries(polygons.map((Polygon polygon) =>
      MapEntry<PolygonId, Polygon>(polygon.polygonId, polygon.clone())));
}

/// Converts a Set of Polygons into something serializable in JSON.
List<Map<String, dynamic>> serializePolygonSet(Set<Polygon> polygons) {
  if (polygons == null) {
    return null;
  }
  return polygons.map<Map<String, dynamic>>((Polygon p) => p.toJson()).toList();
}
