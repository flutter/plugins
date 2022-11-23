// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Converts a Set of Cluster Managers into object serializable in JSON.
Object serializeClusterManagerSet(Set<ClusterManager> clusterManagers) {
  return clusterManagers
      .map<Object>((ClusterManager cm) => serializeClusterManager(cm))
      .toList();
}

/// Converts a Cluster Manager into object serializable in JSON.
Object serializeClusterManager(ClusterManager clusterManager) {
  final Map<String, Object> json = <String, Object>{};
  json['clusterManagerId'] = clusterManager.clusterManagerId.value;
  return json;
}

/// Converts a Cluster Manager updates into object serializable in JSON.
Object serializeClusterManagerUpdates(
    ClusterManagerUpdates clusterManagerUpdates) {
  final Map<String, Object> updateMap = <String, Object>{};

  updateMap['clusterManagersToAdd'] =
      serializeClusterManagerSet(clusterManagerUpdates.objectsToAdd);
  updateMap['clusterManagerIdsToRemove'] = clusterManagerUpdates
      .objectIdsToRemove
      .map<String>((MapsObjectId<ClusterManager> id) => id.value)
      .toList();

  return updateMap;
}
