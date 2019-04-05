// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Set<Polyline> _toSet({Polyline m1, Polyline m2, Polyline m3}) {
  final Set<Polyline> res = Set<Polyline>.identity();
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

Widget _mapWithPolylines(Set<Polyline> polylines) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polylines: polylines,
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

  testWidgets('Initializing a polyline', (WidgetTester tester) async {
    final Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));
    await tester.pumpWidget(_mapWithPolylines(_toSet(m1: m1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToAdd.length, 1);

    final Polyline initializedPolyline = platformGoogleMap.polylinesToAdd.first;
    expect(initializedPolyline, equals(m1));
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
  });

  testWidgets("Adding a polyline", (WidgetTester tester) async {
    final Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline m2 = Polyline(polylineId: PolylineId("polyline_2"));

    await tester.pumpWidget(_mapWithPolylines(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(m1: m1, m2: m2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToAdd.length, 1);

    final Polyline addedPolyline = platformGoogleMap.polylinesToAdd.first;
    expect(addedPolyline, equals(m2));
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToChange.first, equals(m1));
  });

  testWidgets("Removing a polyline", (WidgetTester tester) async {
    final Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));

    await tester.pumpWidget(_mapWithPolylines(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithPolylines(null));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylineIdsToRemove.length, 1);
    expect(platformGoogleMap.polylineIdsToRemove.first, equals(m1.polylineId));

    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets("Updating a polyline", (WidgetTester tester) async {
    final Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline m2 =
        Polyline(polylineId: PolylineId("polyline_1"), width: 4);

    await tester.pumpWidget(_mapWithPolylines(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(m1: m2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToChange.first, equals(m2));

    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));
    Polyline m2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Set<Polyline> prev = _toSet(m1: m1, m2: m2);
    m1 = Polyline(polylineId: PolylineId("polyline_1"), visible: false);
    m2 = Polyline(polylineId: PolylineId("polyline_2"), color: 12);
    final Set<Polyline> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polylinesToChange, cur);
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polyline m2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Polyline m3 = Polyline(polylineId: PolylineId("polyline_3"));
    final Set<Polyline> prev = _toSet(m2: m2, m3: m3);

    // m1 is added, m2 is updated, m3 is removed.
    final Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));
    m2 = Polyline(polylineId: PolylineId("polyline_2"), width: 5.0);
    final Set<Polyline> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToAdd.length, 1);
    expect(platformGoogleMap.polylineIdsToRemove.length, 1);

    expect(platformGoogleMap.polylinesToChange.first, equals(m2));
    expect(platformGoogleMap.polylinesToAdd.first, equals(m1));
    expect(platformGoogleMap.polylineIdsToRemove.first, equals(m3.polylineId));
  });

  testWidgets(
    "Partial Update",
    (WidgetTester tester) async {
      final Polyline m1 = Polyline(polylineId: PolylineId("polyline_1"));
      Polyline m2 = Polyline(polylineId: PolylineId("polyline_2"));
      final Set<Polyline> prev = _toSet(m1: m1, m2: m2);
      m2 = Polyline(polylineId: PolylineId("polyline_2"), visible: false);
      final Set<Polyline> cur = _toSet(m1: m1, m2: m2);

      await tester.pumpWidget(_mapWithPolylines(prev));
      await tester.pumpWidget(_mapWithPolylines(cur));

      final FakePlatformGoogleMap platformGoogleMap =
          fakePlatformViewsController.lastCreatedView;

      expect(platformGoogleMap.polylinesToChange, _toSet(m2: m2));
      expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
      expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
    },
    skip: true,
  );
}
