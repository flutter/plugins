// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;

import 'types.dart';

/// [Heatmap] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class HeatmapUpdates {
  /// Computes [HeatmapUpdates] given previous and current [Heatmap]s.
  HeatmapUpdates.from(Set<Heatmap> previous, Set<Heatmap> current) {
    final Map<HeatmapId, Heatmap> previousHeatmaps = keyByHeatmapId(previous);
    final Map<HeatmapId, Heatmap> currentHeatmaps = keyByHeatmapId(current);

    final Set<HeatmapId> prevHeatmapIds = previousHeatmaps.keys.toSet();
    final Set<HeatmapId> currentHeatmapIds = currentHeatmaps.keys.toSet();

    Heatmap idToCurrentHeatmap(HeatmapId id) {
      return currentHeatmaps[id]!;
    }

    final Set<HeatmapId> _heatmapIdsToRemove =
        prevHeatmapIds.difference(currentHeatmapIds);

    final Set<Heatmap> _heatmapsToAdd = currentHeatmapIds
        .difference(prevHeatmapIds)
        .map(idToCurrentHeatmap)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Heatmap current) {
      final Heatmap previous = previousHeatmaps[current.heatmapId]!;
      return current != previous;
    }

    final Set<Heatmap> _heatmapsToChange = currentHeatmapIds
        .intersection(prevHeatmapIds)
        .map(idToCurrentHeatmap)
        .where(hasChanged)
        .toSet();

    heatmapsToAdd = _heatmapsToAdd;
    heatmapIdsToRemove = _heatmapIdsToRemove;
    heatmapsToChange = _heatmapsToChange;
  }

  /// Set of Heatmaps to be added in this update.
  late Set<Heatmap> heatmapsToAdd;

  /// Set of HeatmapIds to be removed in this update.
  late Set<HeatmapId> heatmapIdsToRemove;

  /// Set of Heatmaps to be changed in this update.
  late Set<Heatmap> heatmapsToChange;
}
