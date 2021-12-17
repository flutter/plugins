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
  return heatmaps.map<Map<String, dynamic>>((Heatmap p) => _heatmapToJson(p)).toList();
}

/// Converts this object to something serializable in JSON.
dynamic _heatmapToJson(Heatmap heatmap) {
  final Map<String, dynamic> json = <String, dynamic>{};

  void addIfPresent(String fieldName, dynamic value) {
    if (value != null) {
      json[fieldName] = value;
    }
  }

  addIfPresent('heatmapId', heatmap.heatmapId.value);
  addIfPresent('opacity', heatmap.opacity);
  addIfPresent('radius', heatmap.radius);
  addIfPresent('fadeIn', heatmap.fadeIn);
  addIfPresent('transparency', heatmap.transparency);
  addIfPresent('visible', heatmap.visible);
  addIfPresent('zIndex', heatmap.zIndex);

  if (heatmap.gradient != null) {
    json['gradient'] = heatmap.gradient?.toJson();
  }

  if (heatmap.points != null) {
    json['points'] = heatmap.pointsToJson();
  }

  return json;
}
