// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Since onTap events happen asynchronously, we need to store when the event
  // is fired. We use a completer so the test can wait for the future to be completed.
  late Completer<bool> methodCalledCompleter;

  /// This is the future value of the [methodCalledCompleter]. Reinitialized
  /// in the [setUp] method, and completed (as `true`) by [onTap], when it gets
  /// called by the corresponding Shape Controller.
  late Future<bool> methodCalled;

  void onTap() {
    methodCalledCompleter.complete(true);
  }

  setUp(() {
    methodCalledCompleter = Completer<bool>();
    methodCalled = methodCalledCompleter.future;
  });

  group('CircleController', () {
    late gmaps.Circle circle;

    setUp(() {
      circle = gmaps.Circle();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      CircleController(circle: circle, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.Event.trigger(circle, 'click', <Object?>[gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final CircleController controller = CircleController(circle: circle);
      final gmaps.CircleOptions options = gmaps.CircleOptions()
        ..draggable = true;

      expect(circle.draggable, isNull);

      controller.update(options);

      expect(circle.draggable, isTrue);
    });

    group('remove', () {
      late CircleController controller;

      setUp(() {
        controller = CircleController(circle: circle);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.circle, isNull);
      });

      testWidgets('cannot call update after remove',
          (WidgetTester tester) async {
        final gmaps.CircleOptions options = gmaps.CircleOptions()
          ..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });
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
      gmaps.Event.trigger(polygon, 'click', <Object?>[gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final PolygonController controller = PolygonController(polygon: polygon);
      final gmaps.PolygonOptions options = gmaps.PolygonOptions()
        ..draggable = true;

      expect(polygon.draggable, isNull);

      controller.update(options);

      expect(polygon.draggable, isTrue);
    });

    group('remove', () {
      late PolygonController controller;

      setUp(() {
        controller = PolygonController(polygon: polygon);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.polygon, isNull);
      });

      testWidgets('cannot call update after remove',
          (WidgetTester tester) async {
        final gmaps.PolygonOptions options = gmaps.PolygonOptions()
          ..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });
    });
  });

  group('PolylineController', () {
    late gmaps.Polyline polyline;

    setUp(() {
      polyline = gmaps.Polyline();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolylineController(
        polyline: polyline,
        consumeTapEvents: true,
        onTap: onTap,
      );

      // Trigger a click event...
      gmaps.Event.trigger(polyline, 'click', <Object?>[gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final PolylineController controller = PolylineController(
        polyline: polyline,
      );
      final gmaps.PolylineOptions options = gmaps.PolylineOptions()
        ..draggable = true;

      expect(polyline.draggable, isNull);

      controller.update(options);

      expect(polyline.draggable, isTrue);
    });

    group('remove', () {
      late PolylineController controller;

      setUp(() {
        controller = PolylineController(polyline: polyline);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.line, isNull);
      });

      testWidgets('cannot call update after remove',
          (WidgetTester tester) async {
        final gmaps.PolylineOptions options = gmaps.PolylineOptions()
          ..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });
    });
  });
}
