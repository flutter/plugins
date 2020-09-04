// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `CircleController` class wraps a [gmaps.Circle] and its `onTap` behavior.
class CircleController {
  gmaps.Circle _circle;

  final bool _consumeTapEvents;

  /// Creates a `CircleController`, which wraps a [gmaps.Circle] object and its `onTap` behavior.
  CircleController({
    @required gmaps.Circle circle,
    bool consumeTapEvents = false,
    ui.VoidCallback onTap,
  })  : _circle = circle,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      circle.onClick.listen((_) {
        onTap.call();
      });
    }
  }

  /// Returns the wrapped [gmaps.Circle]. Only used for testing.
  @visibleForTesting
  gmaps.Circle get circle => _circle;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Circle] object.
  void update(gmaps.CircleOptions options) {
    _circle.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Circle].
  void remove() {
    _circle.visible = false;
    _circle.radius = 0;
    _circle.map = null;
    _circle = null;
  }
}
