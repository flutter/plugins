// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/method_channel/method_channel_google_maps_flutter.dart';

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

  static GoogleMapsFlutterPlatform _instance =
      MethodChannelGoogleMapsFlutter();

  /// The default instance of [GoogleMapsFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelGoogleMapsFlutter].
  static GoogleMapsFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GoogleMapsFlutterPlatform] when they register themselves.
  static set instance(GoogleMapsFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  Future<void> init(int id) {
    throw UnimplementedError('init() has not been implemented.');
  }

  void setMethodCallHandler(dynamic call) {
    throw UnimplementedError(
        'setMethodCallHandler() has not been implemented.');
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMapOptions(Map<String, dynamic> optionsUpdate) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMarkers(Map<String, dynamic> markerUpdates) {
    throw UnimplementedError('updateMarkers() has not been implemented.');
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolygons(Map<String, dynamic> polygonUpdates) {
    throw UnimplementedError('updatePolygons() has not been implemented.');
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolylines(Map<String, dynamic> polylineUpdates) {
    throw UnimplementedError('updatePolylines() has not been implemented.');
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateCircles(Map<String, dynamic> circleUpdates) {
    throw UnimplementedError('updateCircles() has not been implemented.');
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(dynamic cameraUpdate) {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(dynamic cameraUpdate) {
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
  Future<void> setMapStyle(String mapStyle) {
    throw UnimplementedError('setMapStyle() has not been implemented.');
  }

  /// Return [Map<String, dynamic>] defining the region that is visible in a map.
  Future<Map<String, dynamic>> getVisibleRegion() {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  /// Return point [Map<String, int>] of the [latLngInJson] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<List<dynamic>> getLatLng(dynamic latLng) {
    throw UnimplementedError('getLatLng() has not been implemented.');
  }

  /// Return point [Map<String, int>] of the [screenCoordinateInJson] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<Map<String, int>> getScreenCoordinate(dynamic screenCoordinateInJson) {
    throw UnimplementedError('getScreenCoordinate() has not been implemented.');
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow(String markerId) {
    throw UnimplementedError(
        'showMarkerInfoWindow() has not been implemented.');
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(String markerId) {
    throw UnimplementedError(
        'hideMarkerInfoWindow() has not been implemented.');
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool> isMarkerInfoWindowShown(String markerId) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    throw UnimplementedError('getZoomLevel() has not been implemented.');
  }

  /// TODO
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {
    throw UnimplementedError('buildView() has not been implemented.');
  }
}
