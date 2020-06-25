part of google_maps_flutter_web;

class PolygonsController extends AbstractController {

  final Map<PolygonId, PolygonController> _polygonIdToController;

  StreamController<MapEvent> _streamController;

  PolygonsController({
    @required StreamController<MapEvent> stream,
  }): _streamController = stream, _polygonIdToController = Map<PolygonId, PolygonController>();

  void addPolygons(Set<Polygon> polygonsToAdd) {
    if(polygonsToAdd != null) {
      polygonsToAdd.forEach((polygon) {
        _addPolygon(polygon);
      });
    }
  }

  void _addPolygon(Polygon polygon){
    if(polygon == null) return;
    final populationOptions =  _polygonOptionsFromPolygon(googleMap, polygon);
    GoogleMap.Polygon  gmPolygon = GoogleMap.Polygon(populationOptions);
    gmPolygon.map = googleMap;
    PolygonController controller = PolygonController(
        polygon: gmPolygon,
        consumeTapEvents:polygon.consumeTapEvents,
        ontab:(){ _onPolygonTap(polygon.polygonId);});
    _polygonIdToController[polygon.polygonId] = controller;
  }

  void changePolygons(Set<Polygon> polygonsToChange) {
    if (polygonsToChange != null) {
      polygonsToChange.forEach((polygonToChange) {
        changePolygon(polygonToChange);
      });
    }
  }

  void changePolygon(Polygon polygon) {
    if (polygon == null) { return;}

    PolygonController polygonController = _polygonIdToController[polygon.polygonId];
    if (polygonController != null) {
      polygonController.update(
          _polygonOptionsFromPolygon(googleMap, polygon));
    }
  }

  void removePolygons(Set<PolygonId> polygonIdsToRemove) {
    if (polygonIdsToRemove == null) {return;}
    polygonIdsToRemove.forEach((polygonId) {
      if(polygonId != null) {
        final PolygonController polygonController = _polygonIdToController[polygonId];
        if(polygonController != null) {
          polygonController.remove();
          _polygonIdToController.remove(polygonId.value);
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
