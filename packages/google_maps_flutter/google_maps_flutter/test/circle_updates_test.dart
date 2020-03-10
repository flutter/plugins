// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Set<Circle> _toSet({Circle c1, Circle c2, Circle c3}) {
  final Set<Circle> res = Set<Circle>.identity();
  if (c1 != null) {
    res.add(c1);
  }
  if (c2 != null) {
    res.add(c2);
  }
  if (c3 != null) {
    res.add(c3);
  }
  return res;
}

Widget _mapWithCircles(Set<Circle> circles) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      circles: circles,
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

  testWidgets('Initializing a circle', (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.circlesToAdd.length, 1);

    final Circle initializedCircle = platformGoogleMap.circlesToAdd.first;
    expect(initializedCircle, equals(c1));
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToChange.isEmpty, true);
  });

  testWidgets("Adding a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_2"));

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1, c2: c2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.circlesToAdd.length, 1);

    final Circle addedCircle = platformGoogleMap.circlesToAdd.first;
    expect(addedCircle, equals(c2));

    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.circlesToChange.isEmpty, true);
  });

  testWidgets("Removing a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(null));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.circleIdsToRemove.length, 1);
    expect(platformGoogleMap.circleIdsToRemove.first, equals(c1.circleId));

    expect(platformGoogleMap.circlesToChange.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Updating a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_1"), radius: 10);

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.circlesToChange.length, 1);
    expect(platformGoogleMap.circlesToChange.first, equals(c2));

    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Updating a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_1"), radius: 10);

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.circlesToChange.length, 1);

    final Circle update = platformGoogleMap.circlesToChange.first;
    expect(update, equals(c2));
    expect(update.radius, 10);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Circle c1 = Circle(circleId: CircleId("circle_1"));
    Circle c2 = Circle(circleId: CircleId("circle_2"));
    final Set<Circle> prev = _toSet(c1: c1, c2: c2);
    c1 = Circle(circleId: CircleId("circle_1"), visible: false);
    c2 = Circle(circleId: CircleId("circle_2"), radius: 10);
    final Set<Circle> cur = _toSet(c1: c1, c2: c2);

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.circlesToChange, cur);
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Circle c2 = Circle(circleId: CircleId("circle_2"));
    final Circle c3 = Circle(circleId: CircleId("circle_3"));
    final Set<Circle> prev = _toSet(c2: c2, c3: c3);

    // c1 is added, c2 is updated, c3 is removed.
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    c2 = Circle(circleId: CircleId("circle_2"), radius: 10);
    final Set<Circle> cur = _toSet(c1: c1, c2: c2);

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.circlesToChange.length, 1);
    expect(platformGoogleMap.circlesToAdd.length, 1);
    expect(platformGoogleMap.circleIdsToRemove.length, 1);

    expect(platformGoogleMap.circlesToChange.first, equals(c2));
    expect(platformGoogleMap.circlesToAdd.first, equals(c1));
    expect(platformGoogleMap.circleIdsToRemove.first, equals(c3.circleId));
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_2"));
    Circle c3 = Circle(circleId: CircleId("circle_3"));
    final Set<Circle> prev = _toSet(c1: c1, c2: c2, c3: c3);
    c3 = Circle(circleId: CircleId("circle_3"), radius: 10);
    final Set<Circle> cur = _toSet(c1: c1, c2: c2, c3: c3);

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.circlesToChange, _toSet(c3: c3));
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });
}
