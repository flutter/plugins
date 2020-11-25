// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart' show setEquals;

import 'utils/tile_overlay.dart';
import 'types.dart';

/// [TileProvider] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class TileOverlayUpdates {
  /// Computes [TileOverlayUpdates] given previous and current [TileOverlay]s.
  TileOverlayUpdates.from(Set<TileOverlay> previous, Set<TileOverlay> current) {
    if (previous == null) {
      previous = Set<TileOverlay>.identity();
    }

    if (current == null) {
      current = Set<TileOverlay>.identity();
    }

    final Map<TileOverlayId, TileOverlay> previousTileOverlays =
        keyTileOverlayId(previous);
    final Map<TileOverlayId, TileOverlay> currentTileOverlays =
        keyTileOverlayId(current);

    final Set<TileOverlayId> prevTileOverlayIds =
        previousTileOverlays.keys.toSet();
    final Set<TileOverlayId> currentTileOverlayIds =
        currentTileOverlays.keys.toSet();

    TileOverlay idToCurrentTileOverlay(TileOverlayId id) {
      return currentTileOverlays[id];
    }

    final Set<TileOverlayId> _tileOverlayIdsToRemove =
        prevTileOverlayIds.difference(currentTileOverlayIds);

    final Set<TileOverlay> _tileOverlaysToAdd = currentTileOverlayIds
        .difference(prevTileOverlayIds)
        .map(idToCurrentTileOverlay)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(TileOverlay current) {
      final TileOverlay previous = previousTileOverlays[current.tileOverlayId];
      return current != previous;
    }

    final Set<TileOverlay> _tileOverlaysToChange = currentTileOverlayIds
        .intersection(prevTileOverlayIds)
        .map(idToCurrentTileOverlay)
        .where(hasChanged)
        .toSet();

    tileOverlaysToAdd = _tileOverlaysToAdd;
    tileOverlayIdsToRemove = _tileOverlayIdsToRemove;
    tileOverlaysToChange = _tileOverlaysToChange;
  }

  /// Set of TileOverlays to be added in this update.
  Set<TileOverlay> tileOverlaysToAdd;

  /// Set of TileOverlayIds to be removed in this update.
  Set<TileOverlayId> tileOverlayIdsToRemove;

  /// Set of TileOverlays to be changed in this update.
  Set<TileOverlay> tileOverlaysToChange;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull(
        'tileOverlaysToAdd', serializeTileOverlaySet(tileOverlaysToAdd));
    addIfNonNull(
        'tileOverlaysToChange', serializeTileOverlaySet(tileOverlaysToChange));
    addIfNonNull(
        'tileOverlayIdsToRemove',
        tileOverlayIdsToRemove
            .map<dynamic>((TileOverlayId m) => m.value)
            .toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final TileOverlayUpdates typedOther = other;
    return setEquals(tileOverlaysToAdd, typedOther.tileOverlaysToAdd) &&
        setEquals(tileOverlayIdsToRemove, typedOther.tileOverlayIdsToRemove) &&
        setEquals(tileOverlaysToChange, typedOther.tileOverlaysToChange);
  }

  @override
  int get hashCode => hashValues(
      tileOverlaysToAdd, tileOverlayIdsToRemove, tileOverlaysToChange);

  @override
  String toString() {
    return 'TileOverlayUpdates{tileOverlaysToAdd: $tileOverlaysToAdd, '
        'tileOverlayIdsToRemove: $tileOverlayIdsToRemove, '
        'tileOverlaysToChange: $tileOverlaysToChange}';
  }
}
