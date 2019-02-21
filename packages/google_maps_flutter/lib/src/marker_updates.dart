// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// [Marker] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class MarkerUpdates {
  MarkerUpdates.internal({
    @required this.markersToAdd,
    @required this.markerIdsToRemove,
    @required this.markersToChange,
  })  : assert(markersToAdd != null),
        assert(markerIdsToRemove != null),
        assert(markersToChange != null);

  /// Computes [MarkerUpdates] given previous and current [Marker]s.
  factory MarkerUpdates.from(Set<Marker> previous, Set<Marker> current) {
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

    final Set<MarkerId> markerIdsToRemove =
        prevMarkerIds.difference(currentMarkerIds);
    final Set<Marker> markersToAdd = currentMarkerIds
        .difference(prevMarkerIds)
        .map(idToCurrentMarker)
        .toSet();
    final Set<Marker> markersToChange = currentMarkerIds
        .intersection(prevMarkerIds)
        .map(idToCurrentMarker)
        .toSet();

    return MarkerUpdates.internal(
      markersToAdd: markersToAdd,
      markerIdsToRemove: markerIdsToRemove,
      markersToChange: markersToChange,
    );
  }

  Set<Marker> markersToAdd;
  Set<MarkerId> markerIdsToRemove;
  Set<Marker> markersToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('markersToAdd', _serializeMarkerSet(markersToAdd));
    addIfNonNull('markersToChange', _serializeMarkerSet(markersToChange));
    addIfNonNull('markerIdsToRemove',
        markerIdsToRemove.map<dynamic>((MarkerId m) => m.value));

    return updateMap;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerUpdates &&
          runtimeType == other.runtimeType &&
          setEquals(markersToAdd, other.markersToAdd) &&
          setEquals(markerIdsToRemove, other.markerIdsToRemove) &&
          setEquals(markersToChange, other.markersToChange);

  @override
  int get hashCode =>
      markersToAdd.hashCode ^
      markerIdsToRemove.hashCode ^
      markersToChange.hashCode;

  @override
  String toString() {
    return '_MarkerUpdates{markersToAdd: $markersToAdd, '
        'markerIdsToRemove: $markerIdsToRemove, '
        'markersToChange: $markersToChange}';
  }
}
