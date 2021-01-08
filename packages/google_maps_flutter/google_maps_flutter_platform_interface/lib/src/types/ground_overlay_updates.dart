// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:google_maps_flutter_platform_interface/src/types/ground_overlay.dart';

import 'types.dart';
import 'utils/ground_overlay.dart';

/// [GroundOverlay] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class GroundOverlayUpdates {
  /// Computes [GroundOverlayUpdates] given previous and current [GroundOverlay]s.
  GroundOverlayUpdates.from(Set<GroundOverlay> previous, Set<GroundOverlay> current) {
    if (previous == null) {
      previous = Set<GroundOverlay>.identity();
    }

    if (current == null) {
      current = Set<GroundOverlay>.identity();
    }

    final Map<GroundOverlayId, GroundOverlay> previousGroundOverlays = keyByGroundOverlayId(previous);
    final Map<GroundOverlayId, GroundOverlay> currentGroundOverlays = keyByGroundOverlayId(current);

    final Set<GroundOverlayId> prevGroundOverlayIds = previousGroundOverlays.keys.toSet();
    final Set<GroundOverlayId> currentGroundOverlayIds = currentGroundOverlays.keys.toSet();

    GroundOverlay idToCurrentGroundOverlay(GroundOverlayId id) {
      return currentGroundOverlays[id];
    }

    final Set<GroundOverlayId> _groundOverlayIdsToRemove =
    prevGroundOverlayIds.difference(currentGroundOverlayIds);

    final Set<GroundOverlay> _groundOverlaysToAdd = currentGroundOverlayIds
        .difference(prevGroundOverlayIds)
        .map(idToCurrentGroundOverlay)
        .toSet();


    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(GroundOverlay current) {
      final GroundOverlay previous = previousGroundOverlays[current.groundOverlayId];
      return current != previous;
    }

    final Set<GroundOverlay> _groundOverlaysToChange = currentGroundOverlayIds
        .intersection(prevGroundOverlayIds)
        .map(idToCurrentGroundOverlay)
        .where(hasChanged)
        .toSet();

    groundOverlaysToAdd = _groundOverlaysToAdd;
    groundOverlayIdsToRemove = _groundOverlayIdsToRemove;
    groundOverlaysToChange = _groundOverlaysToChange;
  }

  /// Set of GroundOverlays to be added in this update.
  Set<GroundOverlay> groundOverlaysToAdd;

  /// Set of GroundOverlayIds to be removed in this update.
  Set<GroundOverlayId> groundOverlayIdsToRemove;

  /// Set of GroundOverlays to be changed in this update.
  Set<GroundOverlay> groundOverlaysToChange;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('groundOverlaysToAdd', serializeGroundOverlaySet(groundOverlaysToAdd));
    addIfNonNull('groundOverlaysToChange', serializeGroundOverlaySet(groundOverlaysToChange));
    addIfNonNull('groundOverlayIdsToRemove',
        groundOverlayIdsToRemove.map<dynamic>((GroundOverlayId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final GroundOverlayUpdates typedOther = other;
    return setEquals(groundOverlaysToAdd, typedOther.groundOverlaysToAdd) &&
        setEquals(groundOverlayIdsToRemove, typedOther.groundOverlayIdsToRemove) &&
        setEquals(groundOverlaysToChange, typedOther.groundOverlaysToChange);
  }

  @override
  int get hashCode =>
      hashValues(groundOverlaysToAdd, groundOverlayIdsToRemove, groundOverlaysToChange);

  @override
  String toString() {
    return '_GroundOverlayUpdates{groundOverlaysToAdd: $groundOverlaysToAdd, '
        'groundOverlayIdsToRemove: $groundOverlayIdsToRemove, '
        'groundOverlaysToChange: $groundOverlaysToChange}';
  }
}