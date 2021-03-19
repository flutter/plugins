// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `PolygonController` class wraps a [gmaps.Polyline] and its `onTap` behavior.
class PolylineController {
  gmaps.Polyline _polyline;

  final bool _consumeTapEvents;

  /// Creates a `PolylineController` that wraps a [gmaps.Polyline] object and its `onTap` behavior.
  PolylineController({
    @required gmaps.Polyline polyline,
    bool consumeTapEvents = false,
    ui.VoidCallback onTap,
  })  : _polyline = polyline,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      polyline.onClick.listen((event) {
        onTap.call();
      });
    }
  }

  /// Returns the wrapped [gmaps.Polyline]. Only used for testing.
  @visibleForTesting
  gmaps.Polyline get line => _polyline;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Polyline] object.
  void update(gmaps.PolylineOptions options) {
    _polyline.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Polyline].
  void remove() {
    _polyline.visible = false;
    _polyline.map = null;
    _polyline = null;
  }
}
