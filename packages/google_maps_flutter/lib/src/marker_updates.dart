// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Types of [Marker] updates.
enum MarkerUpdateEventType {
  add,
  update,
  remove,
}

Map<MarkerId, Marker> _toMap(Set<Marker> markers) {
  final Map<MarkerId, Marker> result = <MarkerId, Marker>{};
  if (markers == null) {
    return null;
  }
  markers.forEach((Marker marker) {
    if (marker != null) {
      result[marker.markerId] = marker;
    }
  });
  return result;
}

/// [Marker] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
@immutable
class MarkerUpdates {
  @visibleForTesting
  MarkerUpdates.internal({
    @required this.markerUpdates,
  }) : assert(markerUpdates != null);

  /// Computes [MarkerUpdates] given previous and current [Marker]s.
  factory MarkerUpdates.from(Set<Marker> previous, Set<Marker> current) {
    if (previous == null) {
      previous = Set<Marker>.identity();
    }

    if (current == null) {
      current = Set<Marker>.identity();
    }

    final Map<MarkerId, Marker> previousMarkers = _toMap(previous);
    final Map<MarkerId, Marker> currentMarkers = _toMap(current);

    final Set<MarkerId> allMarkerIds =
        previousMarkers.keys.toSet().union(currentMarkers.keys.toSet());

    final Set<MarkerUpdate> markerUpdates = allMarkerIds.map(
      (MarkerId markerId) {
        final bool inCurrent = currentMarkers.containsKey(markerId);
        final bool inPrevious = previousMarkers.containsKey(markerId);

        if (inCurrent && inPrevious) {
          return MarkerUpdate._update(
            oldMarker: previousMarkers[markerId],
            newMarker: currentMarkers[markerId],
          );
        } else if (inCurrent) {
          return MarkerUpdate._add(currentMarkers[markerId]);
        } else if (inPrevious) {
          return MarkerUpdate._remove(markerId);
        } else {
          throw FlutterError("Unknown markerId: " + markerId.value);
        }
      },
    ).toSet();

    return MarkerUpdates.internal(markerUpdates: markerUpdates);
  }

  final Set<MarkerUpdate> markerUpdates;

  dynamic _toJson() {
    return markerUpdates
        .map<dynamic>((MarkerUpdate update) => update._toMap())
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerUpdates &&
          runtimeType == other.runtimeType &&
          markerUpdates == other.markerUpdates;

  @override
  int get hashCode => markerUpdates.hashCode;

  @override
  String toString() {
    return 'MarkerUpdates{markerUpdates: $markerUpdates}';
  }
}

/// [Marker] update event with the changes.
@immutable
class MarkerUpdate {
  @visibleForTesting
  MarkerUpdate.internal({
    @required this.updateEventType,
    @required this.markerId,
    this.changes,
    this.newMarker,
  })  : assert(updateEventType != null),
        assert(markerId != null),
        assert(markerId.value != null);

  factory MarkerUpdate._remove(MarkerId markerId) {
    return MarkerUpdate.internal(
      updateEventType: MarkerUpdateEventType.remove,
      markerId: markerId,
    );
  }

  factory MarkerUpdate._add(Marker newMarker) {
    return MarkerUpdate.internal(
      updateEventType: MarkerUpdateEventType.add,
      markerId: newMarker.markerId,
      changes: newMarker,
      newMarker: newMarker,
    );
  }

  /// TODO (kaushik) diff is sufficient, don't need to send the whole update.
  factory MarkerUpdate._update({
    @required Marker oldMarker,
    @required Marker newMarker,
  }) {
    assert(oldMarker.markerId == newMarker.markerId);
    return MarkerUpdate.internal(
      updateEventType: MarkerUpdateEventType.update,
      markerId: newMarker.markerId,
      changes: newMarker,
      newMarker: newMarker,
    );
  }

  final MarkerUpdateEventType updateEventType;
  final MarkerId markerId;
  final Marker changes;
  final Marker newMarker;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('updateEventType', updateEventType.toString());
    addIfNonNull('markerId', markerId.value);
    addIfNonNull('changes', changes?._toJson());

    return updateMap;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerUpdate &&
          runtimeType == other.runtimeType &&
          updateEventType == other.updateEventType &&
          markerId == other.markerId &&
          changes == other.changes &&
          newMarker == other.newMarker;

  @override
  int get hashCode =>
      updateEventType.hashCode ^
      markerId.hashCode ^
      changes.hashCode ^
      newMarker.hashCode;

  @override
  String toString() {
    return 'MarkerUpdate{updateEventType: $updateEventType, markerId: $markerId, '
        'changes: $changes, newMarker: $newMarker}';
  }
}
