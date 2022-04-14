// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [Heatmap] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class HeatmapUpdates extends MapsObjectUpdates<Heatmap> {
  /// Computes [HeatmapUpdates] given previous and current [Heatmap]s.
  HeatmapUpdates.from(
    Set<Heatmap> previous,
    Set<Heatmap> current,
  ) : super.from(previous, current, objectName: 'heatmap');

  /// Set of Heatmaps to be added in this update.
  Set<Heatmap> get heatmapsToAdd => objectsToAdd;

  /// Set of Heatmaps to be removed in this update.
  Set<HeatmapId> get heatmapIdsToRemove => objectIdsToRemove.cast<HeatmapId>();

  /// Set of Heatmaps to be changed in this update.
  Set<Heatmap> get heatmapsToChange => objectsToChange;
}
