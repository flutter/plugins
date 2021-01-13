// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show setEquals;

import 'utils/tile_overlay.dart';
import 'types.dart';

/// Represents the details of an update events of [TileOverlay]s.
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

    _tileOverlayIdsToRemove =
        prevTileOverlayIds.difference(currentTileOverlayIds);

    _tileOverlaysToAdd = currentTileOverlayIds
        .difference(prevTileOverlayIds)
        .map(idToCurrentTileOverlay)
        .toSet();

    // Returns `true` if [current] is not equals to previous one with the
    // same id.
    bool hasChanged(TileOverlay current) {
      final TileOverlay previous = previousTileOverlays[current.tileOverlayId];
      return current != previous;
    }

    _tileOverlaysToChange = currentTileOverlayIds
        .intersection(prevTileOverlayIds)
        .map(idToCurrentTileOverlay)
        .where(hasChanged)
        .toSet();
  }

  /// Set of TileOverlays to be added in this update.
  Set<TileOverlay> get tileOverlaysToAdd {
    return _tileOverlaysToAdd;
  }

  Set<TileOverlay> _tileOverlaysToAdd;

  /// Set of TileOverlayIds to be removed in this update.
  Set<TileOverlayId> get tileOverlayIdsToRemove {
    return _tileOverlayIdsToRemove;
  }

  Set<TileOverlayId> _tileOverlayIdsToRemove;

  /// Set of TileOverlays to be changed in this update.
  Set<TileOverlay> get tileOverlaysToChange {
    return _tileOverlaysToChange;
  }

  Set<TileOverlay> _tileOverlaysToChange;

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull(
        'tileOverlaysToAdd', serializeTileOverlaySet(_tileOverlaysToAdd));
    addIfNonNull(
        'tileOverlaysToChange', serializeTileOverlaySet(_tileOverlaysToChange));
    addIfNonNull(
        'tileOverlayIdsToRemove',
        _tileOverlayIdsToRemove
            .map<dynamic>((TileOverlayId m) => m.value)
            .toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final TileOverlayUpdates typedOther = other;
    return setEquals(_tileOverlaysToAdd, typedOther._tileOverlaysToAdd) &&
        setEquals(
            _tileOverlayIdsToRemove, typedOther._tileOverlayIdsToRemove) &&
        setEquals(_tileOverlaysToChange, typedOther._tileOverlaysToChange);
  }

  @override
  int get hashCode =>
      _tileOverlaysToAdd.hashCode ^
      _tileOverlayIdsToRemove.hashCode ^
      _tileOverlaysToChange.hashCode;

  @override
  String toString() {
    return 'TileOverlayUpdates{tileOverlaysToAdd: $_tileOverlaysToAdd, '
        'tileOverlayIdsToRemove: $_tileOverlayIdsToRemove, '
        'tileOverlaysToChange: $_tileOverlaysToChange}';
  }
}
