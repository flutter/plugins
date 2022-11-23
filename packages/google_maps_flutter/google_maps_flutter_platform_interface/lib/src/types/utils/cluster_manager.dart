// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of Cluster Managers in a Map of ClusterManagerId -> Cluster.
Map<ClusterManagerId, ClusterManager> keyByClusterManagerId(
    Iterable<ClusterManager> clusterManagers) {
  return keyByMapsObjectId<ClusterManager>(clusterManagers)
      .cast<ClusterManagerId, ClusterManager>();
}
