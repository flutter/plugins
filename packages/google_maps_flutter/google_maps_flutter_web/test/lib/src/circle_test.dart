// @TestOn('chrome') // Uses web-only Flutter SDKs...

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

/// Test Circle
void circleTests() {
  group('Circle', () {
    _MockCircle circle;
    bool called = false;
    void onTap() {
      called = true;
    }

    setUp(() {
      called = false;
      circle = _MockCircle();
    });

    test('_consumeTapEvents true', () async {
      CircleController(circle: circle, consumeTapEvents: true, onTap: onTap);
      expect(circle.onClickController.hasListener, isTrue);
      // Simulate a click
      await circle.onClickController.add(null);
      expect(called, isTrue);
    });

    test('_consumeTapEvents false', () async {
      CircleController(circle: circle, consumeTapEvents: false, onTap: onTap);
      expect(circle.onClickController.hasListener, isFalse);
      // Simulate a click
      await circle.onClickController.add(null);
      expect(called, isFalse);
    });

    test('update', () {
      final controller = CircleController(circle: circle);
      final options = gmaps.CircleOptions()..draggable = false;
      controller.update(options);
      verify(circle.options = options);
    });
  });
}
