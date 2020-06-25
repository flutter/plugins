part of google_maps_flutter_web;

class MarkersController extends AbstractController {

  final Map<MarkerId, MarkerController> _markerIdToController;

  StreamController<MapEvent> _streamController;

  MarkersController({
    @required  StreamController<MapEvent> stream,
  }): _streamController = stream, _markerIdToController = Map<MarkerId, MarkerController>();

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
        onTap:(){ _onMarkerTap(marker.markerId);},
        onDragEnd : (GoogleMap.LatLng latLng){
          _onMarkerDragEnd(marker.markerId, latLng);},
        onInfoWindowTap : (){ _onInfoWindowTap(marker.markerId);}
          );
    _markerIdToController[marker.markerId] = controller;
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
    MarkerController markerController = _markerIdToController[marker.markerId];
    if (markerController != null) {
      markerController.update(
          _markerOptionsFromMarker(googleMap, marker));
    }
  }

  void removeMarkers(Set<MarkerId> markerIdsToRemove) {
    if (markerIdsToRemove == null) {return;}
    markerIdsToRemove.forEach((markerId) {
      if(markerId != null) {
        final MarkerController markerController = _markerIdToController[markerId];
        if(markerController != null) {
          markerController.remove();
          _markerIdToController.remove(markerId.value);
        }
      }
    });
  }

  void showMarkerInfoWindow(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      markerController.showMarkerInfoWindow();
    }
  }

  bool isInfoWindowShown(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      return markerController.isInfoWindowShown();
    }
    return false;
  }

  void hideMarkerInfoWindow(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      markerController.hideInfoWindow();
    }
  }

  // Handle internal events

  bool _onMarkerTap(MarkerId markerId) {
    _streamController.add(MarkerTapEvent(mapId, markerId));
    // Stop propagation?
    return _markerIdToController[markerId]?.consumeTapEvents ?? false;
  }

  void _onInfoWindowTap(MarkerId markerId) {
    _streamController.add(InfoWindowTapEvent(mapId, markerId));
  }

  void _onMarkerDragEnd(MarkerId markerId, GoogleMap.LatLng latLng) {
    _streamController.add(MarkerDragEndEvent(mapId,
        _gmLatlngToLatlng(latLng), markerId,));
  }

}

typedef LatLngCallback = void Function(GoogleMap.LatLng latLng);