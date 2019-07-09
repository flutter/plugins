// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Controller for a single GoogleMap instance running on the host platform.
class GoogleMapController {
  GoogleMapController._(
<<<<<<< .merge_file_lUrGED
    this.channel,
    CameraPosition initialCameraPosition,
    this._googleMapState,
  ) : assert(channel != null) {
    channel.setMethodCallHandler(_handleMethodCall);
=======
    MethodChannel channel,
    CameraPosition initialCameraPosition,
    this._googleMapState,
  )   : assert(channel != null),
        _channel = channel {
    _channel.setMethodCallHandler(_handleMethodCall);
>>>>>>> .merge_file_mz0XLq
  }

  static Future<GoogleMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _GoogleMapState googleMapState,
  ) async {
    assert(id != null);
    final MethodChannel channel =
        MethodChannel('plugins.flutter.io/google_maps_$id');
<<<<<<< .merge_file_lUrGED
    await channel.invokeMethod<void>('map#waitForMap');
=======
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod('map#waitForMap');
>>>>>>> .merge_file_mz0XLq
    return GoogleMapController._(
      channel,
      initialCameraPosition,
      googleMapState,
    );
  }

<<<<<<< .merge_file_lUrGED
  @visibleForTesting
  final MethodChannel channel;
=======
  final MethodChannel _channel;
>>>>>>> .merge_file_mz0XLq

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
          _googleMapState.widget.onCameraIdle(
            MapBounds.fromMap(call.arguments['bounds']),
          );
        }
        break;
      case 'marker#onTap':
        _googleMapState.onMarkerTap(call.arguments['markerId']);
        break;
      case 'infoWindow#onTap':
        _googleMapState.onInfoWindowTap(call.arguments['markerId']);
        break;
<<<<<<< .merge_file_lUrGED
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
        _googleMapState.onTap(LatLng._fromJson(call.arguments['position']));
        break;
      case 'map#onLongPress':
        _googleMapState
            .onLongPress(LatLng._fromJson(call.arguments['position']));
        break;
=======
>>>>>>> .merge_file_mz0XLq
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
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    assert(optionsUpdate != null);
<<<<<<< .merge_file_lUrGED
    await channel.invokeMethod<void>(
=======
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod(
>>>>>>> .merge_file_mz0XLq
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
  Future<void> _updateMarkers(_MarkerUpdates markerUpdates) async {
    assert(markerUpdates != null);
<<<<<<< .merge_file_lUrGED
    await channel.invokeMethod<void>(
=======
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod(
>>>>>>> .merge_file_mz0XLq
      'markers#update',
      markerUpdates._toMap(),
    );
  }

<<<<<<< .merge_file_lUrGED
  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(_PolygonUpdates polygonUpdates) async {
    assert(polygonUpdates != null);
    await channel.invokeMethod<void>(
      'polygons#update',
      polygonUpdates._toMap(),
    );
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(_PolylineUpdates polylineUpdates) async {
    assert(polylineUpdates != null);
    await channel.invokeMethod<void>(
      'polylines#update',
      polylineUpdates._toMap(),
    );
  }

  /// Updates circle configuration.
=======
  /// Updates route configuration.
>>>>>>> .merge_file_mz0XLq
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
<<<<<<< .merge_file_lUrGED
  Future<void> _updateCircles(_CircleUpdates circleUpdates) async {
    assert(circleUpdates != null);
    await channel.invokeMethod<void>(
      'circles#update',
      circleUpdates._toMap(),
=======
  Future<void> _updateMarkerRoutes(_MarkerRouteUpdates routeUpdates) async {
    assert(routeUpdates != null);
    await _channel.invokeMethod(
      'routes#update',
      routeUpdates._toMap(),
>>>>>>> .merge_file_mz0XLq
    );
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
<<<<<<< .merge_file_lUrGED
    await channel.invokeMethod<void>('camera#animate', <String, dynamic>{
=======
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('camera#animate', <String, dynamic>{
>>>>>>> .merge_file_mz0XLq
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
<<<<<<< .merge_file_lUrGED
    await channel.invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
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
        await channel.invokeMethod<List<dynamic>>('map#setStyle', mapStyle);
    final bool success = successAndError[0];
    if (!success) {
      throw MapStyleException(successAndError[1]);
    }
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() async {
    final Map<String, dynamic> latLngBounds =
        await channel.invokeMapMethod<String, dynamic>('map#getVisibleRegion');
    final LatLng southwest = LatLng._fromJson(latLngBounds['southwest']);
    final LatLng northeast = LatLng._fromJson(latLngBounds['northeast']);

    return LatLngBounds(northeast: northeast, southwest: southwest);
  }
=======
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }
>>>>>>> .merge_file_mz0XLq
}
