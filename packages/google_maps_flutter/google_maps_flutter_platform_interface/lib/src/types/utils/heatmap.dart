// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of Heatmaps in a Map of
/// HeatmapId -> Heatmap.
Map<HeatmapId, Heatmap> keyByHeatmapId(
  Iterable<Heatmap> heatmaps,
) {
  return keyByMapsObjectId<Heatmap>(heatmaps).cast<HeatmapId, Heatmap>();
}

/// Converts a Set of Heatmaps into something serializable in JSON.
Object serializeHeatmapSet(Set<Heatmap> heatmaps) {
  return serializeMapsObjectSet(heatmaps);
}
