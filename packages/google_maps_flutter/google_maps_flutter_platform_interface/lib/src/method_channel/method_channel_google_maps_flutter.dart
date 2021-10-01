// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

import '../types/tile_overlay_updates.dart';
import '../types/utils/tile_overlay.dart';

/// Error thrown when an unknown map ID is provided to a method channel API.
class UnknownMapIDError extends Error {
  /// Creates an assertion error with the provided [mapId] and optional
  /// [message].
  UnknownMapIDError(this.mapId, [this.message]);

  /// The unknown ID.
  final int mapId;

  /// Message describing the assertion error.
  final Object? message;

  String toString() {
    if (message != null) {
      return "Unknown map ID $mapId: ${Error.safeToString(message)}";
    }
    return "Unknown map ID $mapId";
  }
}

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
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      throw UnknownMapIDError(mapId);
    }
    return channel;
  }

  // Keep a collection of mapId to a map of TileOverlays.
  final Map<int, Map<TileOverlayId, TileOverlay>> _tileOverlays = {};

  /// Returns the channel for [mapId], creating it if it doesn't already exist.
  @visibleForTesting
  MethodChannel ensureChannelInitialized(int mapId) {
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      channel = MethodChannel('plugins.flutter.io/google_maps_$mapId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, mapId));
      _channels[mapId] = channel;
    }
    return channel;
  }

  @override
  Future<void> init(int mapId) {
    MethodChannel channel = ensureChannelInitialized(mapId);
    return channel.invokeMethod<void>('map#waitForMap');
  }

  @override
  void dispose({required int mapId}) {
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
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) {
    return _events(mapId).whereType<CameraMoveStartedEvent>();
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) {
    return _events(mapId).whereType<CameraMoveEvent>();
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) {
    return _events(mapId).whereType<CameraIdleEvent>();
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) {
    return _events(mapId).whereType<MarkerTapEvent>();
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) {
    return _events(mapId).whereType<InfoWindowTapEvent>();
  }

  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) {
    return _events(mapId).whereType<MarkerDragStartEvent>();
  }

  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) {
    return _events(mapId).whereType<MarkerDragEvent>();
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) {
    return _events(mapId).whereType<MarkerDragEndEvent>();
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) {
    return _events(mapId).whereType<PolylineTapEvent>();
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) {
    return _events(mapId).whereType<PolygonTapEvent>();
  }

  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) {
    return _events(mapId).whereType<CircleTapEvent>();
  }

  @override
  Stream<MapTapEvent> onTap({required int mapId}) {
    return _events(mapId).whereType<MapTapEvent>();
  }

  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) {
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
          CameraPosition.fromMap(call.arguments['position'])!,
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
      case 'marker#onDragStart':
        _mapEventStreamController.add(MarkerDragStartEvent(
          mapId,
          LatLng.fromJson(call.arguments['position'])!,
          MarkerId(call.arguments['markerId']),
        ));
        break;
      case 'marker#onDrag':
        _mapEventStreamController.add(MarkerDragEvent(
          mapId,
          LatLng.fromJson(call.arguments['position'])!,
          MarkerId(call.arguments['markerId']),
        ));
        break;
      case 'marker#onDragEnd':
        _mapEventStreamController.add(MarkerDragEndEvent(
          mapId,
          LatLng.fromJson(call.arguments['position'])!,
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
          LatLng.fromJson(call.arguments['position'])!,
        ));
        break;
      case 'map#onLongPress':
        _mapEventStreamController.add(MapLongPressEvent(
          mapId,
          LatLng.fromJson(call.arguments['position'])!,
        ));
        break;
      case 'tileOverlay#getTile':
        final Map<TileOverlayId, TileOverlay>? tileOverlaysForThisMap =
            _tileOverlays[mapId];
        final String tileOverlayId = call.arguments['tileOverlayId'];
        final TileOverlay? tileOverlay =
            tileOverlaysForThisMap?[TileOverlayId(tileOverlayId)];
        TileProvider? tileProvider = tileOverlay?.tileProvider;
        if (tileProvider == null) {
          return TileProvider.noTile.toJson();
        }
        final Tile tile = await tileProvider.getTile(
          call.arguments['x'],
          call.arguments['y'],
          call.arguments['zoom'],
        );
        return tile.toJson();
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    required int mapId,
  }) {
    assert(optionsUpdate != null);
    return channel(mapId).invokeMethod<void>(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
  }

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) {
    assert(markerUpdates != null);
    return channel(mapId).invokeMethod<void>(
      'markers#update',
      markerUpdates.toJson(),
    );
  }

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) {
    assert(polygonUpdates != null);
    return channel(mapId).invokeMethod<void>(
      'polygons#update',
      polygonUpdates.toJson(),
    );
  }

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) {
    assert(polylineUpdates != null);
    return channel(mapId).invokeMethod<void>(
      'polylines#update',
      polylineUpdates.toJson(),
    );
  }

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) {
    assert(circleUpdates != null);
    return channel(mapId).invokeMethod<void>(
      'circles#update',
      circleUpdates.toJson(),
    );
  }

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) {
    final Map<TileOverlayId, TileOverlay>? currentTileOverlays =
        _tileOverlays[mapId];
    Set<TileOverlay> previousSet = currentTileOverlays != null
        ? currentTileOverlays.values.toSet()
        : <TileOverlay>{};
    final TileOverlayUpdates updates =
        TileOverlayUpdates.from(previousSet, newTileOverlays);
    _tileOverlays[mapId] = keyTileOverlayId(newTileOverlays);
    return channel(mapId).invokeMethod<void>(
      'tileOverlays#update',
      updates.toJson(),
    );
  }

  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) {
    return channel(mapId)
        .invokeMethod<void>('tileOverlays#clearTileCache', <String, Object>{
      'tileOverlayId': tileOverlayId.value,
    });
  }

  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>('camera#animate', <String, Object>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<void> setMapStyle(
    String? mapStyle, {
    required int mapId,
  }) async {
    final List<dynamic> successAndError = (await channel(mapId)
        .invokeMethod<List<dynamic>>('map#setStyle', mapStyle))!;
    final bool success = successAndError[0];
    if (!success) {
      throw MapStyleException(successAndError[1]);
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    required int mapId,
  }) async {
    final Map<String, dynamic> latLngBounds = (await channel(mapId)
        .invokeMapMethod<String, dynamic>('map#getVisibleRegion'))!;
    final LatLng southwest = LatLng.fromJson(latLngBounds['southwest'])!;
    final LatLng northeast = LatLng.fromJson(latLngBounds['northeast'])!;

    return LatLngBounds(northeast: northeast, southwest: southwest);
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) async {
    final Map<String, int> point = (await channel(mapId)
        .invokeMapMethod<String, int>(
            'map#getScreenCoordinate', latLng.toJson()))!;

    return ScreenCoordinate(x: point['x']!, y: point['y']!);
  }

  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) async {
    final List<dynamic> latLng = (await channel(mapId)
        .invokeMethod<List<dynamic>>(
            'map#getLatLng', screenCoordinate.toJson()))!;
    return LatLng(latLng[0], latLng[1]);
  }

  @override
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) {
    assert(markerId != null);
    return channel(mapId).invokeMethod<void>(
        'markers#showInfoWindow', <String, String>{'markerId': markerId.value});
  }

  @override
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) {
    assert(markerId != null);
    return channel(mapId).invokeMethod<void>(
        'markers#hideInfoWindow', <String, String>{'markerId': markerId.value});
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    required int mapId,
  }) async {
    assert(markerId != null);
    return (await channel(mapId).invokeMethod<bool>('markers#isInfoWindowShown',
        <String, String>{'markerId': markerId.value}))!;
  }

  @override
  Future<double> getZoomLevel({
    required int mapId,
  }) async {
    return (await channel(mapId).invokeMethod<double>('map#getZoomLevel'))!;
  }

  @override
  Future<Uint8List?> takeSnapshot({
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<Uint8List>('map#takeSnapshot');
  }

  /// Set [GoogleMapsFlutterPlatform] to use [AndroidViewSurface] to build the Google Maps widget.
  ///
  /// This implementation uses hybrid composition to render the Google Maps
  /// Widget on Android. This comes at the cost of some performance on Android
  /// versions below 10. See
  /// https://flutter.dev/docs/development/platform-integration/platform-views#performance for more
  /// information.
  ///
  /// If set to true, the google map widget should be built with
  /// [buildViewWithTextDirection] instead of [buildView].
  ///
  /// Defaults to false.
  bool useAndroidViewSurface = false;

  @override
  Widget buildViewWithTextDirection(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    required TextDirection textDirection,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': initialCameraPosition.toMap(),
      'options': mapOptions,
      'markersToAdd': serializeMarkerSet(markers),
      'polygonsToAdd': serializePolygonSet(polygons),
      'polylinesToAdd': serializePolylineSet(polylines),
      'circlesToAdd': serializeCircleSet(circles),
      'tileOverlaysToAdd': serializeTileOverlaySet(tileOverlays),
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (useAndroidViewSurface) {
        return PlatformViewLink(
          viewType: 'plugins.flutter.io/google_maps',
          surfaceFactory: (
            BuildContext context,
            PlatformViewController controller,
          ) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: gestureRecognizers ??
                  const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            final SurfaceAndroidViewController controller =
                PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'plugins.flutter.io/google_maps',
              layoutDirection: textDirection,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            );
            controller.addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated,
            );
            controller.addOnPlatformViewCreatedListener(
              onPlatformViewCreated,
            );

            controller.create();
            return controller;
          },
        );
      } else {
        return AndroidView(
          viewType: 'plugins.flutter.io/google_maps',
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: gestureRecognizers,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
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

  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    return buildViewWithTextDirection(
      creationId,
      onPlatformViewCreated,
      initialCameraPosition: initialCameraPosition,
      textDirection: TextDirection.ltr,
      markers: markers,
      polygons: polygons,
      polylines: polylines,
      circles: circles,
      tileOverlays: tileOverlays,
      gestureRecognizers: gestureRecognizers,
      mapOptions: mapOptions,
    );
  }
}
