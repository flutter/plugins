part of google_maps_flutter_web;

class PolygonsController extends AbstractController {

  final Map<String, PolygonController> _polygonIdToController;

  GoogleMapController googleMapController;

  PolygonsController({
    @required this.googleMapController
  }): _polygonIdToController = Map<String, PolygonController>();

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
        ontab:(){ onPolygonTap(polygon.polygonId);});
    _polygonIdToController[polygon.polygonId.value] = controller;
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

    PolygonController polygonController = _polygonIdToController[polygon.polygonId.value];
    if (polygonController != null) {
      polygonController.update(
          _polygonOptionsFromPolygon(googleMap, polygon));
    }
  }

  void removePolygons(Set<PolygonId> polygonIdsToRemove) {
    if (polygonIdsToRemove == null) {return;}
    polygonIdsToRemove.forEach((polygonId) {
      if(polygonId != null) {
        final PolygonController polygonController = _polygonIdToController[polygonId
            .value];
        if(polygonController != null) {
          polygonController.remove();
          _polygonIdToController.remove(polygonId.value);
        }
      }
    });
  }

  bool onPolygonTap(PolygonId polygonId) {
    googleMapController.onPolygonTap(polygonId);
    final PolygonController polygonController = _polygonIdToController[polygonId
        .value];
    if(polygonController != null) {
      return polygonController.consumeTapEvents;
    }
    return false;
  }


}

