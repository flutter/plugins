// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized() as E2EWidgetsFlutterBinding;

  group('CirclesController', () {
    StreamController<MapEvent> stream;
    CirclesController controller;

    setUp(() {
      stream = StreamController<MapEvent>();
      controller = CirclesController(stream: stream);
    });

    testWidgets('addCircles', (WidgetTester tester) async {
      final circles = {
        Circle(circleId: CircleId('1')),
        Circle(circleId: CircleId('2')),
      };

      controller.addCircles(circles);

      expect(controller.circles.length, 2);
      expect(controller.circles, contains(CircleId('1')));
      expect(controller.circles, contains(CircleId('2')));
      expect(controller.circles, isNot(contains(CircleId('66'))));
    });

    testWidgets('changeCircles', (WidgetTester tester) async {
      final circles = {
        Circle(circleId: CircleId('1')),
      };
      controller.addCircles(circles);

      expect(controller.circles[CircleId('1')].circle.visible, isTrue);

      final updatedCircles = {
        Circle(circleId: CircleId('1'), visible: false),
      };
      controller.changeCircles(updatedCircles);

      expect(controller.circles.length, 1);
      expect(controller.circles[CircleId('1')].circle.visible, isFalse);
    });

    testWidgets('removeCircles', (WidgetTester tester) async {
      final circles = {
        Circle(circleId: CircleId('1')),
        Circle(circleId: CircleId('2')),
        Circle(circleId: CircleId('3')),
      };

      controller.addCircles(circles);

      expect(controller.circles.length, 3);

      // Remove some circles...
      final circleIdsToRemove = {
        CircleId('1'),
        CircleId('3'),
      };

      controller.removeCircles(circleIdsToRemove);

      expect(controller.circles.length, 1);
      expect(controller.circles, isNot(contains(CircleId('1'))));
      expect(controller.circles, contains(CircleId('2')));
      expect(controller.circles, isNot(contains(CircleId('3'))));
    });
  });

  group('PolygonsController', () {
    StreamController<MapEvent> stream;
    PolygonsController controller;

    setUp(() {
      stream = StreamController<MapEvent>();
      controller = PolygonsController(stream: stream);
    });

    testWidgets('addPolygons', (WidgetTester tester) async {
      final polygons = {
        Polygon(polygonId: PolygonId('1')),
        Polygon(polygonId: PolygonId('2')),
      };

      controller.addPolygons(polygons);

      expect(controller.polygons.length, 2);
      expect(controller.polygons, contains(PolygonId('1')));
      expect(controller.polygons, contains(PolygonId('2')));
      expect(controller.polygons, isNot(contains(PolygonId('66'))));
    });

    testWidgets('changePolygons', (WidgetTester tester) async {
      final polygons = {
        Polygon(polygonId: PolygonId('1')),
      };
      controller.addPolygons(polygons);

      expect(controller.polygons[PolygonId('1')].polygon.visible, isTrue);

      // Update the polygon
      final updatedPolygons = {
        Polygon(polygonId: PolygonId('1'), visible: false),
      };
      controller.changePolygons(updatedPolygons);

      expect(controller.polygons.length, 1);
      expect(controller.polygons[PolygonId('1')].polygon.visible, isFalse);
    });

    testWidgets('removePolygons', (WidgetTester tester) async {
      final polygons = {
        Polygon(polygonId: PolygonId('1')),
        Polygon(polygonId: PolygonId('2')),
        Polygon(polygonId: PolygonId('3')),
      };

      controller.addPolygons(polygons);

      expect(controller.polygons.length, 3);

      // Remove some polygons...
      final polygonIdsToRemove = {
        PolygonId('1'),
        PolygonId('3'),
      };

      controller.removePolygons(polygonIdsToRemove);

      expect(controller.polygons.length, 1);
      expect(controller.polygons, isNot(contains(PolygonId('1'))));
      expect(controller.polygons, contains(PolygonId('2')));
      expect(controller.polygons, isNot(contains(PolygonId('3'))));
    });
  });

  group('PolylinesController', () {
    StreamController<MapEvent> stream;
    PolylinesController controller;

    setUp(() {
      stream = StreamController<MapEvent>();
      controller = PolylinesController(stream: stream);
    });

    testWidgets('addPolylines', (WidgetTester tester) async {
      final polylines = {
        Polyline(polylineId: PolylineId('1')),
        Polyline(polylineId: PolylineId('2')),
      };

      controller.addPolylines(polylines);

      expect(controller.lines.length, 2);
      expect(controller.lines, contains(PolylineId('1')));
      expect(controller.lines, contains(PolylineId('2')));
      expect(controller.lines, isNot(contains(PolylineId('66'))));
    });

    testWidgets('changePolylines', (WidgetTester tester) async {
      final polylines = {
        Polyline(polylineId: PolylineId('1')),
      };
      controller.addPolylines(polylines);

      expect(controller.lines[PolylineId('1')].line.visible, isTrue);

      final updatedPolylines = {
        Polyline(polylineId: PolylineId('1'), visible: false),
      };
      controller.changePolylines(updatedPolylines);

      expect(controller.lines.length, 1);
      expect(controller.lines[PolylineId('1')].line.visible, isFalse);
    });

    testWidgets('removePolylines', (WidgetTester tester) async {
      final polylines = {
        Polyline(polylineId: PolylineId('1')),
        Polyline(polylineId: PolylineId('2')),
        Polyline(polylineId: PolylineId('3')),
      };

      controller.addPolylines(polylines);

      expect(controller.lines.length, 3);

      // Remove some polylines...
      final polylineIdsToRemove = {
        PolylineId('1'),
        PolylineId('3'),
      };

      controller.removePolylines(polylineIdsToRemove);

      expect(controller.lines.length, 1);
      expect(controller.lines, isNot(contains(PolylineId('1'))));
      expect(controller.lines, contains(PolylineId('2')));
      expect(controller.lines, isNot(contains(PolylineId('3'))));
    });
  });
}
