// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:async';
import 'dart:ui';

import 'package:integration_test/integration_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps/google_maps_geometry.dart' as geometry;
import 'package:flutter_test/flutter_test.dart';

// This value is used when comparing the results of
// converting from a byte value to a double between 0 and 1.
// (For Color opacity values, for example)
const _acceptableDelta = 0.01;

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final circles = {
        Circle(
          circleId: CircleId('1'),
          fillColor: Color(0x7FFABADA),
          strokeColor: Color(0xFFC0FFEE),
        ),
      };

      controller.addCircles(circles);

      final circle = controller.circles.values.first.circle;

      expect(circle.get('fillColor'), '#fabada');
      expect(circle.get('fillOpacity'), closeTo(0.5, _acceptableDelta));
      expect(circle.get('strokeColor'), '#c0ffee');
      expect(circle.get('strokeOpacity'), closeTo(1, _acceptableDelta));
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

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final polygons = {
        Polygon(
          polygonId: PolygonId('1'),
          fillColor: Color(0x7FFABADA),
          strokeColor: Color(0xFFC0FFEE),
        ),
      };

      controller.addPolygons(polygons);

      final polygon = controller.polygons.values.first.polygon;

      expect(polygon.get('fillColor'), '#fabada');
      expect(polygon.get('fillOpacity'), closeTo(0.5, _acceptableDelta));
      expect(polygon.get('strokeColor'), '#c0ffee');
      expect(polygon.get('strokeOpacity'), closeTo(1, _acceptableDelta));
    });

    testWidgets('Handle Polygons with holes', (WidgetTester tester) async {
      final polygons = {
        Polygon(
          polygonId: PolygonId('BermudaTriangle'),
          points: [
            LatLng(25.774, -80.19),
            LatLng(18.466, -66.118),
            LatLng(32.321, -64.757),
          ],
          holes: [
            [
              LatLng(28.745, -70.579),
              LatLng(29.57, -67.514),
              LatLng(27.339, -66.668),
            ],
          ],
        ),
      };

      controller.addPolygons(polygons);

      expect(controller.polygons.length, 1);
      expect(controller.polygons, contains(PolygonId('BermudaTriangle')));
      expect(controller.polygons, isNot(contains(PolygonId('66'))));
    });

    testWidgets('Polygon with hole has a hole', (WidgetTester tester) async {
      final polygons = {
        Polygon(
          polygonId: PolygonId('BermudaTriangle'),
          points: [
            LatLng(25.774, -80.19),
            LatLng(18.466, -66.118),
            LatLng(32.321, -64.757),
          ],
          holes: [
            [
              LatLng(28.745, -70.579),
              LatLng(29.57, -67.514),
              LatLng(27.339, -66.668),
            ],
          ],
        ),
      };

      controller.addPolygons(polygons);

      final polygon = controller.polygons.values.first.polygon;
      final pointInHole = gmaps.LatLng(28.632, -68.401);

      expect(geometry.poly.containsLocation(pointInHole, polygon), false);
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

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final lines = {
        Polyline(
          polylineId: PolylineId('1'),
          color: Color(0x7FFABADA),
        ),
      };

      controller.addPolylines(lines);

      final line = controller.lines.values.first.line;

      expect(line.get('strokeColor'), '#fabada');
      expect(line.get('strokeOpacity'), closeTo(0.5, _acceptableDelta));
    });
  });
}
