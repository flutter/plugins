// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

import 'types.dart';

/// A container object for all the types of maps objects.
///
/// This is intended for use as a parameter in platform interface methods, to
/// allow adding new object types to existing methods.
@immutable
class MapObjects {
  /// Creates a new set of map objects with all the given object types.
  const MapObjects({
    this.markers = const <Marker>{},
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.tileOverlays = const <TileOverlay>{},
    this.clusterManagers = const <ClusterManager>{},
  });

  final Set<Marker> markers;
  final Set<Polygon> polygons;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final Set<TileOverlay> tileOverlays;
  final Set<ClusterManager> clusterManagers;
}
