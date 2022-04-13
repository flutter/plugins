// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [HeatmapLayer] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class HeatmapLayerUpdates extends MapsObjectUpdates<HeatmapLayer> {
  /// Computes [HeatmapLayerUpdates] given previous and current [HeatmapLayer]s.
  HeatmapLayerUpdates.from(
    Set<HeatmapLayer> previous,
    Set<HeatmapLayer> current,
  ) : super.from(previous, current, objectName: 'heatmapLayer');

  /// Set of HeatmapLayers to be added in this update.
  Set<HeatmapLayer> get heatmapLayersToAdd => objectsToAdd;

  /// Set of HeatmapLayers to be removed in this update.
  Set<HeatmapLayerId> get heatmapLayerIdsToRemove =>
      objectIdsToRemove.cast<HeatmapLayerId>();

  /// Set of HeatmapLayers to be changed in this update.
  Set<HeatmapLayer> get heatmapLayersToChange => objectsToChange;
}
