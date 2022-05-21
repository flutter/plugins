// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `HeatmapController` class wraps a [visualization.HeatmapLayer] and its `onTap` behavior.
class HeatmapController {
  /// Creates a `HeatmapController`, which wraps a [visualization.HeatmapLayer] object and its `onTap` behavior.
  HeatmapController({required visualization.HeatmapLayer heatmap})
      : _heatmap = heatmap;

  visualization.HeatmapLayer? _heatmap;

  /// Returns the wrapped [visualization.HeatmapLayer]. Only used for testing.
  @visibleForTesting
  visualization.HeatmapLayer? get heatmap => _heatmap;

  /// Updates the options of the wrapped [visualization.HeatmapLayer] object.
  ///
  /// This cannot be called after [remove].
  void update(visualization.HeatmapLayerOptions options) {
    assert(_heatmap != null, 'Cannot `update` Heatmap after calling `remove`.');
    _heatmap!.options = options;
  }

  /// Disposes of the currently wrapped [visualization.HeatmapLayer].
  void remove() {
    if (_heatmap != null) {
      _heatmap!.map = null;
      _heatmap = null;
    }
  }
}
