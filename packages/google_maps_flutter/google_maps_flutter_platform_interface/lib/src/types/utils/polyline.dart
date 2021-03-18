// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of Polylines in a Map of PolylineId -> Polyline.
Map<PolylineId, Polyline> keyByPolylineId(Iterable<Polyline> polylines) {
  return keyByMapsObjectId<Polyline>(polylines).cast<PolylineId, Polyline>();
}

/// Converts a Set of Polylines into something serializable in JSON.
Object serializePolylineSet(Set<Polyline> polylines) {
  return serializeMapsObjectSet(polylines);
}
