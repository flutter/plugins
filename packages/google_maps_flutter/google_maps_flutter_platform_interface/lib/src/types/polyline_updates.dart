// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [Polyline] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class PolylineUpdates extends MapsObjectUpdates<Polyline> {
  /// Computes [PolylineUpdates] given previous and current [Polyline]s.
  PolylineUpdates.from(Set<Polyline> previous, Set<Polyline> current)
      : super.from(previous, current, objectName: 'polyline');

  /// Set of Polylines to be added in this update.
  Set<Polyline> get polylinesToAdd => objectsToAdd;

  /// Set of PolylineIds to be removed in this update.
  Set<PolylineId> get polylineIdsToRemove =>
      objectIdsToRemove.cast<PolylineId>();

  /// Set of Polylines to be changed in this update.
  Set<Polyline> get polylinesToChange => objectsToChange;
}
