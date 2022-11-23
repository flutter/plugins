// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;
import 'types.dart';

/// Uniquely identifies a [ClusterManager] among [GoogleMap] clusters.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class ClusterManagerId extends MapsObjectId<ClusterManager> {
  /// Creates an immutable identifier for a [ClusterManager].
  const ClusterManagerId(String value) : super(value);
}

/// [ClusterManager] manages marker clustering for set of [Marker]s that have
/// the same [ClusterManagerId] set.
@immutable
class ClusterManager implements MapsObject<ClusterManager> {
  /// Creates an immutable object for managing clustering for set of markers.
  const ClusterManager({
    required this.clusterManagerId,
    this.onClusterTap,
  });

  /// Uniquely identifies a [ClusterManager].
  final ClusterManagerId clusterManagerId;

  @override
  ClusterManagerId get mapsId => clusterManagerId;

  /// Callback to receive tap events for cluster markers placed on this map.
  final ArgumentCallback<Cluster>? onClusterTap;

  /// Creates a new [ClusterManager] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  ClusterManager copyWith({
    ArgumentCallback<Cluster>? onClusterTapParam,
  }) {
    return ClusterManager(
      clusterManagerId: clusterManagerId,
      onClusterTap: onClusterTapParam ?? onClusterTap,
    );
  }

  /// Creates a new [ClusterManager] object whose values are the same as this instance.
  @override
  ClusterManager clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('clusterManagerId', clusterManagerId.value);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ClusterManager &&
        clusterManagerId == other.clusterManagerId;
  }

  @override
  int get hashCode => clusterManagerId.hashCode;

  @override
  String toString() {
    return 'Cluster{clusterManagerId: $clusterManagerId, onClusterTap: $onClusterTap}';
  }
}
