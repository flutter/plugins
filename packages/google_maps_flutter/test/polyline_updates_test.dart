// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Set<Polyline> _toSet({Polyline p1, Polyline p2, Polyline p3}) {
  final Set<Polyline> res = Set<Polyline>.identity();
  if (p1 != null) {
    res.add(p1);
  }
  if (p2 != null) {
    res.add(p2);
  }
  if (p3 != null) {
    res.add(p3);
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
  TestWidgetsFlutterBinding.ensureInitialized();

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
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToAdd.length, 1);

    final Polyline initializedPolyline = platformGoogleMap.polylinesToAdd.first;
    expect(initializedPolyline, equals(p1));
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
  });

  testWidgets("Adding a polyline", (WidgetTester tester) async {
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1, p2: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToAdd.length, 1);

    final Polyline addedPolyline = platformGoogleMap.polylinesToAdd.first;
    expect(addedPolyline, equals(p2));

    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
  });

  testWidgets("Removing a polyline", (WidgetTester tester) async {
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(null));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylineIdsToRemove.length, 1);
    expect(platformGoogleMap.polylineIdsToRemove.first, equals(p1.polylineId));

    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets("Updating a polyline", (WidgetTester tester) async {
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 =
        Polyline(polylineId: PolylineId("polyline_1"), geodesic: true);

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToChange.first, equals(p2));

    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets("Updating a polyline", (WidgetTester tester) async {
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 =
        Polyline(polylineId: PolylineId("polyline_1"), geodesic: true);

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polylinesToChange.length, 1);

    final Polyline update = platformGoogleMap.polylinesToChange.first;
    expect(update, equals(p2));
    expect(update.geodesic, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Set<Polyline> prev = _toSet(p1: p1, p2: p2);
    p1 = Polyline(polylineId: PolylineId("polyline_1"), visible: false);
    p2 = Polyline(polylineId: PolylineId("polyline_2"), geodesic: true);
    final Set<Polyline> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polylinesToChange, cur);
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Polyline p3 = Polyline(polylineId: PolylineId("polyline_3"));
    final Set<Polyline> prev = _toSet(p2: p2, p3: p3);

    // p1 is added, p2 is updated, p3 is removed.
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    p2 = Polyline(polylineId: PolylineId("polyline_2"), geodesic: true);
    final Set<Polyline> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToAdd.length, 1);
    expect(platformGoogleMap.polylineIdsToRemove.length, 1);

    expect(platformGoogleMap.polylinesToChange.first, equals(p2));
    expect(platformGoogleMap.polylinesToAdd.first, equals(p1));
    expect(platformGoogleMap.polylineIdsToRemove.first, equals(p3.polylineId));
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));
    Polyline p3 = Polyline(polylineId: PolylineId("polyline_3"));
    final Set<Polyline> prev = _toSet(p1: p1, p2: p2, p3: p3);
    p3 = Polyline(polylineId: PolylineId("polyline_3"), geodesic: true);
    final Set<Polyline> cur = _toSet(p1: p1, p2: p2, p3: p3);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polylinesToChange, _toSet(p3: p3));
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });
}
