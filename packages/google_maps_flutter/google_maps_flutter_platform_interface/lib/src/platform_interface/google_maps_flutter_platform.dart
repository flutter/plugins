// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:google_maps_flutter_platform_interface/src/method_channel/method_channel_google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that platform-specific implementations of `google_maps_flutter` must extend.
///
/// Avoid `implements` of this interface. Using `implements` makes adding any new
/// methods here a breaking change for end users of your platform!
///
/// Do `extends GoogleMapsFlutterPlatform` instead, so new methods added here are
/// inherited in your code with the default implementation (that throws at runtime),
/// rather than breaking your users at compile time.
abstract class GoogleMapsFlutterPlatform extends PlatformInterface {
  /// Constructs a GoogleMapsFlutterPlatform.
  GoogleMapsFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static GoogleMapsFlutterPlatform _instance = MethodChannelGoogleMapsFlutter();

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
  Future<void> init(int mapId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    @required int mapId,
  }) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    @required int mapId,
  }) {
    throw UnimplementedError('updateMarkers() has not been implemented.');
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    @required int mapId,
  }) {
    throw UnimplementedError('updatePolygons() has not been implemented.');
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    @required int mapId,
  }) {
    throw UnimplementedError('updatePolylines() has not been implemented.');
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    @required int mapId,
  }) {
    throw UnimplementedError('updateCircles() has not been implemented.');
  }

  /// Updates tile overlay configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateTileOverlays({
    Set<TileOverlay> newTileOverlays,
    @required int mapId,
  }) {
    throw UnimplementedError('updateTileOverlays() has not been implemented.');
  }

  /// Clears the tile cache so that all tiles will be requested again from the
  /// [TileProvider].
  ///
  /// The current tiles from this tile overlay will also be
  /// cleared from the map after calling this method. The Google Maps SDK maintains a small
  /// in-memory cache of tiles. If you want to cache tiles for longer, you
  /// should implement an on-disk cache.
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    @required int mapId,
  }) {
    throw UnimplementedError('clearTileCache() has not been implemented.');
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    @required int mapId,
  }) {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    @required int mapId,
  }) {
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
  Future<void> setMapStyle(
    String mapStyle, {
    @required int mapId,
  }) {
    throw UnimplementedError('setMapStyle() has not been implemented.');
  }

  /// Return the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion({
    @required int mapId,
  }) {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    @required int mapId,
  }) {
    throw UnimplementedError('getScreenCoordinate() has not been implemented.');
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    @required int mapId,
  }) {
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
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    @required int mapId,
  }) {
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
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    @required int mapId,
  }) {
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
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    @required int mapId,
  }) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel({
    @required int mapId,
  }) {
    throw UnimplementedError('getZoomLevel() has not been implemented.');
  }

  /// Returns the image bytes of the map
  Future<Uint8List> takeSnapshot({
    @required int mapId,
  }) {
    throw UnimplementedError('takeSnapshot() has not been implemented.');
  }

  // The following are the 11 possible streams of data from the native side
  // into the plugin

  /// The Camera started moving.
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({@required int mapId}) {
    throw UnimplementedError('onCameraMoveStarted() has not been implemented.');
  }

  /// The Camera finished moving to a new [CameraPosition].
  Stream<CameraMoveEvent> onCameraMove({@required int mapId}) {
    throw UnimplementedError('onCameraMove() has not been implemented.');
  }

  /// The Camera is now idle.
  Stream<CameraIdleEvent> onCameraIdle({@required int mapId}) {
    throw UnimplementedError('onCameraMove() has not been implemented.');
  }

  /// A [Marker] has been tapped.
  Stream<MarkerTapEvent> onMarkerTap({@required int mapId}) {
    throw UnimplementedError('onMarkerTap() has not been implemented.');
  }

  /// An [InfoWindow] has been tapped.
  Stream<InfoWindowTapEvent> onInfoWindowTap({@required int mapId}) {
    throw UnimplementedError('onInfoWindowTap() has not been implemented.');
  }

  /// A [Marker] has been dragged to a different [LatLng] position.
  Stream<MarkerDragEndEvent> onMarkerDragEnd({@required int mapId}) {
    throw UnimplementedError('onMarkerDragEnd() has not been implemented.');
  }

  /// A [Polyline] has been tapped.
  Stream<PolylineTapEvent> onPolylineTap({@required int mapId}) {
    throw UnimplementedError('onPolylineTap() has not been implemented.');
  }

  /// A [Polygon] has been tapped.
  Stream<PolygonTapEvent> onPolygonTap({@required int mapId}) {
    throw UnimplementedError('onPolygonTap() has not been implemented.');
  }

  /// A [Circle] has been tapped.
  Stream<CircleTapEvent> onCircleTap({@required int mapId}) {
    throw UnimplementedError('onCircleTap() has not been implemented.');
  }

  /// A Map has been tapped at a certain [LatLng].
  Stream<MapTapEvent> onTap({@required int mapId}) {
    throw UnimplementedError('onTap() has not been implemented.');
  }

  /// A Map has been long-pressed at a certain [LatLng].
  Stream<MapLongPressEvent> onLongPress({@required int mapId}) {
    throw UnimplementedError('onLongPress() has not been implemented.');
  }

  /// Dispose of whatever resources the `mapId` is holding on to.
  void dispose({@required int mapId}) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// Returns a widget displaying the map view
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {
    throw UnimplementedError('buildView() has not been implemented.');
  }
}
