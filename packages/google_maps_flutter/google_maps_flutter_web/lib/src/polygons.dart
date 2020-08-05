part of google_maps_flutter_web;

/// This class manages all the polygons associated to any given Google Map Controller.
class PolygonsController extends AbstractController {
  // A cache of polygonIDs to their controllers
  final Map<PolygonId, PolygonController> _polygonIdToController;

  // The stream over which polygons broadcast events
  StreamController<MapEvent> _streamController;

  /// Initializes the cache. The StreamController is shared with the Google Map Controller.
  PolygonsController({
    @required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _polygonIdToController = Map<PolygonId, PolygonController>();

  /// Returns the cache of polygons. Test only.
  @visibleForTesting
  Map<PolygonId, PolygonController> get polygons => _polygonIdToController;

  /// Adds a set of [Polygon] objects to the cache.
  ///
  /// (Wraps each Polygon into its corresponding [PolygonController])
  void addPolygons(Set<Polygon> polygonsToAdd) {
    if (polygonsToAdd != null) {
      polygonsToAdd.forEach((polygon) {
        _addPolygon(polygon);
      });
    }
  }

  void _addPolygon(Polygon polygon) {
    if (polygon == null) return;
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
    if (polygon == null) {
      return;
    }

    PolygonController polygonController =
        _polygonIdToController[polygon.polygonId];
    if (polygonController != null) {
      polygonController.update(_polygonOptionsFromPolygon(googleMap, polygon));
    }
  }

  /// Removes a set of [PolygonId]s from the cache.
  void removePolygons(Set<PolygonId> polygonIdsToRemove) {
    if (polygonIdsToRemove == null) {
      return;
    }
    polygonIdsToRemove.forEach((polygonId) {
      if (polygonId != null) {
        final PolygonController polygonController =
            _polygonIdToController[polygonId];
        if (polygonController != null) {
          polygonController.remove();
          _polygonIdToController.remove(polygonId);
        }
      }
    });
  }

  // Handle internal events
  bool _onPolygonTap(PolygonId polygonId) {
    _streamController.add(PolygonTapEvent(mapId, polygonId));
    // Stop propagation?
    return _polygonIdToController[polygonId]?.consumeTapEvents ?? false;
  }
}
