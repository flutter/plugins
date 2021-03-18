// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps/google_maps.dart' as gmaps;

/// A void function that handles a [gmaps.LatLng] as a parameter.
///
/// Similar to [ui.VoidCallback], but specific for Marker drag events.
typedef LatLngCallback = void Function(gmaps.LatLng latLng);

/// The base class for all "geometry" group controllers.
///
/// This lets all Geometry controllers ([MarkersController], [CirclesController],
/// [PolygonsController], [PolylinesController]) to be bound to a [gmaps.GMap]
/// instance and our internal `mapId` value.
abstract class GeometryController {
  /// The GMap instance that this controller operates on.
  gmaps.GMap googleMap;

  /// The map ID for events.
  int mapId;

  /// Binds a `mapId` and the [gmaps.GMap] instance to this controller.
  void bindToMap(int mapId, gmaps.GMap googleMap) {
    this.mapId = mapId;
    this.googleMap = googleMap;
  }
}
