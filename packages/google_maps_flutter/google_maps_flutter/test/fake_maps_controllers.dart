// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FakePlatformGoogleMap {
  FakePlatformGoogleMap(int id, Map<dynamic, dynamic> params)
      : cameraPosition =
            CameraPosition.fromMap(params['initialCameraPosition']),
        channel = MethodChannel('plugins.flutter.io/google_maps_$id') {
    channel.setMockMethodCallHandler(onMethodCall);
    updateOptions(params['options'] as Map<dynamic, dynamic>);
    updateMarkers(params);
    updatePolygons(params);
    updatePolylines(params);
    updateCircles(params);
    updateTileOverlays(Map.castFrom<dynamic, dynamic, String, dynamic>(params));
  }

  MethodChannel channel;

  CameraPosition? cameraPosition;

  bool? compassEnabled;

  bool? mapToolbarEnabled;

  CameraTargetBounds? cameraTargetBounds;

  MapType? mapType;

  MinMaxZoomPreference? minMaxZoomPreference;

  bool? rotateGesturesEnabled;

  bool? scrollGesturesEnabled;

  bool? tiltGesturesEnabled;

  bool? zoomGesturesEnabled;

  bool? zoomControlsEnabled;

  bool? liteModeEnabled;

  bool? trackCameraPosition;

  bool? myLocationEnabled;

  bool? trafficEnabled;

  bool? buildingsEnabled;

  bool? myLocationButtonEnabled;

  List<dynamic>? padding;

  Set<MarkerId> markerIdsToRemove = <MarkerId>{};

  Set<Marker> markersToAdd = <Marker>{};

  Set<Marker> markersToChange = <Marker>{};

  Set<PolygonId> polygonIdsToRemove = <PolygonId>{};

  Set<Polygon> polygonsToAdd = <Polygon>{};

  Set<Polygon> polygonsToChange = <Polygon>{};

  Set<PolylineId> polylineIdsToRemove = <PolylineId>{};

  Set<Polyline> polylinesToAdd = <Polyline>{};

  Set<Polyline> polylinesToChange = <Polyline>{};

  Set<CircleId> circleIdsToRemove = <CircleId>{};

  Set<Circle> circlesToAdd = <Circle>{};

  Set<Circle> circlesToChange = <Circle>{};

  Set<TileOverlayId> tileOverlayIdsToRemove = <TileOverlayId>{};

  Set<TileOverlay> tileOverlaysToAdd = <TileOverlay>{};

  Set<TileOverlay> tileOverlaysToChange = <TileOverlay>{};

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'map#update':
        final Map<String, Object?> arguments =
            (call.arguments as Map<Object?, Object?>).cast<String, Object?>();
        updateOptions(arguments['options']! as Map<dynamic, dynamic>);
        return Future<void>.sync(() {});
      case 'markers#update':
        updateMarkers(call.arguments as Map<dynamic, dynamic>?);
        return Future<void>.sync(() {});
      case 'polygons#update':
        updatePolygons(call.arguments as Map<dynamic, dynamic>?);
        return Future<void>.sync(() {});
      case 'polylines#update':
        updatePolylines(call.arguments as Map<dynamic, dynamic>?);
        return Future<void>.sync(() {});
      case 'tileOverlays#update':
        updateTileOverlays(Map.castFrom<dynamic, dynamic, String, dynamic>(
            call.arguments as Map<dynamic, dynamic>));
        return Future<void>.sync(() {});
      case 'circles#update':
        updateCircles(call.arguments as Map<dynamic, dynamic>?);
        return Future<void>.sync(() {});
      default:
        return Future<void>.sync(() {});
    }
  }

  void updateMarkers(Map<dynamic, dynamic>? markerUpdates) {
    if (markerUpdates == null) {
      return;
    }
    markersToAdd = _deserializeMarkers(markerUpdates['markersToAdd']);
    markerIdsToRemove = _deserializeMarkerIds(
        markerUpdates['markerIdsToRemove'] as List<dynamic>?);
    markersToChange = _deserializeMarkers(markerUpdates['markersToChange']);
  }

  Set<MarkerId> _deserializeMarkerIds(List<dynamic>? markerIds) {
    if (markerIds == null) {
      return <MarkerId>{};
    }
    return markerIds
        .map((dynamic markerId) => MarkerId(markerId as String))
        .toSet();
  }

  Set<Marker> _deserializeMarkers(dynamic markers) {
    if (markers == null) {
      return <Marker>{};
    }
    final List<dynamic> markersData = markers as List<dynamic>;
    final Set<Marker> result = <Marker>{};
    for (final Map<dynamic, dynamic> markerData
        in markersData.cast<Map<dynamic, dynamic>>()) {
      final String markerId = markerData['markerId'] as String;
      final double alpha = markerData['alpha'] as double;
      final bool draggable = markerData['draggable'] as bool;
      final bool visible = markerData['visible'] as bool;

      final dynamic infoWindowData = markerData['infoWindow'];
      InfoWindow infoWindow = InfoWindow.noText;
      if (infoWindowData != null) {
        final Map<dynamic, dynamic> infoWindowMap =
            infoWindowData as Map<dynamic, dynamic>;
        infoWindow = InfoWindow(
          title: infoWindowMap['title'] as String?,
          snippet: infoWindowMap['snippet'] as String?,
        );
      }

      result.add(Marker(
        markerId: MarkerId(markerId),
        draggable: draggable,
        visible: visible,
        infoWindow: infoWindow,
        alpha: alpha,
      ));
    }

    return result;
  }

  void updatePolygons(Map<dynamic, dynamic>? polygonUpdates) {
    if (polygonUpdates == null) {
      return;
    }
    polygonsToAdd = _deserializePolygons(polygonUpdates['polygonsToAdd']);
    polygonIdsToRemove = _deserializePolygonIds(
        polygonUpdates['polygonIdsToRemove'] as List<dynamic>?);
    polygonsToChange = _deserializePolygons(polygonUpdates['polygonsToChange']);
  }

  Set<PolygonId> _deserializePolygonIds(List<dynamic>? polygonIds) {
    if (polygonIds == null) {
      return <PolygonId>{};
    }
    return polygonIds
        .map((dynamic polygonId) => PolygonId(polygonId as String))
        .toSet();
  }

  Set<Polygon> _deserializePolygons(dynamic polygons) {
    if (polygons == null) {
      return <Polygon>{};
    }
    final List<dynamic> polygonsData = polygons as List<dynamic>;
    final Set<Polygon> result = <Polygon>{};
    for (final Map<dynamic, dynamic> polygonData
        in polygonsData.cast<Map<dynamic, dynamic>>()) {
      final String polygonId = polygonData['polygonId'] as String;
      final bool visible = polygonData['visible'] as bool;
      final bool geodesic = polygonData['geodesic'] as bool;
      final List<LatLng> points =
          _deserializePoints(polygonData['points'] as List<dynamic>);
      final List<List<LatLng>> holes =
          _deserializeHoles(polygonData['holes'] as List<dynamic>);

      result.add(Polygon(
        polygonId: PolygonId(polygonId),
        visible: visible,
        geodesic: geodesic,
        points: points,
        holes: holes,
      ));
    }

    return result;
  }

  // Converts a list of points expressed as two-element lists of doubles into
  // a list of `LatLng`s. All list items are assumed to be non-null.
  List<LatLng> _deserializePoints(List<dynamic> points) {
    return points.map<LatLng>((dynamic item) {
      final List<Object?> list = item as List<Object?>;
      return LatLng(list[0]! as double, list[1]! as double);
    }).toList();
  }

  List<List<LatLng>> _deserializeHoles(List<dynamic> holes) {
    return holes.map<List<LatLng>>((dynamic hole) {
      return _deserializePoints(hole as List<dynamic>);
    }).toList();
  }

  void updatePolylines(Map<dynamic, dynamic>? polylineUpdates) {
    if (polylineUpdates == null) {
      return;
    }
    polylinesToAdd = _deserializePolylines(polylineUpdates['polylinesToAdd']);
    polylineIdsToRemove = _deserializePolylineIds(
        polylineUpdates['polylineIdsToRemove'] as List<dynamic>?);
    polylinesToChange =
        _deserializePolylines(polylineUpdates['polylinesToChange']);
  }

  Set<PolylineId> _deserializePolylineIds(List<dynamic>? polylineIds) {
    if (polylineIds == null) {
      return <PolylineId>{};
    }
    return polylineIds
        .map((dynamic polylineId) => PolylineId(polylineId as String))
        .toSet();
  }

  Set<Polyline> _deserializePolylines(dynamic polylines) {
    if (polylines == null) {
      return <Polyline>{};
    }
    final List<dynamic> polylinesData = polylines as List<dynamic>;
    final Set<Polyline> result = <Polyline>{};
    for (final Map<dynamic, dynamic> polylineData
        in polylinesData.cast<Map<dynamic, dynamic>>()) {
      final String polylineId = polylineData['polylineId'] as String;
      final bool visible = polylineData['visible'] as bool;
      final bool geodesic = polylineData['geodesic'] as bool;
      final List<LatLng> points =
          _deserializePoints(polylineData['points'] as List<dynamic>);

      result.add(Polyline(
        polylineId: PolylineId(polylineId),
        visible: visible,
        geodesic: geodesic,
        points: points,
      ));
    }

    return result;
  }

  void updateCircles(Map<dynamic, dynamic>? circleUpdates) {
    if (circleUpdates == null) {
      return;
    }
    circlesToAdd = _deserializeCircles(circleUpdates['circlesToAdd']);
    circleIdsToRemove = _deserializeCircleIds(
        circleUpdates['circleIdsToRemove'] as List<dynamic>?);
    circlesToChange = _deserializeCircles(circleUpdates['circlesToChange']);
  }

  void updateTileOverlays(Map<String, dynamic> updateTileOverlayUpdates) {
    if (updateTileOverlayUpdates == null) {
      return;
    }
    final List<Map<dynamic, dynamic>>? tileOverlaysToAddList =
        updateTileOverlayUpdates['tileOverlaysToAdd'] != null
            ? List.castFrom<dynamic, Map<dynamic, dynamic>>(
                updateTileOverlayUpdates['tileOverlaysToAdd'] as List<dynamic>)
            : null;
    final List<String>? tileOverlayIdsToRemoveList =
        updateTileOverlayUpdates['tileOverlayIdsToRemove'] != null
            ? List.castFrom<dynamic, String>(
                updateTileOverlayUpdates['tileOverlayIdsToRemove']
                    as List<dynamic>)
            : null;
    final List<Map<dynamic, dynamic>>? tileOverlaysToChangeList =
        updateTileOverlayUpdates['tileOverlaysToChange'] != null
            ? List.castFrom<dynamic, Map<dynamic, dynamic>>(
                updateTileOverlayUpdates['tileOverlaysToChange']
                    as List<dynamic>)
            : null;
    tileOverlaysToAdd = _deserializeTileOverlays(tileOverlaysToAddList);
    tileOverlayIdsToRemove =
        _deserializeTileOverlayIds(tileOverlayIdsToRemoveList);
    tileOverlaysToChange = _deserializeTileOverlays(tileOverlaysToChangeList);
  }

  Set<CircleId> _deserializeCircleIds(List<dynamic>? circleIds) {
    if (circleIds == null) {
      return <CircleId>{};
    }
    return circleIds
        .map((dynamic circleId) => CircleId(circleId as String))
        .toSet();
  }

  Set<Circle> _deserializeCircles(dynamic circles) {
    if (circles == null) {
      return <Circle>{};
    }
    final List<dynamic> circlesData = circles as List<dynamic>;
    final Set<Circle> result = <Circle>{};
    for (final Map<dynamic, dynamic> circleData
        in circlesData.cast<Map<dynamic, dynamic>>()) {
      final String circleId = circleData['circleId'] as String;
      final bool visible = circleData['visible'] as bool;
      final double radius = circleData['radius'] as double;

      result.add(Circle(
        circleId: CircleId(circleId),
        visible: visible,
        radius: radius,
      ));
    }

    return result;
  }

  Set<TileOverlayId> _deserializeTileOverlayIds(List<String>? tileOverlayIds) {
    if (tileOverlayIds == null || tileOverlayIds.isEmpty) {
      return <TileOverlayId>{};
    }
    return tileOverlayIds
        .map((String tileOverlayId) => TileOverlayId(tileOverlayId))
        .toSet();
  }

  Set<TileOverlay> _deserializeTileOverlays(
      List<Map<dynamic, dynamic>>? tileOverlays) {
    if (tileOverlays == null || tileOverlays.isEmpty) {
      return <TileOverlay>{};
    }
    final Set<TileOverlay> result = <TileOverlay>{};
    for (final Map<dynamic, dynamic> tileOverlayData in tileOverlays) {
      final String tileOverlayId = tileOverlayData['tileOverlayId'] as String;
      final bool fadeIn = tileOverlayData['fadeIn'] as bool;
      final double transparency = tileOverlayData['transparency'] as double;
      final int zIndex = tileOverlayData['zIndex'] as int;
      final bool visible = tileOverlayData['visible'] as bool;

      result.add(TileOverlay(
        tileOverlayId: TileOverlayId(tileOverlayId),
        fadeIn: fadeIn,
        transparency: transparency,
        zIndex: zIndex,
        visible: visible,
      ));
    }

    return result;
  }

  void updateOptions(Map<dynamic, dynamic> options) {
    if (options.containsKey('compassEnabled')) {
      compassEnabled = options['compassEnabled'] as bool?;
    }
    if (options.containsKey('mapToolbarEnabled')) {
      mapToolbarEnabled = options['mapToolbarEnabled'] as bool?;
    }
    if (options.containsKey('cameraTargetBounds')) {
      final List<dynamic> boundsList =
          options['cameraTargetBounds'] as List<dynamic>;
      cameraTargetBounds = boundsList[0] == null
          ? CameraTargetBounds.unbounded
          : CameraTargetBounds(LatLngBounds.fromList(boundsList[0]));
    }
    if (options.containsKey('mapType')) {
      mapType = MapType.values[options['mapType'] as int];
    }
    if (options.containsKey('minMaxZoomPreference')) {
      final List<dynamic> minMaxZoomList =
          options['minMaxZoomPreference'] as List<dynamic>;
      minMaxZoomPreference = MinMaxZoomPreference(
          minMaxZoomList[0] as double?, minMaxZoomList[1] as double?);
    }
    if (options.containsKey('rotateGesturesEnabled')) {
      rotateGesturesEnabled = options['rotateGesturesEnabled'] as bool?;
    }
    if (options.containsKey('scrollGesturesEnabled')) {
      scrollGesturesEnabled = options['scrollGesturesEnabled'] as bool?;
    }
    if (options.containsKey('tiltGesturesEnabled')) {
      tiltGesturesEnabled = options['tiltGesturesEnabled'] as bool?;
    }
    if (options.containsKey('trackCameraPosition')) {
      trackCameraPosition = options['trackCameraPosition'] as bool?;
    }
    if (options.containsKey('zoomGesturesEnabled')) {
      zoomGesturesEnabled = options['zoomGesturesEnabled'] as bool?;
    }
    if (options.containsKey('zoomControlsEnabled')) {
      zoomControlsEnabled = options['zoomControlsEnabled'] as bool?;
    }
    if (options.containsKey('liteModeEnabled')) {
      liteModeEnabled = options['liteModeEnabled'] as bool?;
    }
    if (options.containsKey('myLocationEnabled')) {
      myLocationEnabled = options['myLocationEnabled'] as bool?;
    }
    if (options.containsKey('myLocationButtonEnabled')) {
      myLocationButtonEnabled = options['myLocationButtonEnabled'] as bool?;
    }
    if (options.containsKey('trafficEnabled')) {
      trafficEnabled = options['trafficEnabled'] as bool?;
    }
    if (options.containsKey('buildingsEnabled')) {
      buildingsEnabled = options['buildingsEnabled'] as bool?;
    }
    if (options.containsKey('padding')) {
      padding = options['padding'] as List<dynamic>?;
    }
  }
}

class FakePlatformViewsController {
  FakePlatformGoogleMap? lastCreatedView;

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        final Map<dynamic, dynamic> args =
            call.arguments as Map<dynamic, dynamic>;
        final Map<dynamic, dynamic> params =
            _decodeParams(args['params'] as Uint8List)!;
        lastCreatedView = FakePlatformGoogleMap(
          args['id'] as int,
          params,
        );
        return Future<int>.sync(() => 1);
      default:
        return Future<void>.sync(() {});
    }
  }

  void reset() {
    lastCreatedView = null;
  }
}

Map<dynamic, dynamic>? _decodeParams(Uint8List paramsMessage) {
  final ByteBuffer buffer = paramsMessage.buffer;
  final ByteData messageBytes = buffer.asByteData(
    paramsMessage.offsetInBytes,
    paramsMessage.lengthInBytes,
  );
  return const StandardMessageCodec().decodeMessage(messageBytes)
      as Map<dynamic, dynamic>?;
}
