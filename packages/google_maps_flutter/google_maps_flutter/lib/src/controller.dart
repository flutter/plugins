// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

// TODO: the _googleMapsFlutterPlatform is currently stateful (needs to keep
// subscriptions that are related to the mapId), however this is a singleton.
// We need to be able to create configured instances of the platform.
final GoogleMapsFlutterPlatform _googleMapsFlutterPlatform =
    GoogleMapsFlutterPlatform.instance;

/// Controller for a single GoogleMap instance running on the host platform.
class GoogleMapController {
  GoogleMapController._(
    CameraPosition initialCameraPosition,
    this._googleMapState,
  ) : assert(_googleMapsFlutterPlatform != null) {
    _googleMapsFlutterPlatform.setMethodCallHandler(_handleMethodCall);
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
    );
  }

  /// Used to communicate with the native platform.
  ///
  /// Accessible only for testing.
  // TODO: Remove this once tests are migrated to not need this.
  @visibleForTesting
  MethodChannel get channel {
    if (_googleMapsFlutterPlatform is MethodChannelGoogleMapsFlutter) {
      return (_googleMapsFlutterPlatform as MethodChannelGoogleMapsFlutter)
          .channel;
    }
    return null;
  }

  final _GoogleMapState _googleMapState;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'camera#onMoveStarted':
        if (_googleMapState.widget.onCameraMoveStarted != null) {
          _googleMapState.widget.onCameraMoveStarted();
        }
        break;
      case 'camera#onMove':
        if (_googleMapState.widget.onCameraMove != null) {
          _googleMapState.widget.onCameraMove(
            CameraPosition.fromMap(call.arguments['position']),
          );
        }
        break;
      case 'camera#onIdle':
        if (_googleMapState.widget.onCameraIdle != null) {
          _googleMapState.widget.onCameraIdle();
        }
        break;
      case 'marker#onTap':
        _googleMapState.onMarkerTap(call.arguments['markerId']);
        break;
      case 'marker#onDragEnd':
        _googleMapState.onMarkerDragEnd(call.arguments['markerId'],
            LatLng.fromJson(call.arguments['position']));
        break;
      case 'infoWindow#onTap':
        _googleMapState.onInfoWindowTap(call.arguments['markerId']);
        break;
      case 'polyline#onTap':
        _googleMapState.onPolylineTap(call.arguments['polylineId']);
        break;
      case 'polygon#onTap':
        _googleMapState.onPolygonTap(call.arguments['polygonId']);
        break;
      case 'circle#onTap':
        _googleMapState.onCircleTap(call.arguments['circleId']);
        break;
      case 'map#onTap':
        _googleMapState.onTap(LatLng.fromJson(call.arguments['position']));
        break;
      case 'map#onLongPress':
        _googleMapState
            .onLongPress(LatLng.fromJson(call.arguments['position']));
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) {
    assert(optionsUpdate != null);
    return _googleMapsFlutterPlatform.updateMapOptions(optionsUpdate);
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    assert(markerUpdates != null);
    return _googleMapsFlutterPlatform.updateMarkers(markerUpdates);
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    assert(polygonUpdates != null);
    return _googleMapsFlutterPlatform.updatePolygons(polygonUpdates);
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    assert(polylineUpdates != null);
    return _googleMapsFlutterPlatform.updatePolylines(polylineUpdates);
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    assert(circleUpdates != null);
    return _googleMapsFlutterPlatform.updateCircles(circleUpdates);
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return _googleMapsFlutterPlatform.animateCamera(cameraUpdate);
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return _googleMapsFlutterPlatform.moveCamera(cameraUpdate);
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
    return _googleMapsFlutterPlatform.setMapStyle(mapStyle);
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    return _googleMapsFlutterPlatform.getVisibleRegion();
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return _googleMapsFlutterPlatform.getScreenCoordinate(latLng);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return _googleMapsFlutterPlatform.getLatLng(screenCoordinate);
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
    return _googleMapsFlutterPlatform.showMarkerInfoWindow(markerId);
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
    return _googleMapsFlutterPlatform.hideMarkerInfoWindow(markerId);
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
    return _googleMapsFlutterPlatform.isMarkerInfoWindowShown(markerId);
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    return _googleMapsFlutterPlatform.getZoomLevel();
  }

  /// Returns the image bytes of the map
  Future<Uint8List> takeSnapshot() async {
    return await channel.invokeMethod<Uint8List>('map#takeSnapshot');
  }
}
