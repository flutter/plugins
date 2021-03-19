// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

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
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.circlesToAdd.length, 1);

    final Circle initializedCircle = platformGoogleMap.circlesToAdd.first;
    expect(initializedCircle, equals(c1));
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToChange.isEmpty, true);
  });

  testWidgets("Adding a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_2"));

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1, c2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.circlesToAdd.length, 1);

    final Circle addedCircle = platformGoogleMap.circlesToAdd.first;
    expect(addedCircle, equals(c2));

    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.circlesToChange.isEmpty, true);
  });

  testWidgets("Removing a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.circleIdsToRemove.length, 1);
    expect(platformGoogleMap.circleIdsToRemove.first, equals(c1.circleId));

    expect(platformGoogleMap.circlesToChange.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Updating a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_1"), radius: 10);

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.circlesToChange.length, 1);
    expect(platformGoogleMap.circlesToChange.first, equals(c2));

    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Updating a circle", (WidgetTester tester) async {
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_1"), radius: 10);

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.circlesToChange.length, 1);

    final Circle update = platformGoogleMap.circlesToChange.first;
    expect(update, equals(c2));
    expect(update.radius, 10);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Circle c1 = Circle(circleId: CircleId("circle_1"));
    Circle c2 = Circle(circleId: CircleId("circle_2"));
    final Set<Circle> prev = <Circle>{c1, c2};
    c1 = Circle(circleId: CircleId("circle_1"), visible: false);
    c2 = Circle(circleId: CircleId("circle_2"), radius: 10);
    final Set<Circle> cur = <Circle>{c1, c2};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.circlesToChange, cur);
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Circle c2 = Circle(circleId: CircleId("circle_2"));
    final Circle c3 = Circle(circleId: CircleId("circle_3"));
    final Set<Circle> prev = <Circle>{c2, c3};

    // c1 is added, c2 is updated, c3 is removed.
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    c2 = Circle(circleId: CircleId("circle_2"), radius: 10);
    final Set<Circle> cur = <Circle>{c1, c2};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

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
    final Set<Circle> prev = <Circle>{c1, c2, c3};
    c3 = Circle(circleId: CircleId("circle_3"), radius: 10);
    final Set<Circle> cur = <Circle>{c1, c2, c3};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.circlesToChange, <Circle>{c3});
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });

  testWidgets("Update non platform related attr", (WidgetTester tester) async {
    Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Set<Circle> prev = <Circle>{c1};
    c1 = Circle(circleId: CircleId("circle_1"), onTap: () => print("hello"));
    final Set<Circle> cur = <Circle>{c1};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.circlesToChange.isEmpty, true);
    expect(platformGoogleMap.circleIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.circlesToAdd.isEmpty, true);
  });
}
