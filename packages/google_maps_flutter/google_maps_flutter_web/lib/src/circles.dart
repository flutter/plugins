part of google_maps_flutter_web;

class CirclesController extends AbstractController {

  final Map<CircleId, CircleController> _circleIdToController;

  StreamController<MapEvent> _streamController;

  CirclesController({
    @required StreamController<MapEvent> stream,
  }): _streamController = stream, _circleIdToController = Map<CircleId, CircleController>();

  void addCircles(Set<Circle>  circlesToAdd) {
    if(circlesToAdd != null) {
      circlesToAdd.forEach((circle) {
        addCircle(circle);
      });
    }
  }

  /// add [gmaps.Circle] to [gmaps.GMap].
  void addCircle(Circle circle) {
    if(circle == null) return;
    final populationOptions =  _circleOptionsFromCircle(circle);
    gmaps.Circle gmCircle = gmaps.Circle(populationOptions);
    gmCircle.map = googleMap;
    CircleController controller = CircleController(
        circle: gmCircle,
        consumeTapEvents:circle.consumeTapEvents,
        onTap:(){ _onCircleTap(circle.circleId);});
    _circleIdToController[circle.circleId] = controller;
  }


  void changeCircles(Set<Circle> circlesToChange) {
    if (circlesToChange != null) {
      circlesToChange.forEach((circleToChange) {
        changeCircle(circleToChange);
      });
    }
  }

  void changeCircle(Circle circle) {
    if (circle == null) { return;}
    CircleController circleController = _circleIdToController[circle.circleId];
        if (circleController != null) {
        circleController.update(
            _circleOptionsFromCircle(circle));
        }
  }

  void removeCircles(Set<CircleId> circleIdsToRemove) {
    if (circleIdsToRemove == null) {return;}
    circleIdsToRemove.forEach((circleId) {
      if(circleId != null) {
        final CircleController circleController = _circleIdToController[circleId];
        if(circleController != null) {
          circleController.remove();
          _circleIdToController.remove(circleId);
        }
      }
    });
  }

  

  bool _onCircleTap(CircleId circleId) {
    _streamController.add(CircleTapEvent(mapId, circleId));
    // Stop propagation?
    return _circleIdToController[circleId]?.consumeTapEvents ?? false;
  }
}
