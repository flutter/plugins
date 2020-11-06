// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:integration_test/integration_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    testWidgets('InfoWindow show/hide', (WidgetTester tester) async {
      final markers = {
        Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: "Title", snippet: "Snippet"),
        ),
      };

      controller.addMarkers(markers);

      expect(controller.markers[MarkerId('1')].infoWindowShown, isFalse);

      controller.showMarkerInfoWindow(MarkerId('1'));

      expect(controller.markers[MarkerId('1')].infoWindowShown, isTrue);

      controller.hideMarkerInfoWindow(MarkerId('1'));

      expect(controller.markers[MarkerId('1')].infoWindowShown, isFalse);
    });

    // https://github.com/flutter/flutter/issues/67380
    testWidgets('only single InfoWindow is visible',
        (WidgetTester tester) async {
      final markers = {
        Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: "Title", snippet: "Snippet"),
        ),
        Marker(
          markerId: MarkerId('2'),
          infoWindow: InfoWindow(title: "Title", snippet: "Snippet"),
        ),
      };
      controller.addMarkers(markers);

      expect(controller.markers[MarkerId('1')].infoWindowShown, isFalse);
      expect(controller.markers[MarkerId('2')].infoWindowShown, isFalse);

      controller.showMarkerInfoWindow(MarkerId('1'));

      expect(controller.markers[MarkerId('1')].infoWindowShown, isTrue);
      expect(controller.markers[MarkerId('2')].infoWindowShown, isFalse);

      controller.showMarkerInfoWindow(MarkerId('2'));

      expect(controller.markers[MarkerId('1')].infoWindowShown, isFalse);
      expect(controller.markers[MarkerId('2')].infoWindowShown, isTrue);
    });

    // https://github.com/flutter/flutter/issues/64938
    testWidgets('markers with icon:null work', (WidgetTester tester) async {
      final markers = {
        Marker(markerId: MarkerId('1'), icon: null),
      };

      controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      expect(controller.markers[MarkerId('1')].marker.icon, isNull);
    });

    // https://github.com/flutter/flutter/issues/67854
    testWidgets('InfoWindow snippet can have links',
        (WidgetTester tester) async {
      final markers = {
        Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(
            title: 'title for test',
            snippet: '<a href="https://www.google.com">Go to Google >>></a>',
          ),
        ),
      };

      controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final content =
          controller.markers[MarkerId('1')].infoWindow.content as HtmlElement;
      expect(content.innerHtml, contains('title for test'));
      expect(
          content.innerHtml,
          contains(
              '<a href="https://www.google.com">Go to Google &gt;&gt;&gt;</a>'));
    });

    // https://github.com/flutter/flutter/issues/67289
    testWidgets('InfoWindow content is clickable', (WidgetTester tester) async {
      final markers = {
        Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(
            title: 'title for test',
            snippet: 'some snippet',
          ),
        ),
      };

      controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final content =
          controller.markers[MarkerId('1')].infoWindow.content as HtmlElement;

      content.click();

      final event = await stream.stream.first;

      expect(event, isA<InfoWindowTapEvent>());
      expect((event as InfoWindowTapEvent).value, equals(MarkerId('1')));
    });
  });
}
