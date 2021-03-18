// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `PolygonController` class wraps a [gmaps.Polygon] and its `onTap` behavior.
class PolygonController {
  gmaps.Polygon _polygon;

  final bool _consumeTapEvents;

  /// Creates a `PolygonController` that wraps a [gmaps.Polygon] object and its `onTap` behavior.
  PolygonController({
    @required gmaps.Polygon polygon,
    bool consumeTapEvents = false,
    ui.VoidCallback onTap,
  })  : _polygon = polygon,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      polygon.onClick.listen((event) {
        onTap.call();
      });
    }
  }

  /// Returns the wrapped [gmaps.Polygon]. Only used for testing.
  @visibleForTesting
  gmaps.Polygon get polygon => _polygon;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Polygon] object.
  void update(gmaps.PolygonOptions options) {
    _polygon.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Polygon].
  void remove() {
    _polygon.visible = false;
    _polygon.map = null;
    _polygon = null;
  }
}
