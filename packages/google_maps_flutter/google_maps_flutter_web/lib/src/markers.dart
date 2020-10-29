// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages a set of [MarkerController]s associated to a [GoogleMapController].
class MarkersController extends GeometryController {
  // A cache of [MarkerController]s indexed by their [MarkerId].
  final Map<MarkerId, MarkerController> _markerIdToController;

  // The stream over which markers broadcast their events
  StreamController<MapEvent> _streamController;

  /// Initialize the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  MarkersController({
    @required StreamController<MapEvent> stream,
  })  : _streamController = stream,
        _markerIdToController = Map<MarkerId, MarkerController>();

  /// Returns the cache of [MarkerController]s. Test only.
  @visibleForTesting
  Map<MarkerId, MarkerController> get markers => _markerIdToController;

  /// Adds a set of [Marker] objects to the cache.
  ///
  /// Wraps each [Marker] into its corresponding [MarkerController].
  void addMarkers(Set<Marker> markersToAdd) {
    markersToAdd?.forEach(_addMarker);
  }

  void _addMarker(Marker marker) {
    if (marker == null) {
      return;
    }

    final infoWindowOptions = _infoWindowOptionsFromMarker(marker);
    gmaps.InfoWindow gmInfoWindow;

    if (infoWindowOptions != null) {
      gmInfoWindow = gmaps.InfoWindow(infoWindowOptions);
      // Google Maps' JS SDK does not have a click event on the InfoWindow, so
      // we make one...
      if (infoWindowOptions.content is HtmlElement) {
        infoWindowOptions.content.onClick.listen((_) {
          _onInfoWindowTap(marker.markerId);
        });
      }
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
    markersToChange?.forEach(_changeMarker);
  }

  void _changeMarker(Marker marker) {
    MarkerController markerController = _markerIdToController[marker?.markerId];
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
    markerIdsToRemove?.forEach(_removeMarker);
  }

  void _removeMarker(MarkerId markerId) {
    final MarkerController markerController = _markerIdToController[markerId];
    markerController?.remove();
    _markerIdToController.remove(markerId);
  }

  // InfoWindow...

  /// Shows the [InfoWindow] of a [MarkerId].
  ///
  /// See also [hideMarkerInfoWindow] and [isInfoWindowShown].
  void showMarkerInfoWindow(MarkerId markerId) {
    _hideAllMarkerInfoWindow();
    MarkerController markerController = _markerIdToController[markerId];
    markerController?.showInfoWindow();
  }

  /// Hides the [InfoWindow] of a [MarkerId].
  ///
  /// See also [showMarkerInfoWindow] and [isInfoWindowShown].
  void hideMarkerInfoWindow(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    markerController?.hideInfoWindow();
  }

  /// Returns whether or not the [InfoWindow] of a [MarkerId] is shown.
  ///
  /// See also [showMarkerInfoWindow] and [hideMarkerInfoWindow].
  bool isInfoWindowShown(MarkerId markerId) {
    MarkerController markerController = _markerIdToController[markerId];
    return markerController?.infoWindowShown ?? false;
  }

  // Handle internal events

  bool _onMarkerTap(MarkerId markerId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(MarkerTapEvent(mapId, markerId));
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

  void _hideAllMarkerInfoWindow() {
    _markerIdToController.values
        .where((controller) =>
            controller == null ? false : controller.infoWindowShown)
        .forEach((controller) => controller.hideInfoWindow());
  }
}
