// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Set<Marker> _toSet({Marker m1, Marker m2, Marker m3}) {
  final Set<Marker> res = Set<Marker>.identity();
  if (m1 != null) {
    res.add(m1);
  }
  if (m2 != null) {
    res.add(m2);
  }
  if (m3 != null) {
    res.add(m3);
  }
  return res;
}

Widget _mapWithMarkers(Set<Marker> markers) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      markers: markers,
    ),
  );
}

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  testWidgets('Initializing a marker', (WidgetTester tester) async {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.markersToAdd.length, 1);

    final Marker initializedMarker = platformGoogleMap.markersToAdd.first;
    expect(initializedMarker, equals(m1));
    expect(platformGoogleMap.markerIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.markersToChange.isEmpty, true);
  });

  testWidgets("Adding a marker", (WidgetTester tester) async {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(markerId: MarkerId("marker_2"));

    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m1, m2: m2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.markersToAdd.length, 1);

    final Marker addedMarker = platformGoogleMap.markersToAdd.first;
    expect(addedMarker, equals(m2));
    expect(platformGoogleMap.markerIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.markersToChange.length, 1);
    expect(platformGoogleMap.markersToChange.first, equals(m1));
  });

  testWidgets("Removing a marker", (WidgetTester tester) async {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));

    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithMarkers(null));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.markerIdsToRemove.length, 1);
    expect(platformGoogleMap.markerIdsToRemove.first, equals(m1.markerId));

    expect(platformGoogleMap.markersToChange.isEmpty, true);
    expect(platformGoogleMap.markersToAdd.isEmpty, true);
  });

  testWidgets("Updating a marker", (WidgetTester tester) async {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(markerId: MarkerId("marker_1"), alpha: 0.5);

    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.markersToChange.length, 1);
    expect(platformGoogleMap.markersToChange.first, equals(m2));

    expect(platformGoogleMap.markerIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.markersToAdd.isEmpty, true);
  });

  testWidgets("Updating a marker", (WidgetTester tester) async {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(
      markerId: MarkerId("marker_1"),
      infoWindow: const InfoWindow(snippet: 'changed'),
    );

    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithMarkers(_toSet(m1: m2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.markersToChange.length, 1);

    final Marker update = platformGoogleMap.markersToChange.first;
    expect(update, equals(m2));
    expect(update.infoWindow.snippet, 'changed');
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Marker m1 = Marker(markerId: MarkerId("marker_1"));
    Marker m2 = Marker(markerId: MarkerId("marker_2"));
    final Set<Marker> prev = _toSet(m1: m1, m2: m2);
    m1 = Marker(markerId: MarkerId("marker_1"), visible: false);
    m2 = Marker(markerId: MarkerId("marker_2"), draggable: true);
    final Set<Marker> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.markersToChange, cur);
    expect(platformGoogleMap.markerIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.markersToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Marker m2 = Marker(markerId: MarkerId("marker_2"));
    final Marker m3 = Marker(markerId: MarkerId("marker_3"));
    final Set<Marker> prev = _toSet(m2: m2, m3: m3);

    // m1 is added, m2 is updated, m3 is removed.
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    m2 = Marker(markerId: MarkerId("marker_2"), draggable: true);
    final Set<Marker> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.markersToChange.length, 1);
    expect(platformGoogleMap.markersToAdd.length, 1);
    expect(platformGoogleMap.markerIdsToRemove.length, 1);

    expect(platformGoogleMap.markersToChange.first, equals(m2));
    expect(platformGoogleMap.markersToAdd.first, equals(m1));
    expect(platformGoogleMap.markerIdsToRemove.first, equals(m3.markerId));
  });
}
