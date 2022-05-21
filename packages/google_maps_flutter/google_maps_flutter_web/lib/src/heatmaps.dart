// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages all the [HeatmapController]s associated to a [GoogleMapController].
class HeatmapsController extends GeometryController {
  /// Initialize the cache
  HeatmapsController()
      : _heatmapIdToController = <HeatmapId, HeatmapController>{};

  // A cache of [HeatmapController]s indexed by their [HeatmapId].
  final Map<HeatmapId, HeatmapController> _heatmapIdToController;

  /// Returns the cache of [HeatmapController]s. Test only.
  @visibleForTesting
  Map<HeatmapId, HeatmapController> get heatmaps => _heatmapIdToController;

  /// Adds a set of [Heatmap] objects to the cache.
  ///
  /// Wraps each [Heatmap] into its corresponding [HeatmapController].
  void addHeatmaps(Set<Heatmap> heatmapsToAdd) {
    heatmapsToAdd.forEach(_addHeatmap);
  }

  void _addHeatmap(Heatmap heatmap) {
    if (heatmap == null) {
      return;
    }

    final visualization.HeatmapLayerOptions heatmapOptions =
        _heatmapOptionsFromHeatmap(heatmap);
    final visualization.HeatmapLayer gmHeatmap =
        visualization.HeatmapLayer(heatmapOptions);
    gmHeatmap.map = googleMap;
    final HeatmapController controller = HeatmapController(heatmap: gmHeatmap);
    _heatmapIdToController[heatmap.heatmapId] = controller;
  }

  /// Updates a set of [Heatmap] objects with new options.
  void changeHeatmaps(Set<Heatmap> heatmapsToChange) {
    heatmapsToChange.forEach(_changeHeatmap);
  }

  void _changeHeatmap(Heatmap heatmap) {
    final HeatmapController? heatmapController =
        _heatmapIdToController[heatmap.heatmapId];
    heatmapController?.update(_heatmapOptionsFromHeatmap(heatmap));
  }

  /// Removes a set of [HeatmapId]s from the cache.
  void removeHeatmaps(Set<HeatmapId> heatmapIdsToRemove) {
    for (final HeatmapId heatmapId in heatmapIdsToRemove) {
      final HeatmapController? heatmapController =
          _heatmapIdToController[heatmapId];
      heatmapController?.remove();
      _heatmapIdToController.remove(heatmapId);
    }
  }
}
