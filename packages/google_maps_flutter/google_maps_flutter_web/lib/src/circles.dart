part of google_maps_flutter_web;

class CirclesController extends AbstractController {

  final Map<String, CircleController> _circleIdToController;

  GoogleMapController googleMapController;

  CirclesController({
    @required this.googleMapController
  })
  : _circleIdToController = Map<String, CircleController>();

  void addCircles(Set<Circle>  circlesToAdd) {
    if(circlesToAdd != null) {
      circlesToAdd.forEach((circle) {
        addCircle(circle);
      });
    }
  }

  /// add [GoogleMap.Circle] to [GoogleMap.GMap].
  void addCircle(Circle circle) {
    if(circle == null) return;
    final populationOptions =  _circleOptionsFromCircle(circle);
    GoogleMap.Circle gmCircle = GoogleMap.Circle(populationOptions);
    gmCircle.map = googleMap;
    CircleController controller = CircleController(
        circle: gmCircle,
        consumeTapEvents:circle.consumeTapEvents,
        ontab:(){ onCircleTap(circle.circleId);});
    _circleIdToController[circle.circleId.value] = controller;
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
    CircleController circleController = _circleIdToController[circle.circleId.value];
        if (circleController != null) {
        circleController.update(
            _circleOptionsFromCircle(circle));
        }
  }

  void removeCircles(Set<CircleId> circleIdsToRemove) {
    if (circleIdsToRemove == null) {return;}
    circleIdsToRemove.forEach((circleId) {
      if(circleId != null) {
        final CircleController circleController = _circleIdToController[circleId
            .value];
        if(circleController != null) {
          circleController.remove();
          _circleIdToController.remove(circleId.value);
        }
      }
    });
  }

  bool onCircleTap(CircleId circleId) {
    googleMapController.onCircleTap(circleId);
    final CircleController circleController = _circleIdToController[circleId
        .value];
    if(circleController != null) {
      return circleController.consumeTapEvents;
    }
    return false;
  }

}

