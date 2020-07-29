@TestOn('chrome') // Uses web-only Flutter SDKs...

import 'dart:async';

import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
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
void shapeTests() {
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

    test('onTap gets called', () async {
      CircleController(circle: circle, consumeTapEvents: true, onTap: onTap);
      expect(circle.onClickController.hasListener, isTrue);
      // Simulate a click
      await circle.onClickController.add(null);
      expect(called, isTrue);
    });

    test('update', () {
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

    test('onTap gets called', () async {
      PolygonController(polygon: polygon, consumeTapEvents: true, onTap: onTap);
      expect(polygon.onClickController.hasListener, isTrue);
      // Simulate a click
      await polygon.onClickController.add(null);
      expect(called, isTrue);
    });

    test('update', () {
      final controller = PolygonController(polygon: polygon);
      final options = gmaps.PolygonOptions()..draggable = false;
      controller.update(options);
      verify(polygon.options = options);
    });
  });

  group('PolylineController', () {
    _MockPolyline polyline;

    setUp(() {
      polyline = _MockPolyline();
    });

    test('onTap gets called', () async {
      PolylineController(
          polyline: polyline, consumeTapEvents: true, onTap: onTap);
      expect(polyline.onClickController.hasListener, isTrue);
      // Simulate a click
      await polyline.onClickController.add(null);
      expect(called, isTrue);
    });

    test('update', () {
      final controller = PolylineController(polyline: polyline);
      final options = gmaps.PolylineOptions()..draggable = false;
      controller.update(options);
      verify(polyline.options = options);
    });
  });
}
