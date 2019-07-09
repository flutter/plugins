// Copyright 2019 The HKTaxiApp Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// [MarkerRoute] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class _MarkerRouteUpdates {
  /// Computes [_MarkerRouteUpdates] given previous and current [MarkerRoute]s.
  _MarkerRouteUpdates.from(Set<MarkerRoute> previous, Set<MarkerRoute> current) {
    if (previous == null) {
      previous = Set<MarkerRoute>.identity();
    }

    if (current == null) {
      current = Set<MarkerRoute>.identity();
    }

    final Map<MarkerRouteId, MarkerRoute> previousMarkerRoutes = _keyByMarkerRouteId(previous);
    final Map<MarkerRouteId, MarkerRoute> currentMarkerRoutes = _keyByMarkerRouteId(current);

    final Set<MarkerRouteId> prevMarkerRouteIds = previousMarkerRoutes.keys.toSet();
    final Set<MarkerRouteId> currentMarkerRouteIds = currentMarkerRoutes.keys.toSet();

    MarkerRoute idToCurrentMarkerRoute(MarkerRouteId id) {
      return currentMarkerRoutes[id];
    }

    final Set<MarkerRouteId> _routeIdsToRemove =
        prevMarkerRouteIds.difference(currentMarkerRouteIds);

    final Set<MarkerRoute> _routesToAdd = currentMarkerRouteIds
        .difference(prevMarkerRouteIds)
        .map(idToCurrentMarkerRoute)
        .toSet();

    final Set<MarkerRoute> _routesToChange = currentMarkerRouteIds
        .intersection(prevMarkerRouteIds)
        .map(idToCurrentMarkerRoute)
        .toSet();

    routesToAdd = _routesToAdd;
    routeIdsToRemove = _routeIdsToRemove;
    routesToChange = _routesToChange;
  }

  Set<MarkerRoute> routesToAdd;
  Set<MarkerRouteId> routeIdsToRemove;
  Set<MarkerRoute> routesToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('routesToAdd', _serializeMarkerRouteSet(routesToAdd));
    addIfNonNull('routesToChange', _serializeMarkerRouteSet(routesToChange));
    addIfNonNull('routeIdsToRemove',
        routeIdsToRemove.map<dynamic>((MarkerRouteId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _MarkerRouteUpdates typedOther = other;
    return setEquals(routesToAdd, typedOther.routesToAdd) &&
        setEquals(routeIdsToRemove, typedOther.routeIdsToRemove) &&
        setEquals(routesToChange, typedOther.routesToChange);
  }

  @override
  int get hashCode =>
      hashValues(routesToAdd, routeIdsToRemove, routesToChange);

  @override
  String toString() {
    return '_MarkerRouteUpdates{routesToAdd: $routesToAdd, '
        'routeIdsToRemove: $routeIdsToRemove, '
        'routesToChange: $routesToChange}';
  }
}
