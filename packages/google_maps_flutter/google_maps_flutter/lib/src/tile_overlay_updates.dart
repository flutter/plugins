part of google_maps_flutter;

class _TileOverlayUpdates {
  _TileOverlayUpdates.from(List<TileOverlay> previous, List<TileOverlay> current) {
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

  List<TileOverlay> toAdd;
  List<TileOverlay> toChange;
  List<TileOverlay> toRemove;

  Map<String, dynamic> _toMap() {
    return {
      'tilesToAdd': List<dynamic>.from(toAdd.map((x) => x._toMap())),
      'tilesToChange': List<dynamic>.from(toChange.map((x) => x._toMap())),
      'tilesToRemove': List<dynamic>.from(toRemove.map((x) => x._toMap())),
    };
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is _TileOverlayUpdates &&
      listEquals(o.toAdd, toAdd) &&
      listEquals(o.toChange, toChange) &&
      listEquals(o.toRemove, toRemove);
  }

  @override
  int get hashCode => toAdd.hashCode ^ toChange.hashCode ^ toRemove.hashCode;

  @override
  String toString() => '_TileOverlayUpdates(toAdd: $toAdd, toChange: $toChange, toRemove: $toRemove)';
}
