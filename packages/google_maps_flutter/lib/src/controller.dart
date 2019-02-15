// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Controller for a single GoogleMap instance running on the host platform.
///
/// Change listeners are notified upon changes to any of
///
/// * the [options] property
/// * the [isCameraMoving] property
/// * the [cameraPosition] property
///
/// Listeners are notified after changes have been applied on the platform side.
class GoogleMapController extends ChangeNotifier {
  GoogleMapController._(
      MethodChannel channel, CameraPosition initialCameraPosition)
      : assert(channel != null),
        _channel = channel {
    _cameraPosition = initialCameraPosition;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<GoogleMapController> init(
      int id, CameraPosition initialCameraPosition) async {
    assert(id != null);
    final MethodChannel channel =
        MethodChannel('plugins.flutter.io/google_maps_$id');
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod('map#waitForMap');
    return GoogleMapController._(channel, initialCameraPosition);
  }

  final MethodChannel _channel;

  /// True if the map camera is currently moving.
  bool get isCameraMoving => _isCameraMoving;
  bool _isCameraMoving = false;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if [GoogleMap.trackCameraPosition] is false.
  CameraPosition get cameraPosition => _cameraPosition;
  CameraPosition _cameraPosition;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'camera#onMoveStarted':
        _isCameraMoving = true;
        notifyListeners();
        break;
      case 'camera#onMove':
        _cameraPosition = CameraPosition.fromMap(call.arguments['position']);
        notifyListeners();
        break;
      case 'camera#onIdle':
        _isCameraMoving = false;
        notifyListeners();
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
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final dynamic json = await _channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
    _cameraPosition = CameraPosition.fromMap(json);
    notifyListeners();
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }
}

/// Manages lifecycle of [MarkerController] for all [Marker]s.
///
/// Change listeners are notified upon changes to any of the markers.
class MarkerControllers extends ChangeNotifier {
  MarkerControllers();

  final Map<MarkerId, MarkerController> _markerControllers =
      <MarkerId, MarkerController>{};

  void update(MarkerUpdates markerUpdates) {
    markerUpdates.markerUpdates.forEach((MarkerUpdate markerUpdate) {
      final MarkerId markerId = markerUpdate.markerId;
      switch (markerUpdate.updateEventType) {
        case MarkerUpdateEventType.update:
          _markerControllers[markerId].setMarker(markerUpdate.newMarker);
          break;
        case MarkerUpdateEventType.add:
          final MarkerController controller =
              MarkerController.init(markerUpdate.changes);
          _markerControllers[markerId] = controller;
          break;
        case MarkerUpdateEventType.remove:
          // TODO (kaushik) any other channel cleanup?
          _markerControllers.remove(markerId);
          break;
        default:
          throw Exception("Unknown markerUpdate type.");
      }
    });
    notifyListeners();
  }
}

/// Handles callbacks for events on [Marker] and [InfoWindow].
class MarkerController {
  MarkerController._(this._marker, MethodChannel channel)
      : assert(_marker != null),
        assert(channel != null),
        _channel = channel {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  factory MarkerController.init(Marker marker) {
    assert(marker != null);
    final String id = marker.markerId.value;
    // TODO (kaushik) using id in the plugin handle might not be a good idea.
    final String channelName = 'plugins.flutter.io/google_maps_markers_$id';
    final MethodChannel channel = MethodChannel(channelName);
    return MarkerController._(marker, channel);
  }

  final MethodChannel _channel;
  Marker _marker;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'marker#onTap':
        _marker.onTap();
        break;
      case 'infoWindow#onTap':
        _marker.infoWindow?.onTap();
        break;
      default:
        throw MissingPluginException();
    }
  }

  void setMarker(Marker marker) {
    _marker = marker;
  }
}
