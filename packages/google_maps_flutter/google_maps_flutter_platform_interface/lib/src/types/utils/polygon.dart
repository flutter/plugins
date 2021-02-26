// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of Polygons in a Map of PolygonId -> Polygon.
Map<PolygonId, Polygon> keyByPolygonId(Iterable<Polygon> polygons) {
  return keyByMapsObjectId<Polygon>(polygons).cast<PolygonId, Polygon>();
}

/// Converts a Set of Polygons into something serializable in JSON.
Object serializePolygonSet(Set<Polygon> polygons) {
  return serializeMapsObjectSet(polygons);
}
