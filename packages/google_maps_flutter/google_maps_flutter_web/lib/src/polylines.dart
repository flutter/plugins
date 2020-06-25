part of google_maps_flutter_web;

class PolylinesController extends AbstractController {

  final Map<PolylineId, PolylineController> _polylineIdToController;

  StreamController<MapEvent> _streamController;

  PolylinesController({
    @required StreamController<MapEvent> stream,
  }): _streamController = stream, _polylineIdToController = Map<PolylineId, PolylineController>();

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
        onTap:(){ _onPolylineTap(polyline.polylineId);});
    _polylineIdToController[polyline.polylineId] = controller;
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
    PolylineController polylineController = _polylineIdToController[polyline.polylineId];
    if (polylineController != null) {
      polylineController.update(
          _polylineOptionsFromPolyline(googleMap, polyline));
    }
  }

  void removePolylines(Set<PolylineId> polylineIdsToRemove) {
    if (polylineIdsToRemove == null) {return;}
    polylineIdsToRemove.forEach((polylineId) {
      if(polylineId != null) {
        final PolylineController polylineController = _polylineIdToController[polylineId];
        if(polylineController != null) {
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
