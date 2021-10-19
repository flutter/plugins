// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages all the [CircleController]s associated to a [GoogleMapController].
class CirclesController extends GeometryController {
  // A cache of [CircleController]s indexed by their [CircleId].
  final Map<CircleId, CircleController> _circleIdToController;

  // The stream over which circles broadcast their events
  StreamController<MapEvent> _streamController;

  /// Initialize the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  CirclesController({
    required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _circleIdToController = Map<CircleId, CircleController>();

  /// Returns the cache of [CircleController]s. Test only.
  @visibleForTesting
  Map<CircleId, CircleController> get circles => _circleIdToController;

  /// Adds a set of [Circle] objects to the cache.
  ///
  /// Wraps each [Circle] into its corresponding [CircleController].
  void addCircles(Set<Circle> circlesToAdd) {
    circlesToAdd.forEach((circle) {
      _addCircle(circle);
    });
  }

  void _addCircle(Circle circle) {
    if (circle == null) {
      return;
    }

    final populationOptions = _circleOptionsFromCircle(circle);
    gmaps.Circle gmCircle = gmaps.Circle(populationOptions);
    gmCircle.map = googleMap;
    CircleController controller = CircleController(
        circle: gmCircle,
        consumeTapEvents: circle.consumeTapEvents,
        onTap: () {
          _onCircleTap(circle.circleId);
        });
    _circleIdToController[circle.circleId] = controller;
  }

  /// Updates a set of [Circle] objects with new options.
  void changeCircles(Set<Circle> circlesToChange) {
    circlesToChange.forEach((circleToChange) {
      _changeCircle(circleToChange);
    });
  }

  void _changeCircle(Circle circle) {
    final circleController = _circleIdToController[circle.circleId];
    circleController?.update(_circleOptionsFromCircle(circle));
  }

  /// Removes a set of [CircleId]s from the cache.
  void removeCircles(Set<CircleId> circleIdsToRemove) {
    circleIdsToRemove.forEach((circleId) {
      final CircleController? circleController =
          _circleIdToController[circleId];
      circleController?.remove();
      _circleIdToController.remove(circleId);
    });
  }

  // Handles the global onCircleTap function to funnel events from circles into the stream.
  bool _onCircleTap(CircleId circleId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(CircleTapEvent(mapId, circleId));
    return _circleIdToController[circleId]?.consumeTapEvents ?? false;
  }
}
