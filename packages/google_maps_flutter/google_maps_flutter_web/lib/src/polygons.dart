// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages a set of [PolygonController]s associated to a [GoogleMapController].
class PolygonsController extends GeometryController {
  /// Initializes the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  PolygonsController({
    required StreamController<MapEvent<Object?>> stream,
  })  : _streamController = stream,
        _polygonIdToController = <PolygonId, PolygonController>{};

  // A cache of [PolygonController]s indexed by their [PolygonId].
  final Map<PolygonId, PolygonController> _polygonIdToController;

  // The stream over which polygons broadcast events
  final StreamController<MapEvent<Object?>> _streamController;

  /// Returns the cache of [PolygonController]s. Test only.
  @visibleForTesting
  Map<PolygonId, PolygonController> get polygons => _polygonIdToController;

  /// Adds a set of [Polygon] objects to the cache.
  ///
  /// Wraps each Polygon into its corresponding [PolygonController].
  void addPolygons(Set<Polygon> polygonsToAdd) {
    if (polygonsToAdd != null) {
      polygonsToAdd.forEach(_addPolygon);
    }
  }

  void _addPolygon(Polygon polygon) {
    if (polygon == null) {
      return;
    }

    final gmaps.PolygonOptions polygonOptions =
        _polygonOptionsFromPolygon(googleMap, polygon);
    final gmaps.Polygon gmPolygon = gmaps.Polygon(polygonOptions)
      ..map = googleMap;
    final PolygonController controller = PolygonController(
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
      polygonsToChange.forEach(_changePolygon);
    }
  }

  void _changePolygon(Polygon polygon) {
    final PolygonController? polygonController =
        _polygonIdToController[polygon.polygonId];
    polygonController?.update(_polygonOptionsFromPolygon(googleMap, polygon));
  }

  /// Removes a set of [PolygonId]s from the cache.
  void removePolygons(Set<PolygonId> polygonIdsToRemove) {
    polygonIdsToRemove.forEach(_removePolygon);
  }

  // Removes a polygon and its controller by its [PolygonId].
  void _removePolygon(PolygonId polygonId) {
    final PolygonController? polygonController =
        _polygonIdToController[polygonId];
    polygonController?.remove();
    _polygonIdToController.remove(polygonId);
  }

  // Handle internal events
  bool _onPolygonTap(PolygonId polygonId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(PolygonTapEvent(mapId, polygonId));
    return _polygonIdToController[polygonId]?.consumeTapEvents ?? false;
  }
}
