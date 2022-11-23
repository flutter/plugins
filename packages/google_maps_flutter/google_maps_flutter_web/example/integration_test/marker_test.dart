// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';

/// Test Markers
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Since onTap/DragEnd events happen asynchronously, we need to store when the event
  // is fired. We use a completer so the test can wait for the future to be completed.
  late Completer<bool> methodCalledCompleter;

  /// This is the future value of the [methodCalledCompleter]. Reinitialized
  /// in the [setUp] method, and completed (as `true`) by [onTap] and [onDragEnd]
  /// when those methods are called from the MarkerController.
  late Future<bool> methodCalled;

  void onTap() {
    methodCalledCompleter.complete(true);
  }

  void onDragStart(gmaps.LatLng _) {
    methodCalledCompleter.complete(true);
  }

  void onDrag(gmaps.LatLng _) {
    methodCalledCompleter.complete(true);
  }

  void onDragEnd(gmaps.LatLng _) {
    methodCalledCompleter.complete(true);
  }

  setUp(() {
    methodCalledCompleter = Completer<bool>();
    methodCalled = methodCalledCompleter.future;
  });

  group('MarkerController', () {
    late gmaps.Marker marker;

    setUp(() {
      marker = gmaps.Marker();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onTap: onTap);

      // Trigger a click event...
      gmaps.Event.trigger(marker, 'click', <Object?>[gmaps.MapMouseEvent()]);

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('onDragStart gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onDragStart: onDragStart);

      // Trigger a drag end event...
      gmaps.Event.trigger(marker, 'dragstart',
          <Object?>[gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0)]);

      expect(await methodCalled, isTrue);
    });

    testWidgets('onDrag gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onDrag: onDrag);

      // Trigger a drag end event...
      gmaps.Event.trigger(
        marker,
        'drag',
        <Object?>[gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0)],
      );

      expect(await methodCalled, isTrue);
    });

    testWidgets('onDragEnd gets called', (WidgetTester tester) async {
      MarkerController(marker: marker, onDragEnd: onDragEnd);

      // Trigger a drag end event...
      gmaps.Event.trigger(
        marker,
        'dragend',
        <Object?>[gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0)],
      );

      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final MarkerController controller = MarkerController(marker: marker);
      final gmaps.MarkerOptions options = gmaps.MarkerOptions()
        ..draggable = true
        ..position = gmaps.LatLng(42, 54);

      expect(marker.draggable, isNull);

      controller.update(options);

      expect(marker.draggable, isTrue);
      expect(marker.position?.lat, equals(42));
      expect(marker.position?.lng, equals(54));
    });

    testWidgets('infoWindow null, showInfoWindow.',
        (WidgetTester tester) async {
      final MarkerController controller = MarkerController(marker: marker);

      controller.showInfoWindow();

      expect(controller.infoWindowShown, isFalse);
    });

    testWidgets('showInfoWindow', (WidgetTester tester) async {
      final gmaps.InfoWindow infoWindow = gmaps.InfoWindow();
      final gmaps.GMap map = gmaps.GMap(html.DivElement());
      marker.set('map', map);
      final MarkerController controller = MarkerController(
        marker: marker,
        infoWindow: infoWindow,
      );

      controller.showInfoWindow();

      expect(infoWindow.get('map'), map);
      expect(controller.infoWindowShown, isTrue);
    });

    testWidgets('hideInfoWindow', (WidgetTester tester) async {
      final gmaps.InfoWindow infoWindow = gmaps.InfoWindow();
      final gmaps.GMap map = gmaps.GMap(html.DivElement());
      marker.set('map', map);
      final MarkerController controller = MarkerController(
        marker: marker,
        infoWindow: infoWindow,
      );

      controller.hideInfoWindow();

      expect(infoWindow.get('map'), isNull);
      expect(controller.infoWindowShown, isFalse);
    });

    group('remove', () {
      late MarkerController controller;

      setUp(() {
        final gmaps.InfoWindow infoWindow = gmaps.InfoWindow();
        final gmaps.GMap map = gmaps.GMap(html.DivElement());
        marker.set('map', map);
        controller = MarkerController(marker: marker, infoWindow: infoWindow);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.marker, isNull);
      });

      testWidgets('cannot call update after remove',
          (WidgetTester tester) async {
        final gmaps.MarkerOptions options = gmaps.MarkerOptions()
          ..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });

      testWidgets('cannot call showInfoWindow after remove',
          (WidgetTester tester) async {
        controller.remove();

        expect(() {
          controller.showInfoWindow();
        }, throwsAssertionError);
      });

      testWidgets('cannot call hideInfoWindow after remove',
          (WidgetTester tester) async {
        controller.remove();

        expect(() {
          controller.hideInfoWindow();
        }, throwsAssertionError);
      });
    });
  });
}
