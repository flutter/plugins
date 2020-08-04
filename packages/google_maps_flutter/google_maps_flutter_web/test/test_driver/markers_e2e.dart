import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized() as E2EWidgetsFlutterBinding;

  group('MarkersController', () {
    StreamController<MapEvent> stream;
    MarkersController controller;

    setUp(() {
      stream = StreamController<MapEvent>();
      controller = MarkersController(stream: stream);
    });

    testWidgets('addMarkers', (WidgetTester tester) async {
      final markers = {
        Marker(markerId: MarkerId('1')),
        Marker(markerId: MarkerId('2')),
      };

      controller.addMarkers(markers);

      expect(controller.markers.length, 2);
      expect(controller.markers, contains(MarkerId('1')));
      expect(controller.markers, contains(MarkerId('2')));
      expect(controller.markers, isNot(contains(MarkerId('66'))));
    });

    testWidgets('changeMarkers', (WidgetTester tester) async {
      final markers = {
        Marker(markerId: MarkerId('1')),
      };
      controller.addMarkers(markers);

      expect(controller.markers[MarkerId('1')].marker.draggable, isFalse);

      // Update the marker with radius 10
      final updatedMarkers = {
        Marker(markerId: MarkerId('1'), draggable: true),
      };
      controller.changeMarkers(updatedMarkers);

      expect(controller.markers.length, 1);
      expect(controller.markers[MarkerId('1')].marker.draggable, isTrue);
    });

    testWidgets('removeMarkers', (WidgetTester tester) async {
      final markers = {
        Marker(markerId: MarkerId('1')),
        Marker(markerId: MarkerId('2')),
        Marker(markerId: MarkerId('3')),
      };

      controller.addMarkers(markers);

      expect(controller.markers.length, 3);

      // Remove some markers...
      final markerIdsToRemove = {
        MarkerId('1'),
        MarkerId('3'),
      };

      controller.removeMarkers(markerIdsToRemove);

      expect(controller.markers.length, 1);
      expect(controller.markers, isNot(contains(MarkerId('1'))));
      expect(controller.markers, contains(MarkerId('2')));
      expect(controller.markers, isNot(contains(MarkerId('3'))));
    });

    testWidgets('update', (WidgetTester tester) async {});
  });
}
