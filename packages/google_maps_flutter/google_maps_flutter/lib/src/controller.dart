// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Controller for a single GoogleMap instance running on the host platform.
class GoogleMapController {
  /// The mapId for this controller
  final int mapId;

  GoogleMapController._(
    CameraPosition initialCameraPosition,
    this._googleMapState, {
    required this.mapId,
  }) {
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
    await GoogleMapsFlutterPlatform.instance.init(id);
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
  MethodChannel? get channel {
    if (GoogleMapsFlutterPlatform.instance is MethodChannelGoogleMapsFlutter) {
      return (GoogleMapsFlutterPlatform.instance
              as MethodChannelGoogleMapsFlutter)
          .channel(mapId);
    }
    return null;
  }

  final _GoogleMapState _googleMapState;

  void _connectStreams(int mapId) {
    if (_googleMapState.widget.onCameraMoveStarted != null) {
      GoogleMapsFlutterPlatform.instance
          .onCameraMoveStarted(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraMoveStarted!());
    }
    if (_googleMapState.widget.onCameraMove != null) {
      GoogleMapsFlutterPlatform.instance.onCameraMove(mapId: mapId).listen(
          (CameraMoveEvent e) => _googleMapState.widget.onCameraMove!(e.value));
    }
    if (_googleMapState.widget.onCameraIdle != null) {
      GoogleMapsFlutterPlatform.instance
          .onCameraIdle(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraIdle!());
    }
    GoogleMapsFlutterPlatform.instance
        .onMarkerTap(mapId: mapId)
        .listen((MarkerTapEvent e) => _googleMapState.onMarkerTap(e.value));
    GoogleMapsFlutterPlatform.instance.onMarkerDragEnd(mapId: mapId).listen(
        (MarkerDragEndEvent e) =>
            _googleMapState.onMarkerDragEnd(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onInfoWindowTap(mapId: mapId).listen(
        (InfoWindowTapEvent e) => _googleMapState.onInfoWindowTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onPolylineTap(mapId: mapId)
        .listen((PolylineTapEvent e) => _googleMapState.onPolylineTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onPolygonTap(mapId: mapId)
        .listen((PolygonTapEvent e) => _googleMapState.onPolygonTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onCircleTap(mapId: mapId)
        .listen((CircleTapEvent e) => _googleMapState.onCircleTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onTap(mapId: mapId)
        .listen((MapTapEvent e) => _googleMapState.onTap(e.position));
    GoogleMapsFlutterPlatform.instance.onLongPress(mapId: mapId).listen(
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
    return GoogleMapsFlutterPlatform.instance
        .updateMapOptions(optionsUpdate, mapId: mapId);
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    assert(markerUpdates != null);
    return GoogleMapsFlutterPlatform.instance
        .updateMarkers(markerUpdates, mapId: mapId);
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    assert(polygonUpdates != null);
    return GoogleMapsFlutterPlatform.instance
        .updatePolygons(polygonUpdates, mapId: mapId);
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    assert(polylineUpdates != null);
    return GoogleMapsFlutterPlatform.instance
        .updatePolylines(polylineUpdates, mapId: mapId);
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    assert(circleUpdates != null);
    return GoogleMapsFlutterPlatform.instance
        .updateCircles(circleUpdates, mapId: mapId);
  }

  /// Updates tile overlays configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateTileOverlays(Set<TileOverlay> newTileOverlays) {
    return GoogleMapsFlutterPlatform.instance
        .updateTileOverlays(newTileOverlays: newTileOverlays, mapId: mapId);
  }

  /// Clears the tile cache so that all tiles will be requested again from the
  /// [TileProvider].
  ///
  /// The current tiles from this tile overlay will also be
  /// cleared from the map after calling this method. The API maintains a small
  /// in-memory cache of tiles. If you want to cache tiles for longer, you
  /// should implement an on-disk cache.
  Future<void> clearTileCache(TileOverlayId tileOverlayId) async {
    assert(tileOverlayId != null);
    return GoogleMapsFlutterPlatform.instance
        .clearTileCache(tileOverlayId, mapId: mapId);
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsFlutterPlatform.instance
        .animateCamera(cameraUpdate, mapId: mapId);
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsFlutterPlatform.instance
        .moveCamera(cameraUpdate, mapId: mapId);
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
  Future<void> setMapStyle(String? mapStyle) {
    return GoogleMapsFlutterPlatform.instance
        .setMapStyle(mapStyle, mapId: mapId);
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    return GoogleMapsFlutterPlatform.instance.getVisibleRegion(mapId: mapId);
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return GoogleMapsFlutterPlatform.instance
        .getScreenCoordinate(latLng, mapId: mapId);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return GoogleMapsFlutterPlatform.instance
        .getLatLng(screenCoordinate, mapId: mapId);
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
    return GoogleMapsFlutterPlatform.instance
        .showMarkerInfoWindow(markerId, mapId: mapId);
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
    return GoogleMapsFlutterPlatform.instance
        .hideMarkerInfoWindow(markerId, mapId: mapId);
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
    return GoogleMapsFlutterPlatform.instance
        .isMarkerInfoWindowShown(markerId, mapId: mapId);
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    return GoogleMapsFlutterPlatform.instance.getZoomLevel(mapId: mapId);
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot() {
    return GoogleMapsFlutterPlatform.instance.takeSnapshot(mapId: mapId);
  }

  /// Disposes of the platform resources
  void dispose() {
    GoogleMapsFlutterPlatform.instance.dispose(mapId: mapId);
  }
}
