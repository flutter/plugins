part of google_maps_flutter_web;

/// This class manages all the circles associated to any given Google Map Controller.
class CirclesController extends AbstractController {
  // A cache of circleIDs to their controllers
  final Map<CircleId, CircleController> _circleIdToController;

  // The stream over which circles broadcast their events
  StreamController<MapEvent> _streamController;

  /// Initialize the cache. The StreamController is shared with the Google Map Controller.
  CirclesController({
    @required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _circleIdToController = Map<CircleId, CircleController>();

  @visibleForTesting
  Map<CircleId, CircleController> get circles => _circleIdToController;

  /// Adds a set of [Circle] objects to the cache.
  ///
  /// (Wraps each Circle into its corresponding [CircleController])
  void addCircles(Set<Circle> circlesToAdd) {
    circlesToAdd?.forEach((circle) {
      _addCircle(circle);
    });
  }

  void _addCircle(Circle circle) {
    if (circle == null) return;
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
    circlesToChange?.forEach((circleToChange) {
      _changeCircle(circleToChange);
    });
  }

  void _changeCircle(Circle circle) {
    if (circle != null) {
      final circleController = _circleIdToController[circle.circleId];
      circleController?.update(_circleOptionsFromCircle(circle));
    }
  }

  /// Removes a set of [CircleId]s from the cache.
  void removeCircles(Set<CircleId> circleIdsToRemove) {
    circleIdsToRemove?.forEach((circleId) {
      if (circleId != null) {
        final CircleController circleController =
            _circleIdToController[circleId];
        if (circleController != null) {
          circleController.remove();
          _circleIdToController.remove(circleId);
        }
      }
    });
  }

  // Handles the global onCircleTap function to funnel events from circles into the stream.
  bool _onCircleTap(CircleId circleId) {
    // TODO: Should consumeTapEvents prevent events from being added to the stream?
    _streamController.add(CircleTapEvent(mapId, circleId));
    // Stop propagation?
    return _circleIdToController[circleId]?.consumeTapEvents ?? false;
  }
}
