part of google_maps_flutter;

class _OverlayUpdates {
  _OverlayUpdates();
  _OverlayUpdates.from(Set<Overlay> previous, Set<Overlay> current) {
    if (previous == null) {
      previous = Set<Overlay>.identity();
    }

    if (current == null) {
      current = Set<Overlay>.identity();
    }
    
    final Map<OverlayId, Overlay> previousOverlays = _keyByOverlayId(previous);
    final Map<OverlayId, Overlay> currentOverlays = _keyByOverlayId(current);

    final Set<OverlayId> prevOverlayIds = previousOverlays.keys.toSet();
    final Set<OverlayId> currentOverlayIds = currentOverlays.keys.toSet();

    Overlay idToCurrentOverlay(OverlayId id) {
      return currentOverlays[id];
    }

    final Set<OverlayId> _overlayIdsToRemove =
        prevOverlayIds.difference(currentOverlayIds);

    final Set<Overlay> _overlaysToAdd = currentOverlayIds
        .difference(prevOverlayIds)
        .map(idToCurrentOverlay)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Overlay current) {
      final Overlay previous = previousOverlays[current.overlayId];
      return current != previous;
    }

    final Set<Overlay> _overlaysToChange = currentOverlayIds
        .intersection(prevOverlayIds)
        .map(idToCurrentOverlay)
        .where(hasChanged)
        .toSet();

    overlaysToAdd = _overlaysToAdd;
    overlayIdsToRemove = _overlayIdsToRemove;
    overlaysToChange = _overlaysToChange;
  }

  Set<Overlay> overlaysToAdd;
  Set<OverlayId> overlayIdsToRemove;
  Set<Overlay> overlaysToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('overlaysToAdd', _serializeOverlaySet(overlaysToAdd));
    addIfNonNull('overlaysToChange', _serializeOverlaySet(overlaysToChange));
    addIfNonNull('overlayIdsToRemove',
        overlayIdsToRemove.map<dynamic>((OverlayId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _OverlayUpdates typedOther = other;
    return setEquals(overlaysToAdd, typedOther.overlaysToAdd) &&
        setEquals(overlayIdsToRemove, typedOther.overlayIdsToRemove) &&
        setEquals(overlaysToChange, typedOther.overlaysToChange);
  }

  @override
  int get hashCode =>
      hashValues(overlaysToAdd, overlayIdsToRemove, overlaysToChange);

  @override
  String toString() {
    return '_OverlayUpdates{overlaysToAdd: $overlaysToAdd, '
        'overlayIdsToRemove: $overlayIdsToRemove, '
        'overlaysToChange: $overlaysToChange}';
  }
}
