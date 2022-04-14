// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `HeatmapLayerController` class wraps a [gmaps_visualization.HeatmapLayer] and its `onTap` behavior.
class HeatmapLayerController {
  gmaps_visualization.HeatmapLayer? _heatmapLayer;

  /// Creates a `HeatmapLayerController`, which wraps a [gmaps_visualization.HeatmapLayer] object and its `onTap` behavior.
  HeatmapLayerController({required gmaps_visualization.HeatmapLayer heatmapLayer})
      : _heatmapLayer = heatmapLayer;

  /// Returns the wrapped [gmaps_visualization.HeatmapLayer]. Only used for testing.
  @visibleForTesting
  gmaps_visualization.HeatmapLayer? get heatmapLayer => _heatmapLayer;

  /// Updates the options of the wrapped [gmaps_visualization.HeatmapLayer] object.
  ///
  /// This cannot be called after [remove].
  void update(gmaps_visualization.HeatmapLayerOptions options) {
    assert(_heatmapLayer != null,
        'Cannot `update` HeatmapLayer after calling `remove`.');
    _heatmapLayer!.options = options;
  }

  /// Disposes of the currently wrapped [gmaps_visualization.HeatmapLayer].
  void remove() {
    if (_heatmapLayer != null) {
      _heatmapLayer!.map = null;
      _heatmapLayer = null;
    }
  }
}
