@TestOn('chrome') // Uses web-only Flutter SDKs...

import 'dart:async';

import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _MockMarker extends Mock implements gmaps.Marker {
  final onClickController = StreamController<gmaps.MouseEvent>();
  final onDragEndController = StreamController<gmaps.MouseEvent>();

  @override
  Stream<gmaps.MouseEvent> get onClick => onClickController.stream;

  @override
  Stream<gmaps.MouseEvent> get onDragend => onDragEndController.stream;
}

class _MockMouseEvent extends Mock implements gmaps.MouseEvent {}

class _MockInfoWindow extends Mock implements gmaps.InfoWindow {}

final gmaps.LatLng _nullIsland = gmaps.LatLng(0, 0);

/// Test Shapes (Circle, Polygon, Polyline)
void markerTests() {
  bool called = false;
  void onTap() {
    called = true;
  }

  void onDragEnd(gmaps.LatLng _) {
    called = true;
  }

  setUp(() {
    called = false;
  });

  group('MarkerController', () {
    _MockMarker marker;

    setUp(() {
      marker = _MockMarker();
    });

    test('onTap gets called', () async {
      MarkerController(marker: marker, onTap: onTap);
      // Simulate a click
      await marker.onClickController.add(null);
      expect(called, isTrue);
    });

    test('onDragEnd gets called', () async {
      when(marker.draggable).thenReturn(true);
      MarkerController(marker: marker, onDragEnd: onDragEnd);
      // Simulate a drag end
      await marker.onDragEndController.add(_MockMouseEvent());
      expect(called, isTrue);
    });

    test('update', () {
      final controller = MarkerController(marker: marker);
      final options = gmaps.MarkerOptions()..draggable = false;
      controller.update(options);
      verify(marker.options = options);
    });

    test('infoWindow null, showInfoWindow.', () {
      final controller = MarkerController(marker: marker);
      controller.showInfoWindow();
      expect(controller.infoWindowShown, isFalse);
    });

    test('showInfoWindow', () {
      final infoWindow = _MockInfoWindow();
      final controller =
          MarkerController(marker: marker, infoWindow: infoWindow);
      controller.showInfoWindow();
      verify(infoWindow.open(any)).called(1);
      expect(controller.infoWindowShown, isTrue);
    });

    test('hideInfoWindow', () {
      final infoWindow = _MockInfoWindow();
      final controller =
          MarkerController(marker: marker, infoWindow: infoWindow);
      controller.hideInfoWindow();
      verify(infoWindow.close()).called(1);
      expect(controller.infoWindowShown, isFalse);
    });
  });
}
