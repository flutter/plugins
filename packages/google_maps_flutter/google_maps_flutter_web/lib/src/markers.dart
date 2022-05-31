// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages a set of [MarkerController]s associated to a [GoogleMapController].
class MarkersController extends GeometryController {
  /// Initialize the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  MarkersController({
    required StreamController<MapEvent<Object?>> stream,
  })  : _streamController = stream,
        _markerIdToController = <MarkerId, MarkerController>{};

  // A cache of [MarkerController]s indexed by their [MarkerId].
  final Map<MarkerId, MarkerController> _markerIdToController;

  // The stream over which markers broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  /// Returns the cache of [MarkerController]s. Test only.
  @visibleForTesting
  Map<MarkerId, MarkerController> get markers => _markerIdToController;

  /// Adds a set of [Marker] objects to the cache.
  ///
  /// Wraps each [Marker] into its corresponding [MarkerController].
  void addMarkers(Set<Marker> markersToAdd) {
    markersToAdd.forEach(_addMarker);
  }

  void _addMarker(Marker marker) {
    if (marker == null) {
      return;
    }

    final gmaps.InfoWindowOptions? infoWindowOptions =
        _infoWindowOptionsFromMarker(marker);
    gmaps.InfoWindow? gmInfoWindow;

    if (infoWindowOptions != null) {
      gmInfoWindow = gmaps.InfoWindow(infoWindowOptions);
      // Google Maps' JS SDK does not have a click event on the InfoWindow, so
      // we make one...
      if (infoWindowOptions.content != null &&
          infoWindowOptions.content is HtmlElement) {
        final HtmlElement content = infoWindowOptions.content! as HtmlElement;
        content.onClick.listen((_) {
          _onInfoWindowTap(marker.markerId);
        });
      }
    }

    final gmaps.Marker? currentMarker =
        _markerIdToController[marker.markerId]?.marker;

    final gmaps.MarkerOptions markerOptions =
        _markerOptionsFromMarker(marker, currentMarker);
    final gmaps.Marker gmMarker = gmaps.Marker(markerOptions)..map = googleMap;
    final MarkerController controller = MarkerController(
      marker: gmMarker,
      infoWindow: gmInfoWindow,
      consumeTapEvents: marker.consumeTapEvents,
      onTap: () {
        showMarkerInfoWindow(marker.markerId);
        _onMarkerTap(marker.markerId);
      },
      onDragStart: (gmaps.LatLng latLng) {
        _onMarkerDragStart(marker.markerId, latLng);
      },
      onDrag: (gmaps.LatLng latLng) {
        _onMarkerDrag(marker.markerId, latLng);
      },
      onDragEnd: (gmaps.LatLng latLng) {
        _onMarkerDragEnd(marker.markerId, latLng);
      },
    );
    _markerIdToController[marker.markerId] = controller;
  }

  /// Updates a set of [Marker] objects with new options.
  void changeMarkers(Set<Marker> markersToChange) {
    markersToChange.forEach(_changeMarker);
  }

  void _changeMarker(Marker marker) {
    final MarkerController? markerController =
        _markerIdToController[marker.markerId];
    if (markerController != null) {
      final gmaps.MarkerOptions markerOptions = _markerOptionsFromMarker(
        marker,
        markerController.marker,
      );
      final gmaps.InfoWindowOptions? infoWindow =
          _infoWindowOptionsFromMarker(marker);
      markerController.update(
        markerOptions,
        newInfoWindowContent: infoWindow?.content as HtmlElement?,
      );
    }
  }

  /// Removes a set of [MarkerId]s from the cache.
  void removeMarkers(Set<MarkerId> markerIdsToRemove) {
    markerIdsToRemove.forEach(_removeMarker);
  }

  void _removeMarker(MarkerId markerId) {
    final MarkerController? markerController = _markerIdToController[markerId];
    markerController?.remove();
    _markerIdToController.remove(markerId);
  }

  // InfoWindow...

  /// Shows the [InfoWindow] of a [MarkerId].
  ///
  /// See also [hideMarkerInfoWindow] and [isInfoWindowShown].
  void showMarkerInfoWindow(MarkerId markerId) {
    _hideAllMarkerInfoWindow();
    final MarkerController? markerController = _markerIdToController[markerId];
    markerController?.showInfoWindow();
  }

  /// Hides the [InfoWindow] of a [MarkerId].
  ///
  /// See also [showMarkerInfoWindow] and [isInfoWindowShown].
  void hideMarkerInfoWindow(MarkerId markerId) {
    final MarkerController? markerController = _markerIdToController[markerId];
    markerController?.hideInfoWindow();
  }

  /// Returns whether or not the [InfoWindow] of a [MarkerId] is shown.
  ///
  /// See also [showMarkerInfoWindow] and [hideMarkerInfoWindow].
  bool isInfoWindowShown(MarkerId markerId) {
    final MarkerController? markerController = _markerIdToController[markerId];
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

  void _onMarkerDragStart(MarkerId markerId, gmaps.LatLng latLng) {
    _streamController.add(MarkerDragStartEvent(
      mapId,
      _gmLatLngToLatLng(latLng),
      markerId,
    ));
  }

  void _onMarkerDrag(MarkerId markerId, gmaps.LatLng latLng) {
    _streamController.add(MarkerDragEvent(
      mapId,
      _gmLatLngToLatLng(latLng),
      markerId,
    ));
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
        .where((MarkerController? controller) =>
            controller?.infoWindowShown ?? false)
        .forEach((MarkerController controller) {
      controller.hideInfoWindow();
    });
  }
}
