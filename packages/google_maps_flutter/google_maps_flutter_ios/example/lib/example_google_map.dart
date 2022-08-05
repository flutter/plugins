// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// This is a pared down version of the Dart code from the app-facing package,
// to allow running the same examples for package-local testing.
// TODO(stuartmorgan): Consider extracting this to a shared package. See also
// https://github.com/flutter/flutter/issues/46716.

/// Controller for a single ExampleGoogleMap instance running on the host platform.
class ExampleGoogleMapController {
  ExampleGoogleMapController._(
    this._googleMapState, {
    required this.mapId,
  }) {
    _connectStreams(mapId);
  }

  /// The mapId for this controller
  final int mapId;

  /// Initialize control of a [ExampleGoogleMap] with [id].
  ///
  /// Mainly for internal use when instantiating a [ExampleGoogleMapController] passed
  /// in [ExampleGoogleMap.onMapCreated] callback.
  static Future<ExampleGoogleMapController> _init(
    int id,
    CameraPosition initialCameraPosition,
    _ExampleGoogleMapState googleMapState,
  ) async {
    await GoogleMapsFlutterPlatform.instance.init(id);
    return ExampleGoogleMapController._(
      googleMapState,
      mapId: id,
    );
  }

  final _ExampleGoogleMapState _googleMapState;

  void _connectStreams(int mapId) {
    if (_googleMapState.widget.onCameraMoveStarted != null) {
      GoogleMapsFlutterPlatform.instance
          .onCameraMoveStarted(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraMoveStarted!());
    }
    if (_googleMapState.widget.onCameraMove != null) {
      GoogleMapsFlutterPlatform.instance.onCameraMove(mapId: mapId).listen(
          (CameraMoveEvent e) => _googleMapState.widget.onCameraMove!(e.value));
    }
    if (_googleMapState.widget.onCameraIdle != null) {
      GoogleMapsFlutterPlatform.instance
          .onCameraIdle(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraIdle!());
    }
    GoogleMapsFlutterPlatform.instance
        .onMarkerTap(mapId: mapId)
        .listen((MarkerTapEvent e) => _googleMapState.onMarkerTap(e.value));
    GoogleMapsFlutterPlatform.instance.onMarkerDragStart(mapId: mapId).listen(
        (MarkerDragStartEvent e) =>
            _googleMapState.onMarkerDragStart(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onMarkerDrag(mapId: mapId).listen(
        (MarkerDragEvent e) =>
            _googleMapState.onMarkerDrag(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onMarkerDragEnd(mapId: mapId).listen(
        (MarkerDragEndEvent e) =>
            _googleMapState.onMarkerDragEnd(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onInfoWindowTap(mapId: mapId).listen(
        (InfoWindowTapEvent e) => _googleMapState.onInfoWindowTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onPolylineTap(mapId: mapId)
        .listen((PolylineTapEvent e) => _googleMapState.onPolylineTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onPolygonTap(mapId: mapId)
        .listen((PolygonTapEvent e) => _googleMapState.onPolygonTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onCircleTap(mapId: mapId)
        .listen((CircleTapEvent e) => _googleMapState.onCircleTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onTap(mapId: mapId)
        .listen((MapTapEvent e) => _googleMapState.onTap(e.position));
    GoogleMapsFlutterPlatform.instance.onLongPress(mapId: mapId).listen(
        (MapLongPressEvent e) => _googleMapState.onLongPress(e.position));
  }

  /// Updates configuration options of the map user interface.
  Future<void> _updateMapConfiguration(MapConfiguration update) {
    return GoogleMapsFlutterPlatform.instance
        .updateMapConfiguration(update, mapId: mapId);
  }

  /// Updates marker configuration.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updateMarkers(markerUpdates, mapId: mapId);
  }

  /// Updates polygon configuration.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updatePolygons(polygonUpdates, mapId: mapId);
  }

  /// Updates polyline configuration.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updatePolylines(polylineUpdates, mapId: mapId);
  }

  /// Updates circle configuration.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updateCircles(circleUpdates, mapId: mapId);
  }

  /// Updates tile overlays configuration.
  Future<void> _updateTileOverlays(Set<TileOverlay> newTileOverlays) {
    return GoogleMapsFlutterPlatform.instance
        .updateTileOverlays(newTileOverlays: newTileOverlays, mapId: mapId);
  }

  /// Clears the tile cache so that all tiles will be requested again from the
  /// [TileProvider].
  Future<void> clearTileCache(TileOverlayId tileOverlayId) async {
    return GoogleMapsFlutterPlatform.instance
        .clearTileCache(tileOverlayId, mapId: mapId);
  }

  /// Starts an animated change of the map camera position.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsFlutterPlatform.instance
        .animateCamera(cameraUpdate, mapId: mapId);
  }

  /// Changes the map camera position.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsFlutterPlatform.instance
        .moveCamera(cameraUpdate, mapId: mapId);
  }

  /// Sets the styling of the base map.
  Future<void> setMapStyle(String? mapStyle) {
    return GoogleMapsFlutterPlatform.instance
        .setMapStyle(mapStyle, mapId: mapId);
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    return GoogleMapsFlutterPlatform.instance.getVisibleRegion(mapId: mapId);
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return GoogleMapsFlutterPlatform.instance
        .getScreenCoordinate(latLng, mapId: mapId);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return GoogleMapsFlutterPlatform.instance
        .getLatLng(screenCoordinate, mapId: mapId);
  }

  /// Programmatically show the Info Window for a [Marker].
  Future<void> showMarkerInfoWindow(MarkerId markerId) {
    return GoogleMapsFlutterPlatform.instance
        .showMarkerInfoWindow(markerId, mapId: mapId);
  }

  /// Programmatically hide the Info Window for a [Marker].
  Future<void> hideMarkerInfoWindow(MarkerId markerId) {
    return GoogleMapsFlutterPlatform.instance
        .hideMarkerInfoWindow(markerId, mapId: mapId);
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  Future<bool> isMarkerInfoWindowShown(MarkerId markerId) {
    return GoogleMapsFlutterPlatform.instance
        .isMarkerInfoWindowShown(markerId, mapId: mapId);
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    return GoogleMapsFlutterPlatform.instance.getZoomLevel(mapId: mapId);
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot() {
    return GoogleMapsFlutterPlatform.instance.takeSnapshot(mapId: mapId);
  }

  /// Disposes of the platform resources
  void dispose() {
    GoogleMapsFlutterPlatform.instance.dispose(mapId: mapId);
  }
}

// The next map ID to create.
int _nextMapCreationId = 0;

/// A widget which displays a map with data obtained from the Google Maps service.
class ExampleGoogleMap extends StatefulWidget {
  /// Creates a widget displaying data from Google Maps services.
  ///
  /// [AssertionError] will be thrown if [initialCameraPosition] is null;
  const ExampleGoogleMap({
    Key? key,
    required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.compassEnabled = true,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.layoutDirection,

    /// If no padding is specified default padding will be 0.
    this.padding = const EdgeInsets.all(0),
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.markers = const <Marker>{},
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [ExampleGoogleMapController] for this [ExampleGoogleMap].
  final void Function(ExampleGoogleMapController controller)? onMapCreated;

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

  /// The layout direction to use for the embedded view.
  final TextDirection? layoutDirection;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Padding to be set on map.
  final EdgeInsets padding;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Called when the camera starts moving.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [ExampleGoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [ExampleGoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Which gestures should be consumed by the map.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// Creates a [State] for this [ExampleGoogleMap].
  @override
  State createState() => _ExampleGoogleMapState();
}

class _ExampleGoogleMapState extends State<ExampleGoogleMap> {
  final int _mapId = _nextMapCreationId++;

  final Completer<ExampleGoogleMapController> _controller =
      Completer<ExampleGoogleMapController>();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  late MapConfiguration _mapConfiguration;

  @override
  Widget build(BuildContext context) {
    return GoogleMapsFlutterPlatform.instance.buildViewWithConfiguration(
      _mapId,
      onPlatformViewCreated,
      widgetConfiguration: MapWidgetConfiguration(
        textDirection: widget.layoutDirection ??
            Directionality.maybeOf(context) ??
            TextDirection.ltr,
        initialCameraPosition: widget.initialCameraPosition,
        gestureRecognizers: widget.gestureRecognizers,
      ),
      mapObjects: MapObjects(
        markers: widget.markers,
        polygons: widget.polygons,
        polylines: widget.polylines,
        circles: widget.circles,
      ),
      mapConfiguration: _mapConfiguration,
    );
  }

  @override
  void initState() {
    super.initState();
    _mapConfiguration = _configurationFromMapWidget(widget);
    _markers = keyByMarkerId(widget.markers);
    _polygons = keyByPolygonId(widget.polygons);
    _polylines = keyByPolylineId(widget.polylines);
    _circles = keyByCircleId(widget.circles);
  }

  @override
  void dispose() {
    _controller.future
        .then((ExampleGoogleMapController controller) => controller.dispose());
    super.dispose();
  }

  @override
  void didUpdateWidget(ExampleGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateMarkers();
    _updatePolygons();
    _updatePolylines();
    _updateCircles();
    _updateTileOverlays();
  }

  Future<void> _updateOptions() async {
    final MapConfiguration newConfig = _configurationFromMapWidget(widget);
    final MapConfiguration updates = newConfig.diffFrom(_mapConfiguration);
    if (updates.isEmpty) {
      return;
    }
    final ExampleGoogleMapController controller = await _controller.future;
    controller._updateMapConfiguration(updates);
    _mapConfiguration = newConfig;
  }

  Future<void> _updateMarkers() async {
    final ExampleGoogleMapController controller = await _controller.future;
    controller._updateMarkers(
        MarkerUpdates.from(_markers.values.toSet(), widget.markers));
    _markers = keyByMarkerId(widget.markers);
  }

  Future<void> _updatePolygons() async {
    final ExampleGoogleMapController controller = await _controller.future;
    controller._updatePolygons(
        PolygonUpdates.from(_polygons.values.toSet(), widget.polygons));
    _polygons = keyByPolygonId(widget.polygons);
  }

  Future<void> _updatePolylines() async {
    final ExampleGoogleMapController controller = await _controller.future;
    controller._updatePolylines(
        PolylineUpdates.from(_polylines.values.toSet(), widget.polylines));
    _polylines = keyByPolylineId(widget.polylines);
  }

  Future<void> _updateCircles() async {
    final ExampleGoogleMapController controller = await _controller.future;
    controller._updateCircles(
        CircleUpdates.from(_circles.values.toSet(), widget.circles));
    _circles = keyByCircleId(widget.circles);
  }

  Future<void> _updateTileOverlays() async {
    final ExampleGoogleMapController controller = await _controller.future;
    controller._updateTileOverlays(widget.tileOverlays);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final ExampleGoogleMapController controller =
        await ExampleGoogleMapController._init(
      id,
      widget.initialCameraPosition,
      this,
    );
    _controller.complete(controller);
    _updateTileOverlays();
    widget.onMapCreated?.call(controller);
  }

  void onMarkerTap(MarkerId markerId) {
    _markers[markerId]!.onTap?.call();
  }

  void onMarkerDragStart(MarkerId markerId, LatLng position) {
    _markers[markerId]!.onDragStart?.call(position);
  }

  void onMarkerDrag(MarkerId markerId, LatLng position) {
    _markers[markerId]!.onDrag?.call(position);
  }

  void onMarkerDragEnd(MarkerId markerId, LatLng position) {
    _markers[markerId]!.onDragEnd?.call(position);
  }

  void onPolygonTap(PolygonId polygonId) {
    _polygons[polygonId]!.onTap?.call();
  }

  void onPolylineTap(PolylineId polylineId) {
    _polylines[polylineId]!.onTap?.call();
  }

  void onCircleTap(CircleId circleId) {
    _circles[circleId]!.onTap?.call();
  }

  void onInfoWindowTap(MarkerId markerId) {
    _markers[markerId]!.infoWindow.onTap?.call();
  }

  void onTap(LatLng position) {
    widget.onTap?.call(position);
  }

  void onLongPress(LatLng position) {
    widget.onLongPress?.call(position);
  }
}

/// Builds a [MapConfiguration] from the given [map].
MapConfiguration _configurationFromMapWidget(ExampleGoogleMap map) {
  return MapConfiguration(
    compassEnabled: map.compassEnabled,
    mapToolbarEnabled: map.mapToolbarEnabled,
    cameraTargetBounds: map.cameraTargetBounds,
    mapType: map.mapType,
    minMaxZoomPreference: map.minMaxZoomPreference,
    rotateGesturesEnabled: map.rotateGesturesEnabled,
    scrollGesturesEnabled: map.scrollGesturesEnabled,
    tiltGesturesEnabled: map.tiltGesturesEnabled,
    trackCameraPosition: map.onCameraMove != null,
    zoomControlsEnabled: map.zoomControlsEnabled,
    zoomGesturesEnabled: map.zoomGesturesEnabled,
    liteModeEnabled: map.liteModeEnabled,
    myLocationEnabled: map.myLocationEnabled,
    myLocationButtonEnabled: map.myLocationButtonEnabled,
    padding: map.padding,
    indoorViewEnabled: map.indoorViewEnabled,
    trafficEnabled: map.trafficEnabled,
    buildingsEnabled: map.buildingsEnabled,
  );
}
