// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';

/// Converts an [Iterable] of Markers in a Map of MarkerId -> Marker.
Map<MarkerId, Marker> keyByMarkerId(Iterable<Marker> markers) {
  if (markers == null) {
    return <MarkerId, Marker>{};
  }
  return Map<MarkerId, Marker>.fromEntries(markers.map((Marker marker) =>
      MapEntry<MarkerId, Marker>(marker.markerId, marker.clone())));
}

/// Converts a Set of Markers into something serializable in JSON.
List<Map<String, dynamic>> serializeMarkerSet(Set<Marker> markers) {
  if (markers == null) {
    return null;
  }
  return markers.map<Map<String, dynamic>>((Marker m) => m.toJson()).toList();
}
