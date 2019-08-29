// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// [Polygon] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class _PolygonUpdates {
  /// Computes [_PolygonUpdates] given previous and current [Polygon]s.
  _PolygonUpdates.from(Set<Polygon> previous, Set<Polygon> current) {
    if (previous == null) {
      previous = Set<Polygon>.identity();
    }

    if (current == null) {
      current = Set<Polygon>.identity();
    }

    final Map<PolygonId, Polygon> previousPolygons = _keyByPolygonId(previous);
    final Map<PolygonId, Polygon> currentPolygons = _keyByPolygonId(current);

    final Set<PolygonId> prevPolygonIds = previousPolygons.keys.toSet();
    final Set<PolygonId> currentPolygonIds = currentPolygons.keys.toSet();

    Polygon idToCurrentPolygon(PolygonId id) {
      return currentPolygons[id];
    }

    final Set<PolygonId> _polygonIdsToRemove =
        prevPolygonIds.difference(currentPolygonIds);

    final Set<Polygon> _polygonsToAdd = currentPolygonIds
        .difference(prevPolygonIds)
        .map(idToCurrentPolygon)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Polygon current) {
      final Polygon previous = previousPolygons[current.polygonId];
      return current != previous;
    }

    final Set<Polygon> _polygonsToChange = currentPolygonIds
        .intersection(prevPolygonIds)
        .map(idToCurrentPolygon)
        .where(hasChanged)
        .toSet();

    polygonsToAdd = _polygonsToAdd;
    polygonIdsToRemove = _polygonIdsToRemove;
    polygonsToChange = _polygonsToChange;
  }

  Set<Polygon> polygonsToAdd;
  Set<PolygonId> polygonIdsToRemove;
  Set<Polygon> polygonsToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('polygonsToAdd', _serializePolygonSet(polygonsToAdd));
    addIfNonNull('polygonsToChange', _serializePolygonSet(polygonsToChange));
    addIfNonNull('polygonIdsToRemove',
        polygonIdsToRemove.map<dynamic>((PolygonId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _PolygonUpdates typedOther = other;
    return setEquals(polygonsToAdd, typedOther.polygonsToAdd) &&
        setEquals(polygonIdsToRemove, typedOther.polygonIdsToRemove) &&
        setEquals(polygonsToChange, typedOther.polygonsToChange);
  }

  @override
  int get hashCode =>
      hashValues(polygonsToAdd, polygonIdsToRemove, polygonsToChange);

  @override
  String toString() {
    return '_PolygonUpdates{polygonsToAdd: $polygonsToAdd, '
        'polygonIdsToRemove: $polygonIdsToRemove, '
        'polygonsToChange: $polygonsToChange}';
  }
}
