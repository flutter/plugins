// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:async';

import 'package:integration_test/integration_test.dart';
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

/// Test Markers
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    testWidgets('onTap gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onTap: onTap);
      // Simulate a click
      await marker.onClickController.add(null);
      expect(called, isTrue);
    });

    testWidgets('onDragEnd gets called', (WidgetTester tester) async {
      when(marker.draggable).thenReturn(true);
      MarkerController(marker: marker, onDragEnd: onDragEnd);
      // Simulate a drag end
      await marker.onDragEndController.add(_MockMouseEvent());
      expect(called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = MarkerController(marker: marker);
      final options = gmaps.MarkerOptions()..draggable = false;
      controller.update(options);
      verify(marker.options = options);
    });

    testWidgets('infoWindow null, showInfoWindow.',
        (WidgetTester tester) async {
      final controller = MarkerController(marker: marker);
      controller.showInfoWindow();
      expect(controller.infoWindowShown, isFalse);
    });

    testWidgets('showInfoWindow', (WidgetTester tester) async {
      final infoWindow = _MockInfoWindow();
      final controller =
          MarkerController(marker: marker, infoWindow: infoWindow);
      controller.showInfoWindow();
      verify(infoWindow.open(any, any)).called(1);
      expect(controller.infoWindowShown, isTrue);
    });

    testWidgets('hideInfoWindow', (WidgetTester tester) async {
      final infoWindow = _MockInfoWindow();
      final controller =
          MarkerController(marker: marker, infoWindow: infoWindow);
      controller.hideInfoWindow();
      verify(infoWindow.close()).called(1);
      expect(controller.infoWindowShown, isFalse);
    });
  });
}
