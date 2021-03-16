// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:integration_test/integration_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test Markers
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Completer<bool> _called;
  late Future<bool> called;

  void onTap() {
    _called.complete(true);
  }

  void onDragEnd(gmaps.LatLng _) {
    _called.complete(true);
  }

  setUp(() {
    _called = Completer();
    called = _called.future;
  });

  group('MarkerController', () {
    late gmaps.Marker marker;

    setUp(() {
      marker = gmaps.Marker();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onTap: onTap);

      // Trigger a click event...
      gmaps.Event.trigger(marker, 'click', [gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await called, isTrue);
    });

    testWidgets('onDragEnd gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onDragEnd: onDragEnd);

      // Trigger a drag end event...
      gmaps.Event.trigger(marker, 'dragend',
          [gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0)]);

      expect(await called, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = MarkerController(marker: marker);
      final options = gmaps.MarkerOptions()..draggable = true;

      expect(marker.draggable, isNull);

      controller.update(options);

      expect(marker.draggable, isTrue);
    });

    testWidgets('infoWindow null, showInfoWindow.',
        (WidgetTester tester) async {
      final controller = MarkerController(marker: marker);

      controller.showInfoWindow();

      expect(controller.infoWindowShown, isFalse);
    });

    testWidgets('showInfoWindow', (WidgetTester tester) async {
      final infoWindow = gmaps.InfoWindow();
      final map = gmaps.GMap(html.DivElement());
      marker.set('map', map);
      final controller =
          MarkerController(marker: marker, infoWindow: infoWindow);

      controller.showInfoWindow();

      expect(infoWindow.get('map'), map);
      expect(controller.infoWindowShown, isTrue);
    });

    testWidgets('hideInfoWindow', (WidgetTester tester) async {
      final infoWindow = gmaps.InfoWindow();
      final map = gmaps.GMap(html.DivElement());
      marker.set('map', map);
      final controller =
          MarkerController(marker: marker, infoWindow: infoWindow);

      controller.hideInfoWindow();

      expect(infoWindow.get('map'), isNull);
      expect(controller.infoWindowShown, isFalse);
    });
  });
}
