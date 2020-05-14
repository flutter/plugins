// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;

import 'types.dart';
import 'utils/polygon.dart';

/// [Polygon] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class PolygonUpdates {
  /// Computes [PolygonUpdates] given previous and current [Polygon]s.
  PolygonUpdates.from(Set<Polygon> previous, Set<Polygon> current) {
    if (previous == null) {
      previous = Set<Polygon>.identity();
    }

    if (current == null) {
      current = Set<Polygon>.identity();
    }

    final Map<PolygonId, Polygon> previousPolygons = keyByPolygonId(previous);
    final Map<PolygonId, Polygon> currentPolygons = keyByPolygonId(current);

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

  /// Set of Polygons to be added in this update.
  Set<Polygon> polygonsToAdd;

  /// Set of PolygonIds to be removed in this update.
  Set<PolygonId> polygonIdsToRemove;

  /// Set of Polygons to be changed in this update.
  Set<Polygon> polygonsToChange;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('polygonsToAdd', serializePolygonSet(polygonsToAdd));
    addIfNonNull('polygonsToChange', serializePolygonSet(polygonsToChange));
    addIfNonNull('polygonIdsToRemove',
        polygonIdsToRemove.map<dynamic>((PolygonId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PolygonUpdates typedOther = other;
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
