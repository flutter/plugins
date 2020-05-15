// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;

import 'utils/polyline.dart';
import 'types.dart';

/// [Polyline] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class PolylineUpdates {
  /// Computes [PolylineUpdates] given previous and current [Polyline]s.
  PolylineUpdates.from(Set<Polyline> previous, Set<Polyline> current) {
    if (previous == null) {
      previous = Set<Polyline>.identity();
    }

    if (current == null) {
      current = Set<Polyline>.identity();
    }

    final Map<PolylineId, Polyline> previousPolylines =
        keyByPolylineId(previous);
    final Map<PolylineId, Polyline> currentPolylines = keyByPolylineId(current);

    final Set<PolylineId> prevPolylineIds = previousPolylines.keys.toSet();
    final Set<PolylineId> currentPolylineIds = currentPolylines.keys.toSet();

    Polyline idToCurrentPolyline(PolylineId id) {
      return currentPolylines[id];
    }

    final Set<PolylineId> _polylineIdsToRemove =
        prevPolylineIds.difference(currentPolylineIds);

    final Set<Polyline> _polylinesToAdd = currentPolylineIds
        .difference(prevPolylineIds)
        .map(idToCurrentPolyline)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Polyline current) {
      final Polyline previous = previousPolylines[current.polylineId];
      return current != previous;
    }

    final Set<Polyline> _polylinesToChange = currentPolylineIds
        .intersection(prevPolylineIds)
        .map(idToCurrentPolyline)
        .where(hasChanged)
        .toSet();

    polylinesToAdd = _polylinesToAdd;
    polylineIdsToRemove = _polylineIdsToRemove;
    polylinesToChange = _polylinesToChange;
  }

  /// Set of Polylines to be added in this update.
  Set<Polyline> polylinesToAdd;

  /// Set of PolylineIds to be removed in this update.
  Set<PolylineId> polylineIdsToRemove;

  /// Set of Polylines to be changed in this update.
  Set<Polyline> polylinesToChange;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('polylinesToAdd', serializePolylineSet(polylinesToAdd));
    addIfNonNull('polylinesToChange', serializePolylineSet(polylinesToChange));
    addIfNonNull('polylineIdsToRemove',
        polylineIdsToRemove.map<dynamic>((PolylineId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PolylineUpdates typedOther = other;
    return setEquals(polylinesToAdd, typedOther.polylinesToAdd) &&
        setEquals(polylineIdsToRemove, typedOther.polylineIdsToRemove) &&
        setEquals(polylinesToChange, typedOther.polylinesToChange);
  }

  @override
  int get hashCode =>
      hashValues(polylinesToAdd, polylineIdsToRemove, polylinesToChange);

  @override
  String toString() {
    return '_PolylineUpdates{polylinesToAdd: $polylinesToAdd, '
        'polylineIdsToRemove: $polylineIdsToRemove, '
        'polylinesToChange: $polylinesToChange}';
  }
}
