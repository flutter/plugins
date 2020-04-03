// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;

import 'types.dart';
import 'utils/circle.dart';

/// [Circle] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class CircleUpdates {
  /// Computes [CircleUpdates] given previous and current [Circle]s.
  CircleUpdates.from(Set<Circle> previous, Set<Circle> current) {
    if (previous == null) {
      previous = Set<Circle>.identity();
    }

    if (current == null) {
      current = Set<Circle>.identity();
    }

    final Map<CircleId, Circle> previousCircles = keyByCircleId(previous);
    final Map<CircleId, Circle> currentCircles = keyByCircleId(current);

    final Set<CircleId> prevCircleIds = previousCircles.keys.toSet();
    final Set<CircleId> currentCircleIds = currentCircles.keys.toSet();

    Circle idToCurrentCircle(CircleId id) {
      return currentCircles[id];
    }

    final Set<CircleId> _circleIdsToRemove =
        prevCircleIds.difference(currentCircleIds);

    final Set<Circle> _circlesToAdd = currentCircleIds
        .difference(prevCircleIds)
        .map(idToCurrentCircle)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Circle current) {
      final Circle previous = previousCircles[current.circleId];
      return current != previous;
    }

    final Set<Circle> _circlesToChange = currentCircleIds
        .intersection(prevCircleIds)
        .map(idToCurrentCircle)
        .where(hasChanged)
        .toSet();

    circlesToAdd = _circlesToAdd;
    circleIdsToRemove = _circleIdsToRemove;
    circlesToChange = _circlesToChange;
  }

  /// Set of Circles to be added in this update.
  Set<Circle> circlesToAdd;

  /// Set of CircleIds to be removed in this update.
  Set<CircleId> circleIdsToRemove;

  /// Set of Circles to be changed in this update.
  Set<Circle> circlesToChange;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('circlesToAdd', serializeCircleSet(circlesToAdd));
    addIfNonNull('circlesToChange', serializeCircleSet(circlesToChange));
    addIfNonNull('circleIdsToRemove',
        circleIdsToRemove.map<dynamic>((CircleId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final CircleUpdates typedOther = other;
    return setEquals(circlesToAdd, typedOther.circlesToAdd) &&
        setEquals(circleIdsToRemove, typedOther.circleIdsToRemove) &&
        setEquals(circlesToChange, typedOther.circlesToChange);
  }

  @override
  int get hashCode =>
      hashValues(circlesToAdd, circleIdsToRemove, circlesToChange);

  @override
  String toString() {
    return '_CircleUpdates{circlesToAdd: $circlesToAdd, '
        'circleIdsToRemove: $circleIdsToRemove, '
        'circlesToChange: $circlesToChange}';
  }
}
