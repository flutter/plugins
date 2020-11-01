part of google_maps_flutter;

/// [TileProvider] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class _TileOverlayUpdates {
  /// Computes [_MarkerUpdates] given previous and current [Marker]s.
  _TileOverlayUpdates.from(
      Set<TileOverlay> previous, Set<TileOverlay> current) {
    if (previous == null) {
      previous = Set<TileOverlay>.identity();
    }

    if (current == null) {
      current = Set<TileOverlay>.identity();
    }

    final Map<TileOverlayId, TileOverlay> previousTileOverlays =
        _keyTileOverlayId(previous);
    final Map<TileOverlayId, TileOverlay> currentTileOverlays =
        _keyTileOverlayId(current);

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

  Set<TileOverlay> tileOverlaysToAdd;
  Set<TileOverlayId> tileOverlayIdsToRemove;
  Set<TileOverlay> tileOverlaysToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull(
        'tileOverlaysToAdd', _serializeTileOverlaySet(tileOverlaysToAdd));
    addIfNonNull(
        'tileOverlaysToChange', _serializeTileOverlaySet(tileOverlaysToChange));
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
    final _TileOverlayUpdates typedOther = other;
    return setEquals(tileOverlaysToAdd, typedOther.tileOverlaysToAdd) &&
        setEquals(tileOverlayIdsToRemove, typedOther.tileOverlayIdsToRemove) &&
        setEquals(tileOverlaysToChange, typedOther.tileOverlaysToChange);
  }

  @override
  int get hashCode => hashValues(
      tileOverlaysToAdd, tileOverlayIdsToRemove, tileOverlaysToChange);

  @override
  String toString() {
    return '_TileOverlayUpdates{tileOverlaysToAdd: $tileOverlaysToAdd, '
        'tileOverlayIdsToRemove: $tileOverlayIdsToRemove, '
        'tileOverlaysToChange: $tileOverlaysToChange}';
  }
}
