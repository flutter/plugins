part of google_maps_flutter_web;

///TODO
class CirclesController{
  GoogleMap.GMap googleMap;
  final Map<String, CircleController> _circleIdToController;

  GoogleMapController googleMapController;


  ///TODO
  CirclesController({
    @required this.googleMapController
  })
  : _circleIdToController = Map<String, CircleController>();


  ///TODO
  void addCircles(Set<Circle>  circlesToAdd) {
    if(circlesToAdd != null) {
      circlesToAdd.forEach((circle) {
        addCircle(circle);
      });
    }
  }

  ///TODO
  void setGoogleMap(GoogleMap.GMap googleMap) {
    this.googleMap = googleMap;
  }

  /// add [GoogleMap.Circle] to [GoogleMap.GMap].
  void addCircle(Circle circle) {
    if(circle == null) return;
    final populationOptions =  _circleOptionsFromCircle(googleMap, circle);
    GoogleMap.Circle gmCircle = GoogleMap.Circle(populationOptions);
    CircleController controller = CircleController(
        circle: gmCircle,
        consumeTapEvents:circle.consumeTapEvents,
        ontab:(){ googleMapController.onCircleTap(circle.circleId);});
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
            _circleOptionsFromCircle(googleMap, circle));
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
        }
      }
    });
  }

  ///String circleId = googleMapsCircleIdToDartCircleId.get(googleCircleId);
  //    if (circleId == null) {
  //      return false;
  //    }
  //    methodChannel.invokeMethod("circle#onTap", Convert.circleIdToJson(circleId));
  //    CircleController circleController = circleIdToController.get(circleId);
  //    if (circleController != null) {
  //      return circleController.consumeTapEvents();
  //    }
  //    return false;
  bool onCircleTap(String googleCircleId) {

  }

}