// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// [Marker] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class _ClusterUpdates {
  /// Computes [_ClusterUpdates] given previous and current [ClusterItem]s.
  _ClusterUpdates.from(Set<ClusterItem> previous, Set<ClusterItem> current) {
    if (previous == null) {
      previous = Set<ClusterItem>.identity();
    }

    if (current == null) {
      current = Set<ClusterItem>.identity();
    }

    final Map<MarkerId, ClusterItem> previousClusterItems =
        _keyByClusterItemId(previous);
    final Map<MarkerId, ClusterItem> currentClusterItems =
        _keyByClusterItemId(current);

    final Set<MarkerId> prevClusterIds = previousClusterItems.keys.toSet();
    final Set<MarkerId> currentClusterIds = currentClusterItems.keys.toSet();

    ClusterItem idToCurrentClusterItem(MarkerId id) {
      return currentClusterItems[id];
    }

    final Set<MarkerId> _clusterItemsToRemove =
        prevClusterIds.difference(currentClusterIds);

    final Set<ClusterItem> _clusterItemsToAdd = currentClusterIds
        .difference(prevClusterIds)
        .map(idToCurrentClusterItem)
        .toSet();

    final Set<ClusterItem> _clusterItemsToChange = currentClusterIds
        .intersection(prevClusterIds)
        .map(idToCurrentClusterItem)
        .toSet();

    clusterItemsToAdd = _clusterItemsToAdd;
    clusterItemsIdsToRemove = _clusterItemsToRemove;
    clusterItemsToChange = _clusterItemsToChange;
  }

  Set<ClusterItem> clusterItemsToAdd;
  Set<MarkerId> clusterItemsIdsToRemove;
  Set<ClusterItem> clusterItemsToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('clusterItemsToAdd', _serializeClusterSet(clusterItemsToAdd));
    addIfNonNull(
        'clusterItemsToChange', _serializeClusterSet(clusterItemsToChange));
    addIfNonNull('clusterItemsIdsToRemove',
        clusterItemsIdsToRemove.map<dynamic>((MarkerId m) => m.value).toList());
    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _MarkerUpdates typedOther = other;
    return setEquals(clusterItemsToAdd, typedOther.markersToAdd) &&
        setEquals(clusterItemsIdsToRemove, typedOther.markerIdsToRemove) &&
        setEquals(clusterItemsToChange, typedOther.markersToChange);
  }

  @override
  int get hashCode => hashValues(
      clusterItemsToAdd, clusterItemsIdsToRemove, clusterItemsToChange);

  @override
  String toString() {
    return '_ClusterItemUpdates{ClusterItemsToAdd: $clusterItemsToAdd, '
        'ClusterItemsIdsToRemove: $clusterItemsIdsToRemove, '
        'ClusterItemsToChange: $clusterItemsToChange}';
  }
}
