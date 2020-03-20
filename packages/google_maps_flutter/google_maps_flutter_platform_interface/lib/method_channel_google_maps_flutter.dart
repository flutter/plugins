// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'google_maps_flutter_platform_interface.dart';

MethodChannel _channel;


/// An implementation of [GoogleMapsFlutterPlatform] that uses method channels.
class MethodChannelGoogleMapsFlutter extends GoogleMapsFlutterPlatform {

  int _id;

  /// /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  Future<void> init(int id) {
    this._id = id;
    _channel = MethodChannel('plugins.flutter.io/google_maps_$_id');
    _channel.invokeMethod<void>('map#waitForMap');
  }

  MethodChannel get channel {
    return _channel;
  }

  void setMethodCallHandler(dynamic call) {
    _channel.setMethodCallHandler(call);
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMapOptions(Map<String, dynamic> optionsUpdate) {
    assert(optionsUpdate != null);
    _channel.invokeMethod<void>(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMarkers(Map<String, dynamic> markerUpdates) {
    assert(markerUpdates != null);
    _channel.invokeMethod<void>(
      'markers#update',
      markerUpdates,
    );
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolygons(Map<String, dynamic> polygonUpdates) {
    assert(polygonUpdates != null);
    _channel.invokeMethod<void>(
      'polygons#update',
      polygonUpdates,
    );
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolylines(Map<String, dynamic> polylineUpdates) {
    assert(polylineUpdates != null);
    _channel.invokeMethod<void>(
      'polylines#update',
      polylineUpdates,
    );
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateCircles(Map<String, dynamic> circleUpdates) {
    assert(circleUpdates != null);
    _channel.invokeMethod<void>(
      'circles#update',
      circleUpdates,
    );
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(dynamic cameraUpdate) {
    _channel.invokeMethod<void>('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate,
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(dynamic cameraUpdate) {
    _channel.invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate,
    });
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
    final List<dynamic> successAndError =
        await _channel.invokeMethod<List<dynamic>>('map#setStyle', mapStyle);
    final bool success = successAndError[0];
    if (!success) {
      throw MapStyleException(successAndError[1]);
    }
  }

  /// Return [Map<String, dynamic>] defining the region that is visible in a map.
  Future<Map<String, dynamic>> getVisibleRegion() {
    return _channel
        .invokeMapMethod<String, dynamic>('map#getVisibleRegion');
  }

  /// Return point [Map<String, int>] of the [screenCoordinateInJson] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<Map<String, int>> getScreenCoordinate(
      dynamic screenCoordinateInJson) async {
    final Map<String, int> point = await _channel.invokeMapMethod<String, int>(
        'map#getScreenCoordinate', screenCoordinateInJson);
    return point;
  }

  /// Returns [List] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [List] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<List<dynamic>> getLatLng(dynamic screenCoordinate) {
    return _channel.invokeMethod<List<dynamic>>(
        'map#getLatLng', screenCoordinate.toJson());
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
    assert(markerId != null);
    _channel.invokeMethod<void>(
        'markers#showInfoWindow', <String, String>{'markerId': markerId});
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
    assert(markerId != null);
    _channel.invokeMethod<void>(
        'markers#hideInfoWindow', <String, String>{'markerId': markerId});
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
    assert(markerId != null);
    return _channel.invokeMethod<bool>(
        'markers#isInfoWindowShown', <String, String>{'markerId': markerId});
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() async {
    final double zoomLevel =
        await _channel.invokeMethod<double>('map#getZoomLevel');
    return zoomLevel;
  }

  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.flutter.io/google_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/google_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }


}
