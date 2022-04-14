// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages all the [HeatmapLayerController]s associated to a [GoogleMapController].
class HeatmapLayersController extends GeometryController {
  // A cache of [HeatmapLayerController]s indexed by their [HeatmapLayerId].
  final Map<HeatmapLayerId, HeatmapLayerController> _heatmapLayerIdToController;

  // The stream over which heatmapLayers broadcast their events
  StreamController<MapEvent> _streamController;

  /// Initialize the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  HeatmapLayersController({
    required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _heatmapLayerIdToController =
            Map<HeatmapLayerId, HeatmapLayerController>();

  /// Returns the cache of [HeatmapLayerController]s. Test only.
  @visibleForTesting
  Map<HeatmapLayerId, HeatmapLayerController> get heatmapLayers =>
      _heatmapLayerIdToController;

  /// Adds a set of [HeatmapLayer] objects to the cache.
  ///
  /// Wraps each [HeatmapLayer] into its corresponding [HeatmapLayerController].
  void addHeatmapLayers(Set<HeatmapLayer> heatmapLayersToAdd) {
    heatmapLayersToAdd.forEach((heatmapLayer) {
      _addHeatmapLayer(heatmapLayer);
    });
  }

  void _addHeatmapLayer(HeatmapLayer heatmapLayer) {
    if (heatmapLayer == null) {
      return;
    }

    final populationOptions =
        _heatmapLayerOptionsFromHeatmapLayer(heatmapLayer);
    gmaps_visualization.HeatmapLayer gmHeatmapLayer =
        gmaps_visualization.HeatmapLayer(populationOptions);
    gmHeatmapLayer.map = googleMap;
    HeatmapLayerController controller =
        HeatmapLayerController(heatmapLayer: gmHeatmapLayer);
    _heatmapLayerIdToController[heatmapLayer.heatmapLayerId] = controller;
  }

  /// Updates a set of [HeatmapLayer] objects with new options.
  void changeHeatmapLayers(Set<HeatmapLayer> heatmapLayersToChange) {
    heatmapLayersToChange.forEach((heatmapLayerToChange) {
      _changeHeatmapLayer(heatmapLayerToChange);
    });
  }

  void _changeHeatmapLayer(HeatmapLayer heatmapLayer) {
    final heatmapLayerController =
        _heatmapLayerIdToController[heatmapLayer.heatmapLayerId];
    heatmapLayerController
        ?.update(_heatmapLayerOptionsFromHeatmapLayer(heatmapLayer));
  }

  /// Removes a set of [HeatmapLayerId]s from the cache.
  void removeHeatmapLayers(Set<HeatmapLayerId> heatmapLayerIdsToRemove) {
    heatmapLayerIdsToRemove.forEach((heatmapLayerId) {
      final HeatmapLayerController? heatmapLayerController =
          _heatmapLayerIdToController[heatmapLayerId];
      heatmapLayerController?.remove();
      _heatmapLayerIdToController.remove(heatmapLayerId);
    });
  }
}
