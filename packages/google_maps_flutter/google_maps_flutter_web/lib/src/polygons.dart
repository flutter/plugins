// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages a set of [PolygonController]s associated to a [GoogleMapController].
class PolygonsController extends GeometryController {
  // A cache of [PolygonController]s indexed by their [PolygonId].
  final Map<PolygonId, PolygonController> _polygonIdToController;

  // The stream over which polygons broadcast events
  StreamController<MapEvent> _streamController;

  /// Initializes the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  PolygonsController({
    @required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _polygonIdToController = Map<PolygonId, PolygonController>();

  /// Returns the cache of [PolygonController]s. Test only.
  @visibleForTesting
  Map<PolygonId, PolygonController> get polygons => _polygonIdToController;

  /// Adds a set of [Polygon] objects to the cache.
  ///
  /// Wraps each Polygon into its corresponding [PolygonController].
  void addPolygons(Set<Polygon> polygonsToAdd) {
    if (polygonsToAdd != null) {
      polygonsToAdd.forEach((polygon) {
        _addPolygon(polygon);
      });
    }
  }

  void _addPolygon(Polygon polygon) {
    if (polygon == null) {
      return;
    }

    final populationOptions = _polygonOptionsFromPolygon(googleMap, polygon);
    gmaps.Polygon gmPolygon = gmaps.Polygon(populationOptions);
    gmPolygon.map = googleMap;
    PolygonController controller = PolygonController(
        polygon: gmPolygon,
        consumeTapEvents: polygon.consumeTapEvents,
        onTap: () {
          _onPolygonTap(polygon.polygonId);
        });
    _polygonIdToController[polygon.polygonId] = controller;
  }

  /// Updates a set of [Polygon] objects with new options.
  void changePolygons(Set<Polygon> polygonsToChange) {
    if (polygonsToChange != null) {
      polygonsToChange.forEach((polygonToChange) {
        _changePolygon(polygonToChange);
      });
    }
  }

  void _changePolygon(Polygon polygon) {
    PolygonController polygonController =
        _polygonIdToController[polygon?.polygonId];
    polygonController?.update(_polygonOptionsFromPolygon(googleMap, polygon));
  }

  /// Removes a set of [PolygonId]s from the cache.
  void removePolygons(Set<PolygonId> polygonIdsToRemove) {
    polygonIdsToRemove?.forEach((polygonId) {
      final PolygonController polygonController =
          _polygonIdToController[polygonId];
      polygonController?.remove();
      _polygonIdToController.remove(polygonId);
    });
  }

  // Handle internal events
  bool _onPolygonTap(PolygonId polygonId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(PolygonTapEvent(mapId, polygonId));
    return _polygonIdToController[polygonId]?.consumeTapEvents ?? false;
  }
}
