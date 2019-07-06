// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FakePlatformGoogleMap {
  FakePlatformGoogleMap(int id, Map<dynamic, dynamic> params) {
    cameraPosition = CameraPosition.fromMap(params['initialCameraPosition']);
    channel = MethodChannel(
        'plugins.flutter.io/google_maps_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
    updateOptions(params['options']);
    updateMarkers(params);
    updatePolygons(params);
    updatePolylines(params);
    updateCircles(params);
  }

  MethodChannel channel;

  CameraPosition cameraPosition;

  bool compassEnabled;

  bool mapToolbarEnabled;

  CameraTargetBounds cameraTargetBounds;

  MapType mapType;

  MinMaxZoomPreference minMaxZoomPreference;

  bool rotateGesturesEnabled;

  bool scrollGesturesEnabled;

  bool tiltGesturesEnabled;

  bool zoomGesturesEnabled;

  bool trackCameraPosition;

  bool myLocationEnabled;

  bool myLocationButtonEnabled;

  List<dynamic> padding;

  Set<MarkerId> markerIdsToRemove;

  Set<Marker> markersToAdd;

  Set<Marker> markersToChange;

  Set<PolygonId> polygonIdsToRemove;

  Set<Polygon> polygonsToAdd;

  Set<Polygon> polygonsToChange;

  Set<PolylineId> polylineIdsToRemove;

  Set<Polyline> polylinesToAdd;

  Set<Polyline> polylinesToChange;

  Set<CircleId> circleIdsToRemove;

  Set<Circle> circlesToAdd;

  Set<Circle> circlesToChange;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'map#update':
        updateOptions(call.arguments['options']);
        return Future<void>.sync(() {});
      case 'markers#update':
        updateMarkers(call.arguments);
        return Future<void>.sync(() {});
      case 'polygons#update':
        updatePolygons(call.arguments);
        return Future<void>.sync(() {});
      case 'polylines#update':
        updatePolylines(call.arguments);
        return Future<void>.sync(() {});
      case 'circles#update':
        updateCircles(call.arguments);
        return Future<void>.sync(() {});
      default:
        return Future<void>.sync(() {});
    }
  }

  void updateMarkers(Map<dynamic, dynamic> markerUpdates) {
    if (markerUpdates == null) {
      return;
    }
    markersToAdd = _deserializeMarkers(markerUpdates['markersToAdd']);
    markerIdsToRemove =
        _deserializeMarkerIds(markerUpdates['markerIdsToRemove']);
    markersToChange = _deserializeMarkers(markerUpdates['markersToChange']);
  }

  Set<MarkerId> _deserializeMarkerIds(List<dynamic> markerIds) {
    if (markerIds == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<MarkerId>();
    }
    return markerIds.map((dynamic markerId) => MarkerId(markerId)).toSet();
  }

  Set<Marker> _deserializeMarkers(dynamic markers) {
    if (markers == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<Marker>();
    }
    final List<dynamic> markersData = markers;
    // TODO(iskakaushik): Remove this when collection literals makes it to stable.
    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    final Set<Marker> result = Set<Marker>();
    for (Map<dynamic, dynamic> markerData in markersData) {
      final String markerId = markerData['markerId'];
      final bool draggable = markerData['draggable'];
      final bool visible = markerData['visible'];

      final dynamic infoWindowData = markerData['infoWindow'];
      InfoWindow infoWindow = InfoWindow.noText;
      if (infoWindowData != null) {
        final Map<dynamic, dynamic> infoWindowMap = infoWindowData;
        infoWindow = InfoWindow(
          title: infoWindowMap['title'],
          snippet: infoWindowMap['snippet'],
        );
      }

      result.add(Marker(
        markerId: MarkerId(markerId),
        draggable: draggable,
        visible: visible,
        infoWindow: infoWindow,
      ));
    }

    return result;
  }

  void updatePolygons(Map<dynamic, dynamic> polygonUpdates) {
    if (polygonUpdates == null) {
      return;
    }
    polygonsToAdd = _deserializePolygons(polygonUpdates['polygonsToAdd']);
    polygonIdsToRemove =
        _deserializePolygonIds(polygonUpdates['polygonIdsToRemove']);
    polygonsToChange = _deserializePolygons(polygonUpdates['polygonsToChange']);
  }

  Set<PolygonId> _deserializePolygonIds(List<dynamic> polygonIds) {
    if (polygonIds == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<PolygonId>();
    }
    return polygonIds.map((dynamic polygonId) => PolygonId(polygonId)).toSet();
  }

  Set<Polygon> _deserializePolygons(dynamic polygons) {
    if (polygons == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<Polygon>();
    }
    final List<dynamic> polygonsData = polygons;
    // TODO(iskakaushik): Remove this when collection literals makes it to stable.
    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    final Set<Polygon> result = Set<Polygon>();
    for (Map<dynamic, dynamic> polygonData in polygonsData) {
      final String polygonId = polygonData['polygonId'];
      final bool visible = polygonData['visible'];
      final bool geodesic = polygonData['geodesic'];

      result.add(Polygon(
        polygonId: PolygonId(polygonId),
        visible: visible,
        geodesic: geodesic,
      ));
    }

    return result;
  }

  void updatePolylines(Map<dynamic, dynamic> polylineUpdates) {
    if (polylineUpdates == null) {
      return;
    }
    polylinesToAdd = _deserializePolylines(polylineUpdates['polylinesToAdd']);
    polylineIdsToRemove =
        _deserializePolylineIds(polylineUpdates['polylineIdsToRemove']);
    polylinesToChange =
        _deserializePolylines(polylineUpdates['polylinesToChange']);
  }

  Set<PolylineId> _deserializePolylineIds(List<dynamic> polylineIds) {
    if (polylineIds == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<PolylineId>();
    }
    return polylineIds
        .map((dynamic polylineId) => PolylineId(polylineId))
        .toSet();
  }

  Set<Polyline> _deserializePolylines(dynamic polylines) {
    if (polylines == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<Polyline>();
    }
    final List<dynamic> polylinesData = polylines;
    // TODO(iskakaushik): Remove this when collection literals makes it to stable.
    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    final Set<Polyline> result = Set<Polyline>();
    for (Map<dynamic, dynamic> polylineData in polylinesData) {
      final String polylineId = polylineData['polylineId'];
      final bool visible = polylineData['visible'];
      final bool geodesic = polylineData['geodesic'];

      result.add(Polyline(
        polylineId: PolylineId(polylineId),
        visible: visible,
        geodesic: geodesic,
      ));
    }

    return result;
  }

  void updateCircles(Map<dynamic, dynamic> circleUpdates) {
    if (circleUpdates == null) {
      return;
    }
    circlesToAdd = _deserializeCircles(circleUpdates['circlesToAdd']);
    circleIdsToRemove =
        _deserializeCircleIds(circleUpdates['circleIdsToRemove']);
    circlesToChange = _deserializeCircles(circleUpdates['circlesToChange']);
  }

  Set<CircleId> _deserializeCircleIds(List<dynamic> circleIds) {
    if (circleIds == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<CircleId>();
    }
    return circleIds.map((dynamic circleId) => CircleId(circleId)).toSet();
  }

  Set<Circle> _deserializeCircles(dynamic circles) {
    if (circles == null) {
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      return Set<Circle>();
    }
    final List<dynamic> circlesData = circles;
    // TODO(iskakaushik): Remove this when collection literals makes it to stable.
    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    final Set<Circle> result = Set<Circle>();
    for (Map<dynamic, dynamic> circleData in circlesData) {
      final String circleId = circleData['circleId'];
      final bool visible = circleData['visible'];
      final double radius = circleData['radius'];

      result.add(Circle(
        circleId: CircleId(circleId),
        visible: visible,
        radius: radius,
      ));
    }

    return result;
  }

  void updateOptions(Map<dynamic, dynamic> options) {
    if (options.containsKey('compassEnabled')) {
      compassEnabled = options['compassEnabled'];
    }
    if (options.containsKey('mapToolbarEnabled')) {
      mapToolbarEnabled = options['mapToolbarEnabled'];
    }
    if (options.containsKey('cameraTargetBounds')) {
      final List<dynamic> boundsList = options['cameraTargetBounds'];
      cameraTargetBounds = boundsList[0] == null
          ? CameraTargetBounds.unbounded
          : CameraTargetBounds(LatLngBounds.fromList(boundsList[0]));
    }
    if (options.containsKey('mapType')) {
      mapType = MapType.values[options['mapType']];
    }
    if (options.containsKey('minMaxZoomPreference')) {
      final List<dynamic> minMaxZoomList = options['minMaxZoomPreference'];
      minMaxZoomPreference =
          MinMaxZoomPreference(minMaxZoomList[0], minMaxZoomList[1]);
    }
    if (options.containsKey('rotateGesturesEnabled')) {
      rotateGesturesEnabled = options['rotateGesturesEnabled'];
    }
    if (options.containsKey('scrollGesturesEnabled')) {
      scrollGesturesEnabled = options['scrollGesturesEnabled'];
    }
    if (options.containsKey('tiltGesturesEnabled')) {
      tiltGesturesEnabled = options['tiltGesturesEnabled'];
    }
    if (options.containsKey('trackCameraPosition')) {
      trackCameraPosition = options['trackCameraPosition'];
    }
    if (options.containsKey('zoomGesturesEnabled')) {
      zoomGesturesEnabled = options['zoomGesturesEnabled'];
    }
    if (options.containsKey('myLocationEnabled')) {
      myLocationEnabled = options['myLocationEnabled'];
    }
    if (options.containsKey('myLocationButtonEnabled')) {
      myLocationButtonEnabled = options['myLocationButtonEnabled'];
    }
    if (options.containsKey('padding')) {
      padding = options['padding'];
    }
  }
}

class FakePlatformViewsController {
  FakePlatformGoogleMap lastCreatedView;

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        final Map<dynamic, dynamic> args = call.arguments;
        final Map<dynamic, dynamic> params = _decodeParams(args['params']);
        lastCreatedView = FakePlatformGoogleMap(
          args['id'],
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

Map<dynamic, dynamic> _decodeParams(Uint8List paramsMessage) {
  final ByteBuffer buffer = paramsMessage.buffer;
  final ByteData messageBytes = buffer.asByteData(
    paramsMessage.offsetInBytes,
    paramsMessage.lengthInBytes,
  );
  return const StandardMessageCodec().decodeMessage(messageBytes);
}
