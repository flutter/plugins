import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

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

      expect(controller.circles[CircleId('1')].circle.radius, 0);

      // Update the circle with radius 10
      final updatedCircles = {
        Circle(circleId: CircleId('1'), radius: 10),
      };
      controller.changeCircles(updatedCircles);

      expect(controller.circles.length, 1);
      expect(controller.circles[CircleId('1')].circle.radius, 10);
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

    testWidgets('update', (WidgetTester tester) async {});
  });
}
