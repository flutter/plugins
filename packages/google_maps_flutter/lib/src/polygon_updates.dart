// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// [Polygon] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class _PolygonUpdates extends _OverlayUpdates {
  /// Computes [_PolygonUpdates] given previous and current [Polygon]s.
  _PolygonUpdates.from(Set<Polygon> previous, Set<Polygon> current) 
      : super.from(previous, current);
}
