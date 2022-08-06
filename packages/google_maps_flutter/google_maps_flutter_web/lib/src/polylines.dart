// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages a set of [PolylinesController]s associated to a [GoogleMapController].
class PolylinesController extends GeometryController {
  /// Initializes the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  PolylinesController({
    required StreamController<MapEvent<Object?>> stream,
  })  : _streamController = stream,
        _polylineIdToController = <PolylineId, PolylineController>{};

  // A cache of [PolylineController]s indexed by their [PolylineId].
  final Map<PolylineId, PolylineController> _polylineIdToController;

  // The stream over which polylines broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  /// Returns the cache of [PolylineContrller]s. Test only.
  @visibleForTesting
  Map<PolylineId, PolylineController> get lines => _polylineIdToController;

  /// Adds a set of [Polyline] objects to the cache.
  ///
  /// Wraps each line into its corresponding [PolylineController].
  void addPolylines(Set<Polyline> polylinesToAdd) {
    polylinesToAdd.forEach(_addPolyline);
  }

  void _addPolyline(Polyline polyline) {
    if (polyline == null) {
      return;
    }

    final gmaps.PolylineOptions polylineOptions =
        _polylineOptionsFromPolyline(googleMap, polyline);
    final gmaps.Polyline gmPolyline = gmaps.Polyline(polylineOptions)
      ..map = googleMap;
    final PolylineController controller = PolylineController(
        polyline: gmPolyline,
        consumeTapEvents: polyline.consumeTapEvents,
        onTap: () {
          _onPolylineTap(polyline.polylineId);
        });
    _polylineIdToController[polyline.polylineId] = controller;
  }

  /// Updates a set of [Polyline] objects with new options.
  void changePolylines(Set<Polyline> polylinesToChange) {
    polylinesToChange.forEach(_changePolyline);
  }

  void _changePolyline(Polyline polyline) {
    final PolylineController? polylineController =
        _polylineIdToController[polyline.polylineId];
    polylineController
        ?.update(_polylineOptionsFromPolyline(googleMap, polyline));
  }

  /// Removes a set of [PolylineId]s from the cache.
  void removePolylines(Set<PolylineId> polylineIdsToRemove) {
    polylineIdsToRemove.forEach(_removePolyline);
  }

  // Removes a polyline and its controller by its [PolylineId].
  void _removePolyline(PolylineId polylineId) {
    final PolylineController? polylineController =
        _polylineIdToController[polylineId];
    polylineController?.remove();
    _polylineIdToController.remove(polylineId);
  }

  // Handle internal events

  bool _onPolylineTap(PolylineId polylineId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(PolylineTapEvent(mapId, polylineId));
    return _polylineIdToController[polylineId]?.consumeTapEvents ?? false;
  }
}
