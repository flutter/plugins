// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;

import 'types.dart';
import 'utils/marker.dart';

/// [Marker] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class MarkerUpdates {
  /// Computes [MarkerUpdates] given previous and current [Marker]s.
  MarkerUpdates.from(Set<Marker> previous, Set<Marker> current) {
    if (previous == null) {
      previous = Set<Marker>.identity();
    }

    if (current == null) {
      current = Set<Marker>.identity();
    }

    final Map<MarkerId, Marker> previousMarkers = keyByMarkerId(previous);
    final Map<MarkerId, Marker> currentMarkers = keyByMarkerId(current);

    final Set<MarkerId> prevMarkerIds = previousMarkers.keys.toSet();
    final Set<MarkerId> currentMarkerIds = currentMarkers.keys.toSet();

    Marker idToCurrentMarker(MarkerId id) {
      return currentMarkers[id];
    }

    final Set<MarkerId> _markerIdsToRemove =
        prevMarkerIds.difference(currentMarkerIds);

    final Set<Marker> _markersToAdd = currentMarkerIds
        .difference(prevMarkerIds)
        .map(idToCurrentMarker)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Marker current) {
      final Marker previous = previousMarkers[current.markerId];
      return current != previous;
    }

    final Set<Marker> _markersToChange = currentMarkerIds
        .intersection(prevMarkerIds)
        .map(idToCurrentMarker)
        .where(hasChanged)
        .toSet();

    markersToAdd = _markersToAdd;
    markerIdsToRemove = _markerIdsToRemove;
    markersToChange = _markersToChange;
  }

  /// Set of Markers to be added in this update.
  Set<Marker> markersToAdd;

  /// Set of MarkerIds to be removed in this update.
  Set<MarkerId> markerIdsToRemove;

  /// Set of Markers to be changed in this update.
  Set<Marker> markersToChange;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('markersToAdd', serializeMarkerSet(markersToAdd));
    addIfNonNull('markersToChange', serializeMarkerSet(markersToChange));
    addIfNonNull('markerIdsToRemove',
        markerIdsToRemove.map<dynamic>((MarkerId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final MarkerUpdates typedOther = other;
    return setEquals(markersToAdd, typedOther.markersToAdd) &&
        setEquals(markerIdsToRemove, typedOther.markerIdsToRemove) &&
        setEquals(markersToChange, typedOther.markersToChange);
  }

  @override
  int get hashCode =>
      hashValues(markersToAdd, markerIdsToRemove, markersToChange);

  @override
  String toString() {
    return '_MarkerUpdates{markersToAdd: $markersToAdd, '
        'markerIdsToRemove: $markerIdsToRemove, '
        'markersToChange: $markersToChange}';
  }
}
