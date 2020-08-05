part of google_maps_flutter_web;

/// This class manages all the (poly)lines associated to any given Google Map Controller.
class PolylinesController extends AbstractController {
  // A cache of polylineIds to their controllers
  final Map<PolylineId, PolylineController> _polylineIdToController;

  // The stream over which polylines broadcast their events
  StreamController<MapEvent> _streamController;

  /// Initializes the cache. The StreamController is shared with the Google Map Controller.
  PolylinesController({
    @required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _polylineIdToController = Map<PolylineId, PolylineController>();

  /// Returns the cache of polylines. Test only.
  @visibleForTesting
  Map<PolylineId, PolylineController> get lines => _polylineIdToController;

  /// Adds a set of [Polyline] objects to the cache.
  ///
  /// (Wraps each line into its corresponding [PolylineController])
  void addPolylines(Set<Polyline> polylinesToAdd) {
    if (polylinesToAdd != null) {
      polylinesToAdd.forEach((polyline) {
        _addPolyline(polyline);
      });
    }
  }

  void _addPolyline(Polyline polyline) {
    if (polyline == null) return;
    final populationOptions = _polylineOptionsFromPolyline(googleMap, polyline);
    gmaps.Polyline gmPolyline = gmaps.Polyline(populationOptions);
    gmPolyline.map = googleMap;
    PolylineController controller = PolylineController(
        polyline: gmPolyline,
        consumeTapEvents: polyline.consumeTapEvents,
        onTap: () {
          _onPolylineTap(polyline.polylineId);
        });
    _polylineIdToController[polyline.polylineId] = controller;
  }

  /// Updates a set of [Polyline] objects with new options.
  void changePolylines(Set<Polyline> polylinesToChange) {
    if (polylinesToChange != null) {
      polylinesToChange.forEach((polylineToChange) {
        _changePolyline(polylineToChange);
      });
    }
  }

  void _changePolyline(Polyline polyline) {
    if (polyline == null) {
      return;
    }
    PolylineController polylineController =
        _polylineIdToController[polyline.polylineId];
    if (polylineController != null) {
      polylineController
          .update(_polylineOptionsFromPolyline(googleMap, polyline));
    }
  }

  /// Removes a set of [PolylineId]s from the cache.
  void removePolylines(Set<PolylineId> polylineIdsToRemove) {
    if (polylineIdsToRemove == null) {
      return;
    }
    polylineIdsToRemove.forEach((polylineId) {
      if (polylineId != null) {
        final PolylineController polylineController =
            _polylineIdToController[polylineId];
        if (polylineController != null) {
          polylineController.remove();
          _polylineIdToController.remove(polylineId);
        }
      }
    });
  }

  // Handle internal events

  bool _onPolylineTap(PolylineId polylineId) {
    _streamController.add(PolylineTapEvent(mapId, polylineId));
    // Stop propagation?
    return _polylineIdToController[polylineId]?.consumeTapEvents ?? false;
  }
}
