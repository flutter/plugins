// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// [ClusterManager] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
// (Do not re-export)
class ClusterManagerUpdates extends MapsObjectUpdates<ClusterManager> {
  /// Computes [ClusterManagerUpdates] given previous and current [ClusterManager]s.
  ClusterManagerUpdates.from(
      Set<ClusterManager> previous, Set<ClusterManager> current)
      : super.from(previous, current, objectName: 'clusterManager');

  /// Set of Clusters to be added in this update.
  Set<ClusterManager> get clusterManagersToAdd => objectsToAdd;

  /// Set of ClusterManagerIds to be removed in this update.
  Set<ClusterManagerId> get clusterManagerIdsToRemove =>
      objectIdsToRemove.cast<ClusterManagerId>();

  /// Set of Clusters to be changed in this update.
  Set<ClusterManager> get clusterManagersToChange => objectsToChange;
}
