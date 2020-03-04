// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_google_maps_flutter.dart';

/// Exception when a map style is invalid or was unable to be set.
///
/// See also: `setStyle` on [GoogleMapController] for why this exception
/// might be thrown.
class MapStyleException implements Exception {
  /// Default constructor for [MapStyleException].
  const MapStyleException(this.cause);

  /// The reason `GoogleMapController.setStyle` would throw this exception.
  final String cause;
}


/// Represents a point coordinate in the [GoogleMap]'s view.
///
/// The screen location is specified in screen pixels (not display pixels) relative
/// to the top left of the map, not top left of the whole screen. (x, y) = (0, 0)
/// corresponds to top-left of the [GoogleMap] not the whole screen.
@immutable
class ScreenCoordinate {
  /// Creates an immutable representation of a point coordinate in the [GoogleMap]'s view.
  const ScreenCoordinate({
    @required this.x,
    @required this.y,
  });

  /// Represents the number of pixels from the left of the [GoogleMap].
  final int x;

  /// Represents the number of pixels from the top of the [GoogleMap].
  final int y;

  /// [x] [y] coordinate in Json format
  dynamic toJson() {
    return <String, int>{
      "x": x,
      "y": y,
    };
  }

  @override
  String toString() => '$runtimeType($x, $y)';

  @override
  bool operator ==(Object o) {
    return o is ScreenCoordinate && o.x == x && o.y == y;
  }

  @override
  int get hashCode => hashValues(x, y);
}

/// The interface that implementations of google_maps_flutter must implement.
///
/// Platform implementations should extend this class rather than implement it as `google_maps_flutter`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [GoogleMapsFlutterPlatform] methods.
abstract class GoogleMapsFlutterPlatform extends PlatformInterface {
  /// Constructs a GoogleMapsFlutterPlatform.
  GoogleMapsFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static GoogleMapsFlutterPlatform _instance = MethodChannelGoogleMapsFlutter(0);

  /// The default instance of [GoogleMapsFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelUrlLauncher].
  static GoogleMapsFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GoogleMapsFlutterPlatform] when they register themselves.
  static set instance(GoogleMapsFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMarkers(Map<String, dynamic> markerUpdates) async {
    throw UnimplementedError('updateMarkers() has not been implemented.');
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolygons(Map<String, dynamic> polygonUpdates) async {
    throw UnimplementedError('updatePolygons() has not been implemented.');
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolylines(Map<String, dynamic> polylineUpdates) async {
    throw UnimplementedError('updatePolylines() has not been implemented.');
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateCircles(Map<String, dynamic> circleUpdates) async {
    throw UnimplementedError('updateCircles() has not been implemented.');
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(Map<String, dynamic> cameraUpdate) async {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(Map<String, dynamic> cameraUpdate) async {
    throw UnimplementedError('moveCamera() has not been implemented.');
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
  Future<void> setMapStyle(String mapStyle) async {
    throw UnimplementedError('setMapStyle() has not been implemented.');
  }

  /// Return [Map<String, dynamic>] defining the region that is visible in a map.
  Future<Map<String, dynamic>> getVisibleRegion() async {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  /// Returns [List] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [List] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<List<dynamic>> getLatLng(ScreenCoordinate screenCoordinate) async {
    throw UnimplementedError('getLatLng() has not been implemented.');
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow( String markerId ) async {
    throw UnimplementedError('showMarkerInfoWindow() has not been implemented.');
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(String markerId ) async {
    throw UnimplementedError('hideMarkerInfoWindow() has not been implemented.');
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool> isMarkerInfoWindowShown(String markerId ) async {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() async {
    throw UnimplementedError('getZoomLevel() has not been implemented.');
  }
}
