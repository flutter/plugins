// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// [Heatmap] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class _HeatmapUpdates {
  /// Computes [_HeatmapUpdates] given previous and current [Heatmap]s.
  _HeatmapUpdates.from(Set<Heatmap> previous, Set<Heatmap> current) {
    if (previous == null) {
      previous = Set<Heatmap>.identity();
    }

    if (current == null) {
      current = Set<Heatmap>.identity();
    }

    final Map<HeatmapId, Heatmap> previousHeatmaps = _keyByHeatmapId(previous);
    final Map<HeatmapId, Heatmap> currentHeatmaps = _keyByHeatmapId(current);

    final Set<HeatmapId> prevHeatmapIds = previousHeatmaps.keys.toSet();
    final Set<HeatmapId> currentHeatmapIds = currentHeatmaps.keys.toSet();

    Heatmap idToCurrentHeatmap(HeatmapId id) {
      return currentHeatmaps[id];
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
      final Heatmap previous = previousHeatmaps[current.heatmapId];
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

  Set<Heatmap> heatmapsToAdd;
  Set<HeatmapId> heatmapIdsToRemove;
  Set<Heatmap> heatmapsToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('heatmapsToAdd', _serializeHeatmapSet(heatmapsToAdd));
    addIfNonNull('heatmapsToChange', _serializeHeatmapSet(heatmapsToChange));
    addIfNonNull('heatmapIdsToRemove',
        heatmapIdsToRemove.map<dynamic>((HeatmapId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _HeatmapUpdates typedOther = other;
    return setEquals(heatmapsToAdd, typedOther.heatmapsToAdd) &&
        setEquals(heatmapIdsToRemove, typedOther.heatmapIdsToRemove) &&
        setEquals(heatmapsToChange, typedOther.heatmapsToChange);
  }

  @override
  int get hashCode =>
      hashValues(heatmapsToAdd, heatmapIdsToRemove, heatmapsToChange);

  @override
  String toString() {
    return '_HeatmapUpdates{heatmapsToAdd: $heatmapsToAdd, '
        'heatmapIdsToRemove: $heatmapIdsToRemove, '
        'heatmapsToChange: $heatmapsToChange}';
  }
}
