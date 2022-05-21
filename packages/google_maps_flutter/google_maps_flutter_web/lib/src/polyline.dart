// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `PolygonController` class wraps a [gmaps.Polyline] and its `onTap` behavior.
class PolylineController {
  /// Creates a `PolylineController` that wraps a [gmaps.Polyline] object and its `onTap` behavior.
  PolylineController({
    required gmaps.Polyline polyline,
    bool consumeTapEvents = false,
    ui.VoidCallback? onTap,
  })  : _polyline = polyline,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      polyline.onClick.listen((gmaps.PolyMouseEvent event) {
        onTap.call();
      });
    }
  }

  gmaps.Polyline? _polyline;

  final bool _consumeTapEvents;

  /// Returns the wrapped [gmaps.Polyline]. Only used for testing.
  @visibleForTesting
  gmaps.Polyline? get line => _polyline;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Polyline] object.
  ///
  /// This cannot be called after [remove].
  void update(gmaps.PolylineOptions options) {
    assert(
        _polyline != null, 'Cannot `update` Polyline after calling `remove`.');
    _polyline!.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Polyline].
  void remove() {
    if (_polyline != null) {
      _polyline!.visible = false;
      _polyline!.map = null;
      _polyline = null;
    }
  }
}
