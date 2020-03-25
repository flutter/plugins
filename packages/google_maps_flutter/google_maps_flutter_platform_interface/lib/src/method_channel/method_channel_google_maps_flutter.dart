// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// An implementation of [GoogleMapsFlutterPlatform] that uses method channels.
class MethodChannelGoogleMapsFlutter extends GoogleMapsFlutterPlatform {
  int _id;

  MethodChannel _channel;

  /// The MethodChannel backing this implementation.
  /// Used in e2e tests (in other package).
  MethodChannel get channel {
    return _channel;
  }

  // TODO: Remove this, and have a private MethodCallHandler that funnels
  // events to the appropriate Stream.
  void setMethodCallHandler(dynamic call) {
    _channel.setMethodCallHandler(call);
  }

  /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  @override
  Future<void> init(int id) {
    this._id = id;
    _channel = MethodChannel('plugins.flutter.io/google_maps_$_id');
    // TODO: Install the internal methodCallHandler here.
    return _channel.invokeMethod<void>('map#waitForMap');
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  @override
  Future<void> updateMapOptions(Map<String, dynamic> optionsUpdate) {
    assert(optionsUpdate != null);
    return _channel.invokeMethod<void>(
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
  @override
  Future<void> updateMarkers(MarkerUpdates markerUpdates) {
    assert(markerUpdates != null);
    return _channel.invokeMethod<void>(
      'markers#update',
      markerUpdates.toJson(),
    );
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  @override
  Future<void> updatePolygons(PolygonUpdates polygonUpdates) {
    assert(polygonUpdates != null);
    return _channel.invokeMethod<void>(
      'polygons#update',
      polygonUpdates.toJson(),
    );
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  @override
  Future<void> updatePolylines(PolylineUpdates polylineUpdates) {
    assert(polylineUpdates != null);
    return _channel.invokeMethod<void>(
      'polylines#update',
      polylineUpdates.toJson(),
    );
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  @override
  Future<void> updateCircles(CircleUpdates circleUpdates) {
    assert(circleUpdates != null);
    return _channel.invokeMethod<void>(
      'circles#update',
      circleUpdates.toJson(),
    );
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return _channel.invokeMethod<void>('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  @override
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return _channel.invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
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
  @override
  Future<void> setMapStyle(String mapStyle) async {
    final List<dynamic> successAndError =
        await _channel.invokeMethod<List<dynamic>>('map#setStyle', mapStyle);
    final bool success = successAndError[0];
    if (!success) {
      throw MapStyleException(successAndError[1]);
    }
  }

  /// Return the region that is visible in a map.
  @override
  Future<LatLngBounds> getVisibleRegion() async {
    final Map<String, dynamic> latLngBounds =
        await _channel.invokeMapMethod<String, dynamic>('map#getVisibleRegion');
    final LatLng southwest = LatLng.fromJson(latLngBounds['southwest']);
    final LatLng northeast = LatLng.fromJson(latLngBounds['northeast']);

    return LatLngBounds(northeast: northeast, southwest: southwest);
  }

  /// Return point [Map<String, int>] of the [screenCoordinateInJson] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    final Map<String, int> point =
        await _channel.invokeMapMethod<String, int>(
        'map#getScreenCoordinate', latLng.toJson());

    return ScreenCoordinate(x: point['x'], y: point['y']);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    final List<dynamic> latLng =
        await _channel.invokeMethod<List<dynamic>>(
        'map#getLatLng', screenCoordinate.toJson());
    return LatLng(latLng[0], latLng[1]);
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  @override
  Future<void> showMarkerInfoWindow(String markerId) {
    assert(markerId != null);
    return _channel.invokeMethod<void>(
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
  @override
  Future<void> hideMarkerInfoWindow(String markerId) {
    assert(markerId != null);
    return _channel.invokeMethod<void>(
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
  @override
  Future<bool> isMarkerInfoWindowShown(String markerId) {
    assert(markerId != null);
    return _channel.invokeMethod<bool>(
        'markers#isInfoWindowShown', <String, String>{'markerId': markerId});
  }

  /// Returns the current zoom level of the map
  @override
  Future<double> getZoomLevel() {
    return _channel.invokeMethod<double>('map#getZoomLevel');
  }

  @override
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
