part of google_maps_flutter_web;

/// This class manages a set of [MarkerController]s associated to a Google Map Controller.
class MarkersController extends AbstractController {
  // A cache of markerIds to their controllers
  final Map<MarkerId, MarkerController> _markerIdToController;

  // The stream over which markers broadcast their events
  StreamController<MapEvent> _streamController;

  /// Initializes the cache. The StreamController is shared with the Google Map Controller.
  MarkersController({
    @required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _markerIdToController = Map<MarkerId, MarkerController>();

  /// Returns the cache of markers. Test only.
  @visibleForTesting
  Map<MarkerId, MarkerController> get markers => _markerIdToController;

  /// Adds a set of [Marker] objects to the cache.
  ///
  /// (Wraps each Marker into its corresponding [MarkerController])
  void addMarkers(Set<Marker> markersToAdd) {
    if (markersToAdd != null) {
      markersToAdd.forEach(_addMarker);
    }
  }

  void _addMarker(Marker marker) {
    if (marker == null) return;

    final infoWindowOptions = _infoWindowOptionsFromMarker(marker);
    gmaps.InfoWindow gmInfoWindow;

    if (infoWindowOptions != null) {
      gmInfoWindow = gmaps.InfoWindow(infoWindowOptions)
        ..addListener('click', () {
          _onInfoWindowTap(marker.markerId);
        });
    }

    final currentMarker = _markerIdToController[marker.markerId]?.marker;

    final populationOptions = _markerOptionsFromMarker(marker, currentMarker);
    gmaps.Marker gmMarker = gmaps.Marker(populationOptions);
    gmMarker.map = googleMap;
    MarkerController controller = MarkerController(
      marker: gmMarker,
      infoWindow: gmInfoWindow,
      consumeTapEvents: marker.consumeTapEvents,
      onTap: () {
        // TODO: If has infowindow...
        this.showMarkerInfoWindow(marker.markerId);
        _onMarkerTap(marker.markerId);
      },
      onDragEnd: (gmaps.LatLng latLng) {
        _onMarkerDragEnd(marker.markerId, latLng);
      },
    );
    _markerIdToController[marker.markerId] = controller;
  }

  /// Updates a set of [Marker] objects with new options.
  void changeMarkers(Set<Marker> markersToChange) {
    if (markersToChange != null) {
      markersToChange.forEach(_changeMarker);
    }
  }

  void _changeMarker(Marker marker) {
    if (marker == null) {
      return;
    }
    MarkerController markerController = _markerIdToController[marker.markerId];
    if (markerController != null) {
      final markerOptions = _markerOptionsFromMarker(
        marker,
        markerController.marker,
      );
      final infoWindow = _infoWindowOptionsFromMarker(marker);
      markerController.update(
        markerOptions,
        newInfoWindowContent: infoWindow?.content,
      );
    }
  }

  /// Removes a set of [MarkerId]s from the cache.
  void removeMarkers(Set<MarkerId> markerIdsToRemove) {
    if (markerIdsToRemove == null) {
      return;
    }
    markerIdsToRemove.forEach(_removeMarker);
  }

  void _removeMarker(MarkerId markerId) {
    if (markerId == null) return;

    final MarkerController markerController = _markerIdToController[markerId];
    if (markerController != null) {
      markerController.remove();
      _markerIdToController.remove(markerId);
    }
  }

  // InfoWindow...

  /// Shows the [InfoWindow] of a Marker.
  void showMarkerInfoWindow(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    markerController?.showInfoWindow();
  }

  /// Hides the [InfoWindow] of a Marker.
  void hideMarkerInfoWindow(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    markerController?.hideInfoWindow();
  }

  /// Returns whether or not the [InfoWindow] of a Marker is shown.
  bool isInfoWindowShown(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    return markerController?.infoWindowShown ?? false;
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

  void _onMarkerDragEnd(MarkerId markerId, gmaps.LatLng latLng) {
    _streamController.add(MarkerDragEndEvent(
      mapId,
      _gmLatLngToLatLng(latLng),
      markerId,
    ));
  }
}
