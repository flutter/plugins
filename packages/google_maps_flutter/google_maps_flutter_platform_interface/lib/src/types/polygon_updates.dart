// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [Polygon] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class PolygonUpdates extends MapsObjectUpdates<Polygon> {
  /// Computes [PolygonUpdates] given previous and current [Polygon]s.
  PolygonUpdates.from(Set<Polygon> previous, Set<Polygon> current)
      : super.from(previous, current, objectName: 'polygon');

  /// Set of Polygons to be added in this update.
  Set<Polygon> get polygonsToAdd => objectsToAdd;

  /// Set of PolygonIds to be removed in this update.
  Set<PolygonId> get polygonIdsToRemove => objectIdsToRemove.cast<PolygonId>();

  /// Set of Polygons to be changed in this update.
  Set<Polygon> get polygonsToChange => objectsToChange;
}
