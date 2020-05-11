// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';

/// Converts an [Iterable] of Polylines in a Map of PolylineId -> Polyline.
Map<PolylineId, Polyline> keyByPolylineId(Iterable<Polyline> polylines) {
  if (polylines == null) {
    return <PolylineId, Polyline>{};
  }
  return Map<PolylineId, Polyline>.fromEntries(polylines.map(
      (Polyline polyline) => MapEntry<PolylineId, Polyline>(
          polyline.polylineId, polyline.clone())));
}

/// Converts a Set of Polylines into something serializable in JSON.
List<Map<String, dynamic>> serializePolylineSet(Set<Polyline> polylines) {
  if (polylines == null) {
    return null;
  }
  return polylines
      .map<Map<String, dynamic>>((Polyline p) => p.toJson())
      .toList();
}
