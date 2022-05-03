// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `HeatmapController` class wraps a [gmaps_visualization.HeatmapLayer] and its `onTap` behavior.
class HeatmapController {
  gmaps_visualization.HeatmapLayer? _heatmap;

  /// Creates a `HeatmapController`, which wraps a [gmaps_visualization.HeatmapLayer] object and its `onTap` behavior.
  HeatmapController({required gmaps_visualization.HeatmapLayer heatmap})
      : _heatmap = heatmap;

  /// Returns the wrapped [gmaps_visualization.HeatmapLayer]. Only used for testing.
  @visibleForTesting
  gmaps_visualization.HeatmapLayer? get heatmap => _heatmap;

  /// Updates the options of the wrapped [gmaps_visualization.HeatmapLayer] object.
  ///
  /// This cannot be called after [remove].
  void update(gmaps_visualization.HeatmapLayerOptions options) {
    assert(_heatmap != null, 'Cannot `update` Heatmap after calling `remove`.');
    _heatmap!.options = options;
  }

  /// Disposes of the currently wrapped [gmaps_visualization.HeatmapLayer].
  void remove() {
    if (_heatmap != null) {
      _heatmap!.map = null;
      _heatmap = null;
    }
  }
}
