// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

typedef void MapCreatedCallback(GoogleMapController controller);

/// Callback that receives updates to the camera position.
///
/// This callback is triggered when the platform Google Map
/// registers a camera movement.
///
/// This is used in [GoogleMap.onCameraMove].
typedef void CameraPositionCallback(CameraPosition position);

class GoogleMap extends StatefulWidget {
  const GoogleMap({
    Key key,
    @required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,

    /// If no padding is specified default padding will be 0.
    this.padding = const EdgeInsets.all(0),
    this.indoorViewEnabled = false,
    this.markers,
    this.polygons,
    this.polylines,
    this.circles,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  })  : assert(initialCameraPosition != null),
        super(key: key);

  final MapCreatedCallback onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback onCameraIdle;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng> onTap;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng> onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  _GoogleMapOptions _googleMapOptions;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition?._toMap(),
      'options': _googleMapOptions.toMap(),
      'markersToAdd': _serializeMarkerSet(widget.markers),
      'polygonsToAdd': _serializePolygonSet(widget.polygons),
      'polylinesToAdd': _serializePolylineSet(widget.polylines),
      'circlesToAdd': _serializeCircleSet(widget.circles),
    };
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.flutter.io/google_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/google_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  @override
  void initState() {
    super.initState();
    _googleMapOptions = _GoogleMapOptions.fromWidget(widget);
    _markers = _keyByMarkerId(widget.markers);
    _polygons = _keyByPolygonId(widget.polygons);
    _polylines = _keyByPolylineId(widget.polylines);
    _circles = _keyByCircleId(widget.circles);
  }

  @override
  void didUpdateWidget(GoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateMarkers();
    _updatePolygons();
    _updatePolylines();
    _updateCircles();
  }

  void _updateOptions() async {
    final _GoogleMapOptions newOptions = _GoogleMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates =
        _googleMapOptions.updatesMap(newOptions);
    if (updates.isEmpty) {
      return;
    }
    final GoogleMapController controller = await _controller.future;
    controller._updateMapOptions(updates);
    _googleMapOptions = newOptions;
  }

  void _updateMarkers() async {
    final GoogleMapController controller = await _controller.future;
    controller._updateMarkers(
        _MarkerUpdates.from(_markers.values.toSet(), widget.markers));
    _markers = _keyByMarkerId(widget.markers);
  }

  void _updatePolygons() async {
    final GoogleMapController controller = await _controller.future;
    controller._updatePolygons(
        _PolygonUpdates.from(_polygons.values.toSet(), widget.polygons));
    _polygons = _keyByPolygonId(widget.polygons);
  }

  void _updatePolylines() async {
    final GoogleMapController controller = await _controller.future;
    controller._updatePolylines(
        _PolylineUpdates.from(_polylines.values.toSet(), widget.polylines));
    _polylines = _keyByPolylineId(widget.polylines);
  }

  void _updateCircles() async {
    final GoogleMapController controller = await _controller.future;
    controller._updateCircles(
        _CircleUpdates.from(_circles.values.toSet(), widget.circles));
    _circles = _keyByCircleId(widget.circles);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final GoogleMapController controller = await GoogleMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );
    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated(controller);
    }
  }

  void onMarkerTap(String markerIdParam) {
    assert(markerIdParam != null);
    final MarkerId markerId = MarkerId(markerIdParam);
    if (_markers[markerId]?.onTap != null) {
      _markers[markerId].onTap();
    }
  }

  void onMarkerDragEnd(String markerIdParam, LatLng position) {
    assert(markerIdParam != null);
    final MarkerId markerId = MarkerId(markerIdParam);
    if (_markers[markerId]?.onDragEnd != null) {
      _markers[markerId].onDragEnd(position);
    }
  }

  void onPolygonTap(String polygonIdParam) {
    assert(polygonIdParam != null);
    final PolygonId polygonId = PolygonId(polygonIdParam);
    _polygons[polygonId].onTap();
  }

  void onPolylineTap(String polylineIdParam) {
    assert(polylineIdParam != null);
    final PolylineId polylineId = PolylineId(polylineIdParam);
    if (_polylines[polylineId]?.onTap != null) {
      _polylines[polylineId].onTap();
    }
  }

  void onCircleTap(String circleIdParam) {
    assert(circleIdParam != null);
    final CircleId circleId = CircleId(circleIdParam);
    _circles[circleId].onTap();
  }

  void onInfoWindowTap(String markerIdParam) {
    assert(markerIdParam != null);
    final MarkerId markerId = MarkerId(markerIdParam);
    if (_markers[markerId]?.infoWindow?.onTap != null) {
      _markers[markerId].infoWindow.onTap();
    }
  }

  void onTap(LatLng position) {
    assert(position != null);
    if (widget.onTap != null) {
      widget.onTap(position);
    }
  }

  void onLongPress(LatLng position) {
    assert(position != null);
    if (widget.onLongPress != null) {
      widget.onLongPress(position);
    }
  }
}

/// Configuration options for the GoogleMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _GoogleMapOptions {
  _GoogleMapOptions({
    this.compassEnabled,
    this.mapToolbarEnabled,
    this.cameraTargetBounds,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.padding,
    this.indoorViewEnabled,
  });

  static _GoogleMapOptions fromWidget(GoogleMap map) {
    return _GoogleMapOptions(
      compassEnabled: map.compassEnabled,
      mapToolbarEnabled: map.mapToolbarEnabled,
      cameraTargetBounds: map.cameraTargetBounds,
      mapType: map.mapType,
      minMaxZoomPreference: map.minMaxZoomPreference,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      tiltGesturesEnabled: map.tiltGesturesEnabled,
      trackCameraPosition: map.onCameraMove != null,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      myLocationEnabled: map.myLocationEnabled,
      myLocationButtonEnabled: map.myLocationButtonEnabled,
      padding: map.padding,
      indoorViewEnabled: map.indoorViewEnabled,
    );
  }

  final bool compassEnabled;

  final bool mapToolbarEnabled;

  final CameraTargetBounds cameraTargetBounds;

  final MapType mapType;

  final MinMaxZoomPreference minMaxZoomPreference;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  final bool tiltGesturesEnabled;

  final bool trackCameraPosition;

  final bool zoomGesturesEnabled;

  final bool myLocationEnabled;

  final bool myLocationButtonEnabled;

  final EdgeInsets padding;

  final bool indoorViewEnabled;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    addIfNonNull('compassEnabled', compassEnabled);
    addIfNonNull('mapToolbarEnabled', mapToolbarEnabled);
    addIfNonNull('cameraTargetBounds', cameraTargetBounds?._toJson());
    addIfNonNull('mapType', mapType?.index);
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?._toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('tiltGesturesEnabled', tiltGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackCameraPosition', trackCameraPosition);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationButtonEnabled', myLocationButtonEnabled);
    addIfNonNull('padding', <double>[
      padding?.top,
      padding?.left,
      padding?.bottom,
      padding?.right,
    ]);
    addIfNonNull('indoorEnabled', indoorViewEnabled);
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_GoogleMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();

    return newOptions.toMap()
      ..removeWhere(
          (String key, dynamic value) => prevOptionsMap[key] == value);
  }
}
