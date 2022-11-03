// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

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
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polylinesToAdd.length, 1);

    final Polyline initializedPolyline = platformGoogleMap.polylinesToAdd.first;
    expect(initializedPolyline, equals(p1));
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
  });

  testWidgets('Adding a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 = Polyline(polylineId: PolylineId('polyline_2'));

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1, p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polylinesToAdd.length, 1);

    final Polyline addedPolyline = platformGoogleMap.polylinesToAdd.first;
    expect(addedPolyline, equals(p2));

    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
  });

  testWidgets('Removing a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polylineIdsToRemove.length, 1);
    expect(platformGoogleMap.polylineIdsToRemove.first, equals(p1.polylineId));

    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Updating a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 =
        Polyline(polylineId: PolylineId('polyline_1'), geodesic: true);

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToChange.first, equals(p2));

    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Updating a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 =
        Polyline(polylineId: PolylineId('polyline_1'), geodesic: true);

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polylinesToChange.length, 1);

    final Polyline update = platformGoogleMap.polylinesToChange.first;
    expect(update, equals(p2));
    expect(update.geodesic, true);
  });

  testWidgets('Mutate a polyline', (WidgetTester tester) async {
    final List<LatLng> points = <LatLng>[const LatLng(0.0, 0.0)];
    final Polyline p1 = Polyline(
      polylineId: const PolylineId('polyline_1'),
      points: points,
    );
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));

    p1.points.add(const LatLng(1.0, 1.0));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToChange.first, equals(p1));

    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Polyline p1 = const Polyline(polylineId: PolylineId('polyline_1'));
    Polyline p2 = const Polyline(polylineId: PolylineId('polyline_2'));
    final Set<Polyline> prev = <Polyline>{p1, p2};
    p1 = const Polyline(polylineId: PolylineId('polyline_1'), visible: false);
    p2 = const Polyline(polylineId: PolylineId('polyline_2'), geodesic: true);
    final Set<Polyline> cur = <Polyline>{p1, p2};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polylinesToChange, cur);
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Polyline p2 = const Polyline(polylineId: PolylineId('polyline_2'));
    const Polyline p3 = Polyline(polylineId: PolylineId('polyline_3'));
    final Set<Polyline> prev = <Polyline>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    p2 = const Polyline(polylineId: PolylineId('polyline_2'), geodesic: true);
    final Set<Polyline> cur = <Polyline>{p1, p2};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polylinesToChange.length, 1);
    expect(platformGoogleMap.polylinesToAdd.length, 1);
    expect(platformGoogleMap.polylineIdsToRemove.length, 1);

    expect(platformGoogleMap.polylinesToChange.first, equals(p2));
    expect(platformGoogleMap.polylinesToAdd.first, equals(p1));
    expect(platformGoogleMap.polylineIdsToRemove.first, equals(p3.polylineId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 = Polyline(polylineId: PolylineId('polyline_2'));
    Polyline p3 = const Polyline(polylineId: PolylineId('polyline_3'));
    final Set<Polyline> prev = <Polyline>{p1, p2, p3};
    p3 = const Polyline(polylineId: PolylineId('polyline_3'), geodesic: true);
    final Set<Polyline> cur = <Polyline>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polylinesToChange, <Polyline>{p3});
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    Polyline p1 = const Polyline(polylineId: PolylineId('polyline_1'));
    final Set<Polyline> prev = <Polyline>{p1};
    p1 = Polyline(
        polylineId: const PolylineId('polyline_1'), onTap: () => print(2 + 2));
    final Set<Polyline> cur = <Polyline>{p1};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polylinesToChange.isEmpty, true);
    expect(platformGoogleMap.polylineIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polylinesToAdd.isEmpty, true);
  });
}
