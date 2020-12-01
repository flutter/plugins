// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Set<Polygon> _toSet({Polygon p1, Polygon p2, Polygon p3}) {
  final Set<Polygon> res = Set<Polygon>.identity();
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

Widget _mapWithPolygons(Set<Polygon> polygons) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polygons: polygons,
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

  testWidgets('Initializing a polygon', (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon initializedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(initializedPolygon, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });

  testWidgets("Adding a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));

    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1, p2: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon addedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(addedPolygon, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });

  testWidgets("Removing a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));

    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolygons(null));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p1.polygonId));

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Updating a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 =
        Polygon(polygonId: PolygonId("polygon_1"), geodesic: true);

    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Updating a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 =
        Polygon(polygonId: PolygonId("polygon_1"), geodesic: true);

    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polygonsToChange.length, 1);

    final Polygon update = platformGoogleMap.polygonsToChange.first;
    expect(update, equals(p2));
    expect(update.geodesic, true);
  });

  testWidgets("Mutate a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(
      polygonId: PolygonId("polygon_1"),
      points: <LatLng>[const LatLng(0.0, 0.0)],
    );
    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));

    p1.points.add(const LatLng(1.0, 1.0));
    await tester.pumpWidget(_mapWithPolygons(_toSet(p1: p1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p1));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));
    final Set<Polygon> prev = _toSet(p1: p1, p2: p2);
    p1 = Polygon(polygonId: PolygonId("polygon_1"), visible: false);
    p2 = Polygon(polygonId: PolygonId("polygon_2"), geodesic: true);
    final Set<Polygon> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polygonsToChange, cur);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));
    final Polygon p3 = Polygon(polygonId: PolygonId("polygon_3"));
    final Set<Polygon> prev = _toSet(p2: p2, p3: p3);

    // p1 is added, p2 is updated, p3 is removed.
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    p2 = Polygon(polygonId: PolygonId("polygon_2"), geodesic: true);
    final Set<Polygon> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToAdd.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);

    expect(platformGoogleMap.polygonsToChange.first, equals(p2));
    expect(platformGoogleMap.polygonsToAdd.first, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p3.polygonId));
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));
    Polygon p3 = Polygon(polygonId: PolygonId("polygon_3"));
    final Set<Polygon> prev = _toSet(p1: p1, p2: p2, p3: p3);
    p3 = Polygon(polygonId: PolygonId("polygon_3"), geodesic: true);
    final Set<Polygon> cur = _toSet(p1: p1, p2: p2, p3: p3);

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polygonsToChange, _toSet(p3: p3));
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Update non platform related attr", (WidgetTester tester) async {
    Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Set<Polygon> prev = _toSet(p1: p1);
    p1 = Polygon(polygonId: PolygonId("polygon_1"), onTap: () => print(2 + 2));
    final Set<Polygon> cur = _toSet(p1: p1);

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
}
