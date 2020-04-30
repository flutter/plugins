part of google_maps_flutter_web;

class PolylinesController extends AbstractController {

  final Map<String, PolylineController> _polylineIdToController;

  GoogleMapController googleMapController;

  PolylinesController({
    @required this.googleMapController
  }): _polylineIdToController = Map<String, PolylineController>();

  void addPolylines(Set<Polyline> polylinesToAdd) {
    if(polylinesToAdd != null) {
      polylinesToAdd.forEach((polyline) {
        _addPolyline(polyline);
      });
    }
  }

  void _addPolyline(Polyline polyline){
    if(polyline == null) return;
    final populationOptions =  _polylineOptionsFromPolyline(googleMap, polyline);
    GoogleMap.Polyline  gmPolyline = GoogleMap.Polyline(populationOptions);
    gmPolyline.map = googleMap;
    PolylineController controller = PolylineController(
        polyline: gmPolyline,
        consumeTapEvents:polyline.consumeTapEvents,
        ontab:(){ onPolylineTap(polyline.polylineId);});
    _polylineIdToController[polyline.polylineId.value] = controller;
  }

  void changePolylines(Set<Polyline> polylinesToChange) {
    if (polylinesToChange != null) {
      polylinesToChange.forEach((polylineToChange) {
        changePolyline(polylineToChange);
      });
    }
  }

  void changePolyline(Polyline polyline) {
    if (polyline == null) { return;}
    PolylineController polylineController = _polylineIdToController[polyline.polylineId.value];
    if (polylineController != null) {
      polylineController.update(
          _polylineOptionsFromPolyline(googleMap, polyline));
    }
  }

  void removePolylines(Set<PolylineId> polylineIdsToRemove) {
    if (polylineIdsToRemove == null) {return;}
    polylineIdsToRemove.forEach((polylineId) {
      if(polylineId != null) {
        final PolylineController polylineController = _polylineIdToController[polylineId
            .value];
        if(polylineController != null) {
          polylineController.remove();
          _polylineIdToController.remove(polylineId.value);
        }
      }
    });
  }

  bool onPolylineTap(PolylineId polylineId) {
    googleMapController.onPolylineTap(polylineId);
    final PolylineController polylineController = _polylineIdToController[polylineId
        .value];
    if(polylineController != null) {
      return polylineController.consumeTapEvents;
    }
    return false;
  }


}

