part of google_maps_flutter_web;

class MarkersController extends AbstractController {

  final Map<String, MarkerController> _markerIdToController;

  GoogleMapController googleMapController;

  MarkersController({
    @required this.googleMapController
  }): _markerIdToController = Map<String, MarkerController>();

  void addMarkers(Set<Marker> markersToAdd) {
    if(markersToAdd != null) {
      markersToAdd.forEach((marker) {
        _addMarker(marker);
      });
    }
  }

  void _addMarker(Marker marker){
    if(marker == null) return;
    final infoWindoOptions = _infoWindowOPtionsFromMarker(marker);
    GoogleMap.InfoWindow gmInfoWindow = GoogleMap.InfoWindow(infoWindoOptions);
    final populationOptions =  _markerOptionsFromMarker(googleMap, marker);
    GoogleMap.Marker  gmMarker = GoogleMap.Marker(populationOptions);
    gmMarker.map = googleMap;
    MarkerController controller = MarkerController(
        marker: gmMarker,
        infoWindow : gmInfoWindow,
        consumeTapEvents:marker.consumeTapEvents,
        ontab:(){onMarkerTap(marker.markerId);},
        onDragEnd :(GoogleMap.LatLng latLng){
          onMarkerDragEnd(marker.markerId, latLng);},
        onInfoWindowTap : (){onInfoWindowTap(marker.markerId);}
          );
    _markerIdToController[marker.markerId.value] = controller;
  }

  void changeMarkers(Set<Marker> markersToChange) {
    if (markersToChange != null) {
      markersToChange.forEach((markerToChange) {
        changeMarker(markerToChange);
      });
    }
  }

  void changeMarker(Marker marker) {
    if (marker == null) { return;}
    MarkerController markerController = _markerIdToController[marker.markerId.value];
    if (markerController != null) {
      markerController.update(
          _markerOptionsFromMarker(googleMap, marker));
    }
  }

  void removeMarkers(Set<MarkerId> markerIdsToRemove) {
    if (markerIdsToRemove == null) {return;}
    markerIdsToRemove.forEach((markerId) {
      if(markerId != null) {
        final MarkerController markerController = _markerIdToController[markerId
            .value];
        if(markerController != null) {
          markerController.remove();
          _markerIdToController.remove(markerId.value);
        }
      }
    });
  }

  bool onMarkerTap(MarkerId markerId) {
    googleMapController.onMarkerTap(markerId);
    final MarkerController markerController = _markerIdToController[markerId
        .value];
    if(markerController != null) {
      return markerController.consumeTapEvents;
    }
    return false;
  }

  void showMarkerInfoWindow(String markerId, dynamic result) {
    MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      markerController.showMarkerInfoWindow();
    }
  }

  bool isInfoWindowShown(String markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      return markerController.isInfoWindowShown();
    }
    return false;
  }

  void hideMarkerInfoWindow(String markerId, dynamic result) {
    MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      markerController.hideInfoWindow();
    }
  }

  void onInfoWindowTap(MarkerId markerId) {
    googleMapController.onInfoWindowTap(markerId);
  }

  void onMarkerDragEnd(MarkerId markerId, GoogleMap.LatLng latLng) {
    googleMapController.onMarkerDragEnd(markerId, latLng);
  }

}

typedef LatLngCallback = void Function(GoogleMap.LatLng latLng);