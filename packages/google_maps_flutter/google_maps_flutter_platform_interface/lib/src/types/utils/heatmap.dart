// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';

/// Converts an [Iterable] of Heatmaps in a Map of HeatmapId -> Heatmap.
Map<HeatmapId, Heatmap> keyByHeatmapId(Iterable<Heatmap> heatmaps) {
  if (heatmaps == null) {
    return <HeatmapId, Heatmap>{};
  }
  return Map<HeatmapId, Heatmap>.fromEntries(heatmaps.map((Heatmap heatmap) =>
      MapEntry<HeatmapId, Heatmap>(heatmap.heatmapId, heatmap.clone())));
}

/// Converts a Set of Heatmaps into something serializable in JSON.
List<Map<String, dynamic>> serializeHeatmapSet(Set<Heatmap> heatmaps) {
  if (heatmaps == null) {
    return null;
  }
  return heatmaps.map<Map<String, dynamic>>((Heatmap p) => p.toJson()).toList();
}
