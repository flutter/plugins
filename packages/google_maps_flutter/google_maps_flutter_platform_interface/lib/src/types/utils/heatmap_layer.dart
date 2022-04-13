// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of HeatmapLayers in a Map of
/// HeatmapLayerId -> HeatmapLayer.
Map<HeatmapLayerId, HeatmapLayer> keyByHeatmapLayerId(
  Iterable<HeatmapLayer> heatmapLayers,
) {
  return keyByMapsObjectId<HeatmapLayer>(heatmapLayers)
      .cast<HeatmapLayerId, HeatmapLayer>();
}

/// Converts a Set of HeatmapLayers into something serializable in JSON.
Object serializeHeatmapLayerSet(Set<HeatmapLayer> heatmapLayers) {
  return serializeMapsObjectSet(heatmapLayers);
}
