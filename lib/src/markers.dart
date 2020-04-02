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
    final populationOptions =  _markerOptionsFromMarker(googleMap, marker);
    GoogleMap.Marker  gmMarker = GoogleMap.Marker(populationOptions);
    gmMarker.map = googleMap;
    MarkerController controller = MarkerController(
        marker: gmMarker,
        consumeTapEvents:marker.consumeTapEvents,
        ontab:(){ onMarkerTap(marker.markerId);});
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
    throw UnimplementedError('unimplemented.');

    /**
     *  MarkerController markerController = markerIdToController.get(markerId);
        if (markerController != null) {
        markerController.showInfoWindow();
        result.success(null);
        } else {
        result.error("Invalid markerId", "showInfoWindow called with invalid markerId", null);
        }
     */
  }

  void isInfoWindowShown(String markerId, dynamic result) {
    throw UnimplementedError('unimplemented.');
    /**
     * MarkerController markerController = markerIdToController.get(markerId);
        if (markerController != null) {
        result.success(markerController.isInfoWindowShown());
        } else {
        result.error("Invalid markerId", "isInfoWindowShown called with invalid markerId", null);
        }
     */
  }

  void hideMarkerInfoWindow(String markerId, dynamic result) {
    throw UnimplementedError('unimplemented.');
    /**
     * MarkerController markerController = markerIdToController.get(markerId);
        if (markerController != null) {
        markerController.hideInfoWindow();
        result.success(null);
        } else {
        result.error("Invalid markerId", "hideInfoWindow called with invalid markerId", null);
        }
     */
  }

  void onInfoWindowTap(String googleMarkerId) {
    throw UnimplementedError('unimplemented.');
    /**
     *  String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
        if (markerId == null) {
        return;
        }
        methodChannel.invokeMethod("infoWindow#onTap", Convert.markerIdToJson(markerId));
     */
  }

  void onMarkerDragEnd(String googleMarkerId, LatLng latLng) {
    throw UnimplementedError('unimplemented.');
    /**
     * String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
        if (markerId == null) {
        return;
        }
        final Map<String, Object> data = new HashMap<>();
        data.put("markerId", markerId);
        data.put("position", Convert.latLngToJson(latLng));
        methodChannel.invokeMethod("marker#onDragEnd", data);
     */
  }


}

