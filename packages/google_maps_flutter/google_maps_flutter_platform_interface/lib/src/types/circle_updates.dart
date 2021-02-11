// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [Circle] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class CircleUpdates extends MapsObjectUpdates<Circle> {
  /// Computes [CircleUpdates] given previous and current [Circle]s.
  CircleUpdates.from(Set<Circle> previous, Set<Circle> current)
      : super.from(previous, current, objectName: 'circle');

  /// Set of Circles to be added in this update.
  Set<Circle> get circlesToAdd => objectsToAdd;

  /// Set of CircleIds to be removed in this update.
  Set<CircleId> get circleIdsToRemove => objectIdsToRemove.cast<CircleId>();

  /// Set of Circles to be changed in this update.
  Set<Circle> get circlesToChange => objectsToChange;
}
