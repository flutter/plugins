// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Controller for a single GoogleMap instance running on the host platform.
class GoogleMapController {
  GoogleMapController._(
    MethodChannel channel,
    CameraPosition initialCameraPosition,
    this._googleMapState,
  )   : assert(channel != null),
        _channel = channel {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<GoogleMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _GoogleMapState googleMapState,
  ) async {
    assert(id != null);
    final MethodChannel channel =
        MethodChannel('plugins.flutter.io/google_maps_$id');
    await channel.invokeMethod<void>('map#waitForMap');
    return GoogleMapController._(
      channel,
      initialCameraPosition,
      googleMapState,
    );
  }

  final MethodChannel _channel;

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
      case 'infoWindow#onTap':
        _googleMapState.onInfoWindowTap(call.arguments['markerId']);
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
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    assert(optionsUpdate != null);
    await _channel.invokeMethod<void>(
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
    await _channel.invokeMethod<void>(
      'markers#update',
      markerUpdates._toMap(),
    );
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _channel.invokeMethod<void>('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await _channel.invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }
}
