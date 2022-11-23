// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

import 'resources/icon_image_base64.dart';

void main() {
  const LatLng mapCenter = LatLng(65.011890, 25.468021);
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Repeatedly checks an asynchronous value against a test condition, waiting
  // one frame between each check, returing the value if it passes the predicate
  // before [maxTries] is reached.
  //
  // Returns null if the predicate is never satisfied.
  //
  // This is useful for cases where the Maps SDK has some internally
  // asynchronous operation that we don't have visibility into (e.g., native UI
  // animations).
  Future<T?> waitForValueMatchingPredicate<T>(WidgetTester tester,
      Future<T> Function() getValue, bool Function(T) predicate,
      {int maxTries = 100}) async {
    for (int i = 0; i < maxTries; i++) {
      final T value = await getValue();
      if (predicate(value)) {
        return value;
      }
      await tester.pump();
    }
    return null;
  }

  group('MarkersController', () {
    late StreamController<MapEvent<Object?>> events;
    late MarkersController markersController;
    late ClusterManagersController clusterManagersController;
    late gmaps.GMap map;

    setUp(() {
      events = StreamController<MapEvent<Object?>>();
      clusterManagersController = ClusterManagersController(stream: events);
      markersController = MarkersController(
          stream: events, clusterManagersController: clusterManagersController);
      final gmaps.MapOptions options = gmaps.MapOptions();
      options.zoom = 4;
      options.center = gmaps.LatLng(mapCenter.latitude, mapCenter.longitude);
      map = gmaps.GMap(html.DivElement(), options);
      clusterManagersController.bindToMap(123, map);
      markersController.bindToMap(123, map);
    });

    testWidgets('addMarkers', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(markerId: MarkerId('1')),
        const Marker(markerId: MarkerId('2')),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers.length, 2);
      expect(markersController.markers, contains(const MarkerId('1')));
      expect(markersController.markers, contains(const MarkerId('2')));
      expect(markersController.markers, isNot(contains(const MarkerId('66'))));
    });

    testWidgets('changeMarkers', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(markerId: MarkerId('1')),
      };
      markersController.addMarkers(markers);

      expect(markersController.markers[const MarkerId('1')]?.marker?.draggable,
          isFalse);

      // Update the marker with radius 10
      final Set<Marker> updatedMarkers = <Marker>{
        const Marker(markerId: MarkerId('1'), draggable: true),
      };
      markersController.changeMarkers(updatedMarkers);

      expect(markersController.markers.length, 1);
      expect(markersController.markers[const MarkerId('1')]?.marker?.draggable,
          isTrue);
    });

    testWidgets('removeMarkers', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(markerId: MarkerId('1')),
        const Marker(markerId: MarkerId('2')),
        const Marker(markerId: MarkerId('3')),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers.length, 3);

      // Remove some markers...
      final Set<MarkerId> markerIdsToRemove = <MarkerId>{
        const MarkerId('1'),
        const MarkerId('3'),
      };

      markersController.removeMarkers(markerIdsToRemove);

      expect(markersController.markers.length, 1);
      expect(markersController.markers, isNot(contains(const MarkerId('1'))));
      expect(markersController.markers, contains(const MarkerId('2')));
      expect(markersController.markers, isNot(contains(const MarkerId('3'))));
    });

    testWidgets('InfoWindow show/hide', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers[const MarkerId('1')]?.infoWindowShown,
          isFalse);

      markersController.showMarkerInfoWindow(const MarkerId('1'));

      expect(markersController.markers[const MarkerId('1')]?.infoWindowShown,
          isTrue);

      markersController.hideMarkerInfoWindow(const MarkerId('1'));

      expect(markersController.markers[const MarkerId('1')]?.infoWindowShown,
          isFalse);
    });

    // https://github.com/flutter/flutter/issues/67380
    testWidgets('only single InfoWindow is visible',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
        const Marker(
          markerId: MarkerId('2'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
      };
      markersController.addMarkers(markers);

      expect(markersController.markers[const MarkerId('1')]?.infoWindowShown,
          isFalse);
      expect(markersController.markers[const MarkerId('2')]?.infoWindowShown,
          isFalse);

      markersController.showMarkerInfoWindow(const MarkerId('1'));

      expect(markersController.markers[const MarkerId('1')]?.infoWindowShown,
          isTrue);
      expect(markersController.markers[const MarkerId('2')]?.infoWindowShown,
          isFalse);

      markersController.showMarkerInfoWindow(const MarkerId('2'));

      expect(markersController.markers[const MarkerId('1')]?.infoWindowShown,
          isFalse);
      expect(markersController.markers[const MarkerId('2')]?.infoWindowShown,
          isTrue);
    });

    // https://github.com/flutter/flutter/issues/66622
    testWidgets('markers with custom bitmap icon work',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<Marker> markers = <Marker>{
        Marker(
          markerId: const MarkerId('1'),
          icon: BitmapDescriptor.fromBytes(bytes),
        ),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers.length, 1);
      final gmaps.Icon? icon = markersController
          .markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final String blobUrl = icon!.url!;
      expect(blobUrl, startsWith('blob:'));

      final http.Response response = await http.get(Uri.parse(blobUrl));
      expect(response.bodyBytes, bytes,
          reason:
              'Bytes from the Icon blob must match bytes used to create Marker');
    });

    // https://github.com/flutter/flutter/issues/73789
    testWidgets('markers with custom bitmap icon pass size to sdk',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<Marker> markers = <Marker>{
        Marker(
          markerId: const MarkerId('1'),
          icon: BitmapDescriptor.fromBytes(bytes, size: const Size(20, 30)),
        ),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers.length, 1);
      final gmaps.Icon? icon = markersController
          .markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final gmaps.Size size = icon!.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      expect(size.width, 20);
      expect(size.height, 30);
      expect(scaledSize.width, 20);
      expect(scaledSize.height, 30);
    });

    // https://github.com/flutter/flutter/issues/67854
    testWidgets('InfoWindow snippet can have links',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(
            title: 'title for test',
            snippet: '<a href="https://www.google.com">Go to Google >>></a>',
          ),
        ),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers.length, 1);
      final html.HtmlElement? content = markersController
          .markers[const MarkerId('1')]
          ?.infoWindow
          ?.content as html.HtmlElement?;
      expect(content?.innerHtml, contains('title for test'));
      expect(
          content?.innerHtml,
          contains(
            '<a href="https://www.google.com">Go to Google &gt;&gt;&gt;</a>',
          ));
    });

    // https://github.com/flutter/flutter/issues/67289
    testWidgets('InfoWindow content is clickable', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(
            title: 'title for test',
            snippet: 'some snippet',
          ),
        ),
      };

      markersController.addMarkers(markers);

      expect(markersController.markers.length, 1);
      final html.HtmlElement? content = markersController
          .markers[const MarkerId('1')]
          ?.infoWindow
          ?.content as html.HtmlElement?;

      content?.click();

      final MapEvent<Object?> event = await events.stream.first;

      expect(event, isA<InfoWindowTapEvent>());
      expect((event as InfoWindowTapEvent).value, equals(const MarkerId('1')));
    });

    testWidgets('clustering', (WidgetTester tester) async {
      const ClusterManagerId clusterManagerId = ClusterManagerId('cluster 1');

      final Set<ClusterManager> clusterManagers = <ClusterManager>{
        const ClusterManager(clusterManagerId: clusterManagerId),
      };

      // Create the marker with clusterManagerId.
      final Set<Marker> markers = <Marker>{
        const Marker(
            markerId: MarkerId('1'),
            position: mapCenter,
            clusterManagerId: clusterManagerId),
      };

      clusterManagersController.addClusterManagers(clusterManagers);
      markersController.addMarkers(markers);

      final List<Cluster> clusters =
          await waitForValueMatchingPredicate<List<Cluster>>(
                  tester,
                  () async =>
                      clusterManagersController.getClusters(clusterManagerId),
                  (List<Cluster> clusters) => clusters.isNotEmpty) ??
              <Cluster>[];

      expect(clusters.length, 1);

      // Update the marker with null clusterManagerId.
      final Set<Marker> updatedMarkers = <Marker>{
        markers.first.copyWithDefaults(defaultClusterManagerId: true)
      };
      markersController.changeMarkers(updatedMarkers);

      expect(markersController.markers.length, 1);

      expect(clusterManagersController.getClusters(clusterManagerId).length, 0);
    });
  });
}
