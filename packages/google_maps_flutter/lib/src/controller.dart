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
///
/// Polygon tap events can be received by adding callbacks to [onPolygonTapped].
class GoogleMapController extends ChangeNotifier {
  GoogleMapController._(
    MethodChannel channel,
    CameraPosition initialCameraPosition,
    this._googleMapState,
  )   : assert(channel != null),
        _channel = channel {
    _cameraPosition = initialCameraPosition;
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
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod('map#waitForMap');
    return GoogleMapController._(
      channel,
      initialCameraPosition,
      googleMapState,
    );
  }

  final MethodChannel _channel;

  /// Callbacks to receive tap events for polygons placed on this map.
  final ArgumentCallbacks<Polygon> onPolygonTapped =
      ArgumentCallbacks<Polygon>();

  /// The current set of polygons on this map.
  ///
  /// The returned set will be a detached snapshot of the polygons collection.
  Set<Polygon> get polygons => Set<Polygon>.from(_polygons.values);
  final Map<String, Polygon> _polygons = <String, Polygon>{};

  /// True if the map camera is currently moving.
  bool get isCameraMoving => _isCameraMoving;
  bool _isCameraMoving = false;

  final _GoogleMapState _googleMapState;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if [GoogleMap.trackCameraPosition] is false.
  CameraPosition get cameraPosition => _cameraPosition;
  CameraPosition _cameraPosition;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'polygon#onTap':
        final String polygonId = call.arguments['polygon'];
        final Polygon polygon = _polygons[polygonId];
        if (polygon != null) {
          onPolygonTapped(polygon);
        }
        break;
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

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(_MarkerUpdates markerUpdates) async {
    assert(markerUpdates != null);
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod(
      'markers#update',
      markerUpdates._toMap(),
    );
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

  /// Adds a polygon to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the marker has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added polygon once listeners have
  /// been notified.
  Future<Polygon> addPolygon(PolygonOptions options) async {
    final PolygonOptions effectiveOptions =
        PolygonOptions.defaultOptions.copyWith(options);

    final String polygonId = await _channel.invokeMethod(
      'polygon#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Polygon polygon = Polygon(polygonId, effectiveOptions);
    _polygons[polygonId] = polygon;
    notifyListeners();
    return polygon;
  }

  /// Updates the specified [polygon] with the given [changes]. The polygon must
  /// be a current member of the [polygons] set.
  ///
  /// Change listeners are notified once the polygon has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updatePolygon(Polygon polygon, PolygonOptions changes) async {
    assert(polygon != null);
    assert(_polygons[polygon._id] == polygon);
    assert(changes != null);
    await _channel.invokeMethod('polygon#update', <String, dynamic>{
      'polygonId': polygon._id,
      'options': changes._toJson(),
    });
    polygon._options = polygon._options.copyWith(changes);
    notifyListeners();
  }

  /// Removes the specified [polygon] from the map. The polygon must be a current
  /// member of the [polygons] set.
  ///
  /// Change listeners are notified once the polygon has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removePolygon(Polygon polygon) async {
    assert(polygon != null);
    assert(_polygons[polygon._id] == polygon);
    await _removePolygon(polygon._id);
    notifyListeners();
  }

  /// Removes all [polygons] from the map.
  ///
  /// Change listeners are notified once all polygons have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearPolygons() async {
    assert(_polygons != null);
    final List<String> polygonIds = List<String>.from(_polygons.keys);
    for (String id in polygonIds) {
      await _removePolygon(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single polygon from the map. Consumed by
  /// [removePolygon] and [clearPolygons].
  ///
  /// The returned [Future] completes once the polygon has been removed from
  /// [_polygons].
  Future<void> _removePolygon(String id) async {
    await _channel.invokeMethod('polygon#remove', <String, dynamic>{
      'polygonId': id,
    });
    _polygons.remove(id);
  }
}
