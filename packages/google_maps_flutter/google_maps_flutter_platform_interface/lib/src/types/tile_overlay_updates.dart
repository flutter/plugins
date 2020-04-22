import 'package:flutter/foundation.dart';

import 'types.dart';

/// [TileOverlay] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class TileOverlayUpdates {
  /// Computes [TileOverlayUpdates] given previous and current [TileOverlay]s.
  TileOverlayUpdates.from(List<TileOverlay> previous, List<TileOverlay> current) {
    previous ??= <TileOverlay>[];
    current ??= <TileOverlay>[];

    final List<TileOverlay> toAdd = [];
    final List<TileOverlay> toChange = [];
    final List<TileOverlay> toRemove = [];

    for (final overlay in current) {
      bool didFindPrevious = false;
      for (final prevOverlay in previous) {
        if (overlay.url == prevOverlay.url) {
          didFindPrevious = true;
          if (overlay != prevOverlay) {
            toChange.add(overlay);
          }
          break;
        }
      }

      if (!didFindPrevious) {
        toAdd.add(overlay);
      }
    }

    for (final prevOverlay in previous) {
      bool containsOverlay = false;
      for (final overlay in current) {
        if (overlay.url == prevOverlay.url) {
          containsOverlay = true;
          break;
        }
      }

      if (!containsOverlay) {
        toRemove.add(prevOverlay);
      }
    }

    this.toAdd = toAdd;
    this.toChange = toChange;
    this.toRemove = toRemove;
  }

  /// List of TileOverlays to be added in this update.
  List<TileOverlay> toAdd;

  /// List of TileOverlays to be changed in this update.
  List<TileOverlay> toChange;

  /// List of TileOverlays to be removed in this update.
  List<TileOverlay> toRemove;

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toMap() {
    return {
      'tilesToAdd': List<dynamic>.from(toAdd.map((x) => x.toMap())),
      'tilesToChange': List<dynamic>.from(toChange.map((x) => x.toMap())),
      'tilesToRemove': List<dynamic>.from(toRemove.map((x) => x.toMap())),
    };
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TileOverlayUpdates &&
        listEquals(o.toAdd, toAdd) &&
        listEquals(o.toChange, toChange) &&
        listEquals(o.toRemove, toRemove);
  }

  @override
  int get hashCode => toAdd.hashCode ^ toChange.hashCode ^ toRemove.hashCode;

  @override
  String toString() => '_TileOverlayUpdates(toAdd: $toAdd, toChange: $toChange, toRemove: $toRemove)';
}
