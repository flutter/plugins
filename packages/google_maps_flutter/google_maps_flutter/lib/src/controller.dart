// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

final GoogleMapsFlutterPlatform _googleMapsFlutterPlatform =
    GoogleMapsFlutterPlatform.instance;

/// Controller for a single GoogleMap instance running on the host platform.
class GoogleMapController {
  /// The mapId for this controller
  final int mapId;

  GoogleMapController._(
    CameraPosition initialCameraPosition,
    this._googleMapState, {
    @required this.mapId,
  }) : assert(_googleMapsFlutterPlatform != null) {
    _connectStreams(mapId);
  }

  /// Initialize control of a [GoogleMap] with [id].
  ///
  /// Mainly for internal use when instantiating a [GoogleMapController] passed
  /// in [GoogleMap.onMapCreated] callback.
  static Future<GoogleMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _GoogleMapState googleMapState,
  ) async {
    assert(id != null);
    await _googleMapsFlutterPlatform.init(id);
    return GoogleMapController._(
      initialCameraPosition,
      googleMapState,
      mapId: id,
    );
  }

  /// Used to communicate with the native platform.
  ///
  /// Accessible only for testing.
  // TODO(dit) https://github.com/flutter/flutter/issues/55504 Remove this getter.
  @visibleForTesting
  MethodChannel get channel {
    if (_googleMapsFlutterPlatform is MethodChannelGoogleMapsFlutter) {
      return (_googleMapsFlutterPlatform as MethodChannelGoogleMapsFlutter)
          .channel(mapId);
    }
    return null;
  }

  final _GoogleMapState _googleMapState;

  void _connectStreams(int mapId) {
    if (_googleMapState.widget.onCameraMoveStarted != null) {
      _googleMapsFlutterPlatform
          .onCameraMoveStarted(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraMoveStarted());
    }
    if (_googleMapState.widget.onCameraMove != null) {
      _googleMapsFlutterPlatform.onCameraMove(mapId: mapId).listen(
          (CameraMoveEvent e) => _googleMapState.widget.onCameraMove(e.value));
    }
    if (_googleMapState.widget.onCameraIdle != null) {
      _googleMapsFlutterPlatform
          .onCameraIdle(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraIdle());
    }
    _googleMapsFlutterPlatform
        .onMarkerTap(mapId: mapId)
        .listen((MarkerTapEvent e) => _googleMapState.onMarkerTap(e.value));
    _googleMapsFlutterPlatform.onMarkerDragEnd(mapId: mapId).listen(
        (MarkerDragEndEvent e) =>
            _googleMapState.onMarkerDragEnd(e.value, e.position));
    _googleMapsFlutterPlatform.onInfoWindowTap(mapId: mapId).listen(
        (InfoWindowTapEvent e) => _googleMapState.onInfoWindowTap(e.value));
    _googleMapsFlutterPlatform
        .onPolylineTap(mapId: mapId)
        .listen((PolylineTapEvent e) => _googleMapState.onPolylineTap(e.value));
    _googleMapsFlutterPlatform
        .onPolygonTap(mapId: mapId)
        .listen((PolygonTapEvent e) => _googleMapState.onPolygonTap(e.value));
    _googleMapsFlutterPlatform
        .onCircleTap(mapId: mapId)
        .listen((CircleTapEvent e) => _googleMapState.onCircleTap(e.value));
    _googleMapsFlutterPlatform
        .onTap(mapId: mapId)
        .listen((MapTapEvent e) => _googleMapState.onTap(e.position));
    _googleMapsFlutterPlatform.onLongPress(mapId: mapId).listen(
        (MapLongPressEvent e) => _googleMapState.onLongPress(e.position));
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) {
    assert(optionsUpdate != null);
    return _googleMapsFlutterPlatform.updateMapOptions(optionsUpdate,
        mapId: mapId);
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    assert(markerUpdates != null);
    return _googleMapsFlutterPlatform.updateMarkers(markerUpdates,
        mapId: mapId);
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    assert(polygonUpdates != null);
    return _googleMapsFlutterPlatform.updatePolygons(polygonUpdates,
        mapId: mapId);
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    assert(polylineUpdates != null);
    return _googleMapsFlutterPlatform.updatePolylines(polylineUpdates,
        mapId: mapId);
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    assert(circleUpdates != null);
    return _googleMapsFlutterPlatform.updateCircles(circleUpdates,
        mapId: mapId);
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return _googleMapsFlutterPlatform.animateCamera(cameraUpdate, mapId: mapId);
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return _googleMapsFlutterPlatform.moveCamera(cameraUpdate, mapId: mapId);
  }

  /// Sets the styling of the base map.
  ///
  /// Set to `null` to clear any previous custom styling.
  ///
  /// If problems were detected with the [mapStyle], including un-parsable
  /// styling JSON, unrecognized feature type, unrecognized element type, or
  /// invalid styler keys: [MapStyleException] is thrown and the current
  /// style is left unchanged.
  ///
  /// The style string can be generated using [map style tool](https://mapstyle.withgoogle.com/).
  /// Also, refer [iOS](https://developers.google.com/maps/documentation/ios-sdk/style-reference)
  /// and [Android](https://developers.google.com/maps/documentation/android-sdk/style-reference)
  /// style reference for more information regarding the supported styles.
  Future<void> setMapStyle(String mapStyle) {
    return _googleMapsFlutterPlatform.setMapStyle(mapStyle, mapId: mapId);
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    return _googleMapsFlutterPlatform.getVisibleRegion(mapId: mapId);
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return _googleMapsFlutterPlatform.getScreenCoordinate(latLng, mapId: mapId);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return _googleMapsFlutterPlatform.getLatLng(screenCoordinate, mapId: mapId);
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow(MarkerId markerId) {
    assert(markerId != null);
    return _googleMapsFlutterPlatform.showMarkerInfoWindow(markerId,
        mapId: mapId);
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(MarkerId markerId) {
    assert(markerId != null);
    return _googleMapsFlutterPlatform.hideMarkerInfoWindow(markerId,
        mapId: mapId);
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool> isMarkerInfoWindowShown(MarkerId markerId) {
    assert(markerId != null);
    return _googleMapsFlutterPlatform.isMarkerInfoWindowShown(markerId,
        mapId: mapId);
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    return _googleMapsFlutterPlatform.getZoomLevel(mapId: mapId);
  }

  /// Returns the image bytes of the map
  Future<Uint8List> takeSnapshot() {
    return _googleMapsFlutterPlatform.takeSnapshot(mapId: mapId);
  }
}
