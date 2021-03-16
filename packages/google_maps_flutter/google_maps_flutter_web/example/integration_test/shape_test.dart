// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:integration_test/integration_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Completer<bool> _called;
  late Future<bool> called;
  void onTap() {
    _called.complete(true);
  }

  setUp(() {
    _called = Completer();
    called = _called.future;
  });

  group('CircleController', () {
    late gmaps.Circle circle;

    setUp(() {
      circle = gmaps.Circle();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      CircleController(circle: circle, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.Event.trigger(circle, 'click', [gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = CircleController(circle: circle);
      final options = gmaps.CircleOptions()..draggable = true;

      expect(circle.draggable, isNull);

      controller.update(options);

      expect(circle.draggable, isTrue);
    });
  });

  group('PolygonController', () {
    late gmaps.Polygon polygon;

    setUp(() {
      polygon = gmaps.Polygon();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolygonController(polygon: polygon, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.Event.trigger(polygon, 'click', [gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = PolygonController(polygon: polygon);
      final options = gmaps.PolygonOptions()..draggable = true;

      expect(polygon.draggable, isNull);

      controller.update(options);

      expect(polygon.draggable, isTrue);
    });
  });

  group('PolylineController', () {
    late gmaps.Polyline polyline;

    setUp(() {
      polyline = gmaps.Polyline();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolylineController(
          polyline: polyline, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.Event.trigger(polyline, 'click', [gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = PolylineController(polyline: polyline);
      final options = gmaps.PolylineOptions()..draggable = true;

      expect(polyline.draggable, isNull);

      controller.update(options);

      expect(polyline.draggable, isTrue);
    });
  });
}
