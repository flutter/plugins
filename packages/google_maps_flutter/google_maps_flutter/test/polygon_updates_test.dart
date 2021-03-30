// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Widget _mapWithPolygons(Set<Polygon> polygons) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polygons: polygons,
    ),
  );
}

List<LatLng> _rectPoints({
  required double size,
  LatLng center = const LatLng(0, 0),
}) {
  final halfSize = size / 2;

  return [
    LatLng(center.latitude + halfSize, center.longitude + halfSize),
    LatLng(center.latitude - halfSize, center.longitude + halfSize),
    LatLng(center.latitude - halfSize, center.longitude - halfSize),
    LatLng(center.latitude + halfSize, center.longitude - halfSize),
  ];
}

Polygon _polygonWithPointsAndHole(PolygonId polygonId) {
  _rectPoints(size: 1);
  return Polygon(
    polygonId: polygonId,
    points: _rectPoints(size: 1),
    holes: [_rectPoints(size: 0.5)],
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
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon initializedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(initializedPolygon, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });

  testWidgets("Adding a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon addedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(addedPolygon, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });

  testWidgets("Removing a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p1.polygonId));

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Updating a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 =
        Polygon(polygonId: PolygonId("polygon_1"), geodesic: true);

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Mutate a polygon", (WidgetTester tester) async {
    final Polygon p1 = Polygon(
      polygonId: PolygonId("polygon_1"),
      points: <LatLng>[const LatLng(0.0, 0.0)],
    );
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    p1.points.add(const LatLng(1.0, 1.0));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p1));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));
    final Set<Polygon> prev = <Polygon>{p1, p2};
    p1 = Polygon(polygonId: PolygonId("polygon_1"), visible: false);
    p2 = Polygon(polygonId: PolygonId("polygon_2"), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange, cur);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));
    final Polygon p3 = Polygon(polygonId: PolygonId("polygon_3"));
    final Set<Polygon> prev = <Polygon>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    p2 = Polygon(polygonId: PolygonId("polygon_2"), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

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
    final Set<Polygon> prev = <Polygon>{p1, p2, p3};
    p3 = Polygon(polygonId: PolygonId("polygon_3"), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange, <Polygon>{p3});
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Update non platform related attr", (WidgetTester tester) async {
    Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Set<Polygon> prev = <Polygon>{p1};
    p1 = Polygon(polygonId: PolygonId("polygon_1"), onTap: () => print(2 + 2));
    final Set<Polygon> cur = <Polygon>{p1};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Initializing a polygon with points and hole',
      (WidgetTester tester) async {
    final Polygon p1 = _polygonWithPointsAndHole(PolygonId("polygon_1"));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon initializedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(initializedPolygon, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });

  testWidgets("Adding a polygon with points and hole",
      (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 = _polygonWithPointsAndHole(PolygonId("polygon_2"));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon addedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(addedPolygon, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });

  testWidgets("Removing a polygon with points and hole",
      (WidgetTester tester) async {
    final Polygon p1 = _polygonWithPointsAndHole(PolygonId("polygon_1"));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p1.polygonId));

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Updating a polygon by adding points and hole",
      (WidgetTester tester) async {
    final Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    final Polygon p2 = _polygonWithPointsAndHole(PolygonId("polygon_1"));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Mutate a polygon with points and holes",
      (WidgetTester tester) async {
    final Polygon p1 = Polygon(
      polygonId: PolygonId("polygon_1"),
      points: _rectPoints(size: 1),
      holes: [_rectPoints(size: 0.5)],
    );
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    p1.points
      ..clear()
      ..addAll(_rectPoints(size: 2));
    p1.holes
      ..clear()
      ..addAll([_rectPoints(size: 1)]);
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p1));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update polygons with points and hole",
      (WidgetTester tester) async {
    Polygon p1 = Polygon(polygonId: PolygonId("polygon_1"));
    Polygon p2 = Polygon(
      polygonId: PolygonId("polygon_2"),
      points: _rectPoints(size: 2),
      holes: [_rectPoints(size: 1)],
    );
    final Set<Polygon> prev = <Polygon>{p1, p2};
    p1 = Polygon(polygonId: PolygonId("polygon_1"), visible: false);
    p2 = p2.copyWith(
      pointsParam: _rectPoints(size: 5),
      holesParam: [_rectPoints(size: 2)],
    );
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange, cur);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update polygons with points and hole",
      (WidgetTester tester) async {
    Polygon p2 = Polygon(
      polygonId: PolygonId("polygon_2"),
      points: _rectPoints(size: 2),
      holes: [_rectPoints(size: 1)],
    );
    final Polygon p3 = Polygon(polygonId: PolygonId("polygon_3"));
    final Set<Polygon> prev = <Polygon>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    final Polygon p1 = _polygonWithPointsAndHole(PolygonId("polygon_1"));
    p2 = p2.copyWith(
      pointsParam: _rectPoints(size: 5),
      holesParam: [_rectPoints(size: 3)],
    );
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToAdd.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);

    expect(platformGoogleMap.polygonsToChange.first, equals(p2));
    expect(platformGoogleMap.polygonsToAdd.first, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p3.polygonId));
  });

  testWidgets("Partial Update polygons with points and hole",
      (WidgetTester tester) async {
    final Polygon p1 = _polygonWithPointsAndHole(PolygonId("polygon_1"));
    final Polygon p2 = Polygon(polygonId: PolygonId("polygon_2"));
    Polygon p3 = Polygon(
      polygonId: PolygonId("polygon_3"),
      points: _rectPoints(size: 2),
      holes: [_rectPoints(size: 1)],
    );
    final Set<Polygon> prev = <Polygon>{p1, p2, p3};
    p3 = p3.copyWith(
      pointsParam: _rectPoints(size: 5),
      holesParam: [_rectPoints(size: 3)],
    );
    final Set<Polygon> cur = <Polygon>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange, <Polygon>{p3});
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
}
