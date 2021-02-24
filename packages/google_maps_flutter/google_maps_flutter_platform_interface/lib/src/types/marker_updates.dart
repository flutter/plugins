// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [Marker] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class MarkerUpdates extends MapsObjectUpdates<Marker> {
  /// Computes [MarkerUpdates] given previous and current [Marker]s.
  MarkerUpdates.from(Set<Marker> previous, Set<Marker> current)
      : super.from(previous, current, objectName: 'marker');

  /// Set of Markers to be added in this update.
  Set<Marker> get markersToAdd => objectsToAdd;

  /// Set of MarkerIds to be removed in this update.
  Set<MarkerId> get markerIdsToRemove => objectIdsToRemove.cast<MarkerId>();

  /// Set of Markers to be changed in this update.
  Set<Marker> get markersToChange => objectsToChange;
}
