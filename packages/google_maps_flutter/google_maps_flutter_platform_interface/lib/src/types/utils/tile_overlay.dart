// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of TileOverlay in a Map of TileOverlayId -> TileOverlay.
Map<TileOverlayId, TileOverlay> keyTileOverlayId(
    Iterable<TileOverlay> tileOverlays) {
  return keyByMapsObjectId<TileOverlay>(tileOverlays)
      .cast<TileOverlayId, TileOverlay>();
}

/// Converts a Set of TileOverlays into something serializable in JSON.
Object serializeTileOverlaySet(Set<TileOverlay> tileOverlays) {
  return serializeMapsObjectSet(tileOverlays);
}
