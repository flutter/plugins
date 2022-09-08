// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages all the [CircleController]s associated to a [GoogleMapController].
class CirclesController extends GeometryController {
  /// Initialize the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  CirclesController({
    required StreamController<MapEvent<Object?>> stream,
  })  : _streamController = stream,
        _circleIdToController = <CircleId, CircleController>{};

  // A cache of [CircleController]s indexed by their [CircleId].
  final Map<CircleId, CircleController> _circleIdToController;

  // The stream over which circles broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  /// Returns the cache of [CircleController]s. Test only.
  @visibleForTesting
  Map<CircleId, CircleController> get circles => _circleIdToController;

  /// Adds a set of [Circle] objects to the cache.
  ///
  /// Wraps each [Circle] into its corresponding [CircleController].
  void addCircles(Set<Circle> circlesToAdd) {
    circlesToAdd.forEach(_addCircle);
  }

  void _addCircle(Circle circle) {
    if (circle == null) {
      return;
    }

    final gmaps.CircleOptions circleOptions = _circleOptionsFromCircle(circle);
    final gmaps.Circle gmCircle = gmaps.Circle(circleOptions)..map = googleMap;
    final CircleController controller = CircleController(
        circle: gmCircle,
        consumeTapEvents: circle.consumeTapEvents,
        onTap: () {
          _onCircleTap(circle.circleId);
        });
    _circleIdToController[circle.circleId] = controller;
  }

  /// Updates a set of [Circle] objects with new options.
  void changeCircles(Set<Circle> circlesToChange) {
    circlesToChange.forEach(_changeCircle);
  }

  void _changeCircle(Circle circle) {
    final CircleController? circleController =
        _circleIdToController[circle.circleId];
    circleController?.update(_circleOptionsFromCircle(circle));
  }

  /// Removes a set of [CircleId]s from the cache.
  void removeCircles(Set<CircleId> circleIdsToRemove) {
    circleIdsToRemove.forEach(_removeCircle);
  }

  // Removes a circle and its controller by its [CircleId].
  void _removeCircle(CircleId circleId) {
    final CircleController? circleController = _circleIdToController[circleId];
    circleController?.remove();
    _circleIdToController.remove(circleId);
  }

  // Handles the global onCircleTap function to funnel events from circles into the stream.
  bool _onCircleTap(CircleId circleId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(CircleTapEvent(mapId, circleId));
    return _circleIdToController[circleId]?.consumeTapEvents ?? false;
  }
}
