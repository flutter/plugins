// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:async';

import 'package:integration_test/integration_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps/google_maps_geometry.dart' as geometry;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as platform;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _MockCircle extends Mock implements gmaps.Circle {
  final onClickController = StreamController<gmaps.MouseEvent>();
  @override
  Stream<gmaps.MouseEvent> get onClick => onClickController.stream;
}

class _MockPolygon extends Mock implements gmaps.Polygon {
  final onClickController = StreamController<gmaps.PolyMouseEvent>();
  @override
  Stream<gmaps.PolyMouseEvent> get onClick => onClickController.stream;
}

class _MockPolyline extends Mock implements gmaps.Polyline {
  final onClickController = StreamController<gmaps.PolyMouseEvent>();
  @override
  Stream<gmaps.PolyMouseEvent> get onClick => onClickController.stream;
}

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  bool called = false;
  void onTap() {
    called = true;
  }

  setUp(() {
    called = false;
  });

  group('CircleController', () {
    _MockCircle circle;

    setUp(() {
      circle = _MockCircle();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      CircleController(circle: circle, consumeTapEvents: true, onTap: onTap);
      expect(circle.onClickController.hasListener, isTrue);
      // Simulate a click
      await circle.onClickController.add(null);
      expect(called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = CircleController(circle: circle);
      final options = gmaps.CircleOptions()..draggable = false;
      controller.update(options);
      verify(circle.options = options);
    });
  });

  group('PolygonController', () {
    _MockPolygon polygon;

    setUp(() {
      polygon = _MockPolygon();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolygonController(polygon: polygon, consumeTapEvents: true, onTap: onTap);
      expect(polygon.onClickController.hasListener, isTrue);
      // Simulate a click
      await polygon.onClickController.add(null);
      expect(called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = PolygonController(polygon: polygon);
      final options = gmaps.PolygonOptions()..draggable = false;
      controller.update(options);
      verify(polygon.options = options);
    });

    test('Polygon with hole has a hole', () {
      final holedPolygon = platform.Polygon(
        polygonId: platform.PolygonId('BermudaTriangle'),
        points: [
          platform.LatLng(25.774, -80.19),
          platform.LatLng(18.466, -66.118),
          platform.LatLng(32.321, -64.757),
        ],
        holes: [
          [
            platform.LatLng(28.745, -70.579),
            platform.LatLng(29.57, -67.514),
            platform.LatLng(27.339, -66.668),
          ],
        ],
      );
      final controller = PolygonsController(stream: null)
        ..addPolygons({holedPolygon});
      final gmapsPolygon = controller.polygons.values.first.polygon;
      final pointInHole = gmaps.LatLng(28.632, -68.401);
      expect(geometry.poly.containsLocation(pointInHole, gmapsPolygon), false);
    });
  });

  group('PolylineController', () {
    _MockPolyline polyline;

    setUp(() {
      polyline = _MockPolyline();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolylineController(
          polyline: polyline, consumeTapEvents: true, onTap: onTap);
      expect(polyline.onClickController.hasListener, isTrue);
      // Simulate a click
      await polyline.onClickController.add(null);
      expect(called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = PolylineController(polyline: polyline);
      final options = gmaps.PolylineOptions()..draggable = false;
      controller.update(options);
      verify(polyline.options = options);
    });
  });
}
