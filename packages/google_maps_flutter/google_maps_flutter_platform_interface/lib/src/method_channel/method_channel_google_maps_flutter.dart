// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';
import '../types/tile_overlay_updates.dart';
import '../types/utils/tile_overlay.dart';

/// An implementation of [GoogleMapsFlutterPlatform] that uses [MethodChannel] to communicate with the native code.
///
/// The `google_maps_flutter` plugin code itself never talks to the native code directly. It delegates
/// all those calls to an instance of a class that extends the GoogleMapsFlutterPlatform.
///
/// The architecture above allows for platforms that communicate differently with the native side
/// (like web) to have a common interface to extend.
///
/// This is the instance that runs when the native side talks to your Flutter app through MethodChannels,
/// like the Android and iOS platforms.
class MethodChannelGoogleMapsFlutter extends GoogleMapsFlutterPlatform {
  // Keep a collection of id -> channel
  // Every method call passes the int mapId
  final Map<int, MethodChannel> _channels = {};

  /// Accesses the MethodChannel associated to the passed mapId.
  MethodChannel channel(int mapId) {
    return _channels[mapId];
  }

  // Keep a collection of mapId to a map of TileOverlays.
  final Map<int, Map<TileOverlayId, TileOverlay>> _tileOverlays = {};

  /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  @override
  Future<void> init(int mapId) {
    MethodChannel channel;
    if (!_channels.containsKey(mapId)) {
      channel = MethodChannel('plugins.flutter.io/google_maps_$mapId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, mapId));
      _channels[mapId] = channel;
    }
    return channel.invokeMethod<void>('map#waitForMap');
  }

  /// Dispose of the native resources.
  @override
  void dispose({int mapId}) {
    // Noop!
  }

  // The controller we need to broadcast the different events coming
  // from handleMethodCall.
  //
  // It is a `broadcast` because multiple controllers will connect to
  // different stream views of this Controller.
  final StreamController<MapEvent> _mapEventStreamController =
      StreamController<MapEvent>.broadcast();

  // Returns a filtered view of the events in the _controller, by mapId.
  Stream<MapEvent> _events(int mapId) =>
      _mapEventStreamController.stream.where((event) => event.mapId == mapId);

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({@required int mapId}) {
    return _events(mapId).whereType<CameraMoveStartedEvent>();
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({@required int mapId}) {
    return _events(mapId).whereType<CameraMoveEvent>();
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({@required int mapId}) {
    return _events(mapId).whereType<CameraIdleEvent>();
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({@required int mapId}) {
    return _events(mapId).whereType<MarkerTapEvent>();
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({@required int mapId}) {
    return _events(mapId).whereType<InfoWindowTapEvent>();
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({@required int mapId}) {
    return _events(mapId).whereType<MarkerDragEndEvent>();
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({@required int mapId}) {
    return _events(mapId).whereType<PolylineTapEvent>();
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({@required int mapId}) {
    return _events(mapId).whereType<PolygonTapEvent>();
  }

  @override
  Stream<CircleTapEvent> onCircleTap({@required int mapId}) {
    return _events(mapId).whereType<CircleTapEvent>();
  }

  @override
  Stream<MapTapEvent> onTap({@required int mapId}) {
    return _events(mapId).whereType<MapTapEvent>();
  }

  @override
  Stream<MapLongPressEvent> onLongPress({@required int mapId}) {
    return _events(mapId).whereType<MapLongPressEvent>();
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int mapId) async {
    switch (call.method) {
      case 'camera#onMoveStarted':
        _mapEventStreamController.add(CameraMoveStartedEvent(mapId));
        break;
      case 'camera#onMove':
        _mapEventStreamController.add(CameraMoveEvent(
          mapId,
          CameraPosition.fromMap(call.arguments['position']),
        ));
        break;
      case 'camera#onIdle':
        _mapEventStreamController.add(CameraIdleEvent(mapId));
        break;
      case 'marker#onTap':
        _mapEventStreamController.add(MarkerTapEvent(
          mapId,
          MarkerId(call.arguments['markerId']),
        ));
        break;
      case 'marker#onDragEnd':
        _mapEventStreamController.add(MarkerDragEndEvent(
          mapId,
          LatLng.fromJson(call.arguments['position']),
          MarkerId(call.arguments['markerId']),
        ));
        break;
      case 'infoWindow#onTap':
        _mapEventStreamController.add(InfoWindowTapEvent(
          mapId,
          MarkerId(call.arguments['markerId']),
        ));
        break;
      case 'polyline#onTap':
        _mapEventStreamController.add(PolylineTapEvent(
          mapId,
          PolylineId(call.arguments['polylineId']),
        ));
        break;
      case 'polygon#onTap':
        _mapEventStreamController.add(PolygonTapEvent(
          mapId,
          PolygonId(call.arguments['polygonId']),
        ));
        break;
      case 'circle#onTap':
        _mapEventStreamController.add(CircleTapEvent(
          mapId,
          CircleId(call.arguments['circleId']),
        ));
        break;
      case 'map#onTap':
        _mapEventStreamController.add(MapTapEvent(
          mapId,
          LatLng.fromJson(call.arguments['position']),
        ));
        break;
      case 'map#onLongPress':
        _mapEventStreamController.add(MapLongPressEvent(
          mapId,
          LatLng.fromJson(call.arguments['position']),
        ));
        break;
      case 'tileOverlay#getTile':
        final Map<TileOverlayId, TileOverlay> tileOverlaysForThisMap =
            _tileOverlays[mapId];
        final String tileOverlayId = call.arguments['tileOverlayId'];
        final TileOverlay tileOverlay = tileOverlaysForThisMap[tileOverlayId];
        assert(tileOverlay.tileProvider.getTile != null);
        final Tile tile = await tileOverlay.tileProvider.getTile(
          call.arguments['x'],
          call.arguments['y'],
          call.arguments['zoom'],
        );
        return tile.toJson();
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
  @override
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    @required int mapId,
  }) {
    assert(optionsUpdate != null);
    return channel(mapId).invokeMethod<void>(
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
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    @required int mapId,
  }) {
    assert(markerUpdates != null);
    return channel(mapId).invokeMethod<void>(
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
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    @required int mapId,
  }) {
    assert(polygonUpdates != null);
    return channel(mapId).invokeMethod<void>(
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
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    @required int mapId,
  }) {
    assert(polylineUpdates != null);
    return channel(mapId).invokeMethod<void>(
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
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    @required int mapId,
  }) {
    assert(circleUpdates != null);
    return channel(mapId).invokeMethod<void>(
      'circles#update',
      circleUpdates.toJson(),
    );
  }

  /// Updates tile overlay configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  ///
  /// If `newTileOverlays` is null, all the [TileOverlays] are removed for the Map with `mapId`.
  @override
  Future<void> updateTileOverlays({
    Set<TileOverlay> newTileOverlays,
    @required int mapId,
  }) {
    final Map<TileOverlayId, TileOverlay> currentTileOverlays =
        _tileOverlays[mapId];
    Set<TileOverlay> previousSet =
        currentTileOverlays != null ? currentTileOverlays.values.toSet() : null;
    final TileOverlayUpdates updates =
        TileOverlayUpdates.from(previousSet, newTileOverlays);
    _tileOverlays[mapId] = keyTileOverlayId(newTileOverlays);
    return channel(mapId).invokeMethod<void>(
      'tileOverlays#update',
      updates.toJson(),
    );
  }

  /// Clears the tile cache so that all tiles will be requested again from the
  /// [TileProvider].
  ///
  /// The current tiles from this tile overlay will also be
  /// cleared from the map after calling this method. The Google Map SDK maintains a small
  /// in-memory cache of tiles. If you want to cache tiles for longer, you
  /// should implement an on-disk cache.
  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    @required int mapId,
  }) {
    return channel(mapId)
        .invokeMethod<void>('tileOverlays#clearTileCache', <String, dynamic>{
      'tileOverlayId': tileOverlayId.value,
    });
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    @required int mapId,
  }) {
    return channel(mapId)
        .invokeMethod<void>('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    @required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>('camera#move', <String, dynamic>{
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
  Future<void> setMapStyle(
    String mapStyle, {
    @required int mapId,
  }) async {
    final List<dynamic> successAndError = await channel(mapId)
        .invokeMethod<List<dynamic>>('map#setStyle', mapStyle);
    final bool success = successAndError[0];
    if (!success) {
      throw MapStyleException(successAndError[1]);
    }
  }

  /// Return the region that is visible in a map.
  @override
  Future<LatLngBounds> getVisibleRegion({
    @required int mapId,
  }) async {
    final Map<String, dynamic> latLngBounds = await channel(mapId)
        .invokeMapMethod<String, dynamic>('map#getVisibleRegion');
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
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    @required int mapId,
  }) async {
    final Map<String, int> point = await channel(mapId)
        .invokeMapMethod<String, int>(
            'map#getScreenCoordinate', latLng.toJson());

    return ScreenCoordinate(x: point['x'], y: point['y']);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    @required int mapId,
  }) async {
    final List<dynamic> latLng = await channel(mapId)
        .invokeMethod<List<dynamic>>(
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
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    @required int mapId,
  }) {
    assert(markerId != null);
    return channel(mapId).invokeMethod<void>(
        'markers#showInfoWindow', <String, String>{'markerId': markerId.value});
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
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    @required int mapId,
  }) {
    assert(markerId != null);
    return channel(mapId).invokeMethod<void>(
        'markers#hideInfoWindow', <String, String>{'markerId': markerId.value});
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
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    @required int mapId,
  }) {
    assert(markerId != null);
    return channel(mapId).invokeMethod<bool>('markers#isInfoWindowShown',
        <String, String>{'markerId': markerId.value});
  }

  /// Returns the current zoom level of the map
  @override
  Future<double> getZoomLevel({
    @required int mapId,
  }) {
    return channel(mapId).invokeMethod<double>('map#getZoomLevel');
  }

  /// Returns the image bytes of the map
  @override
  Future<Uint8List> takeSnapshot({
    @required int mapId,
  }) {
    return channel(mapId).invokeMethod<Uint8List>('map#takeSnapshot');
  }

  /// This method builds the appropriate platform view where the map
  /// can be rendered.
  /// The `mapId` is passed as a parameter from the framework on the
  /// `onPlatformViewCreated` callback.
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
