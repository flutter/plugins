// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter_platform_interface/src/types/ground_overlay.dart';

import '../types.dart';


/// Converts an [Iterable] of GroundOverlays in a Map of GroundOverlayId -> GroundOverlay.
Map<GroundOverlayId, GroundOverlay> keyByGroundOverlayId(
    Iterable<GroundOverlay> groundOverlays) {
  if (groundOverlays == null) {
    return <GroundOverlayId, GroundOverlay>{};
  }
  return Map<GroundOverlayId, GroundOverlay>.fromEntries(groundOverlays.map(
          (GroundOverlay polygon) => MapEntry<GroundOverlayId, GroundOverlay>(
          polygon.groundOverlayId, polygon.clone())));
}

/// Converts a Set of GroundOverlays into something serializable in JSON.
List<Map<String, dynamic>> serializeGroundOverlaySet(Set<GroundOverlay> groundOverlays) {
  if (groundOverlays == null) {
    return null;
  }
  return groundOverlays.map<Map<String, dynamic>>((GroundOverlay p) => p.toJson()).toList();
}