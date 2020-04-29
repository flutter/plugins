// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Set<Heatmap> _toSet({Heatmap p1, Heatmap p2, Heatmap p3}) {
  final Set<Heatmap> res = Set<Heatmap>.identity();
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

Widget _mapWithHeatmaps(Set<Heatmap> heatmaps) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      heatmaps: heatmaps,
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

  testWidgets('Initializing a heatmap', (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.heatmapsToAdd.length, 1);

    final Heatmap initializedHeatmap = platformGoogleMap.heatmapsToAdd.first;
    expect(initializedHeatmap, equals(p1));
    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToChange.isEmpty, true);
  });

  testWidgets("Adding a heatmap", (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    final Heatmap p2 = Heatmap(heatmapId: HeatmapId("heatmap_2"));

    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1, p2: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.heatmapsToAdd.length, 1);

    final Heatmap addedHeatmap = platformGoogleMap.heatmapsToAdd.first;
    expect(addedHeatmap, equals(p2));

    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.heatmapsToChange.isEmpty, true);
  });

  testWidgets("Removing a heatmap", (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));

    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithHeatmaps(null));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.heatmapIdsToRemove.length, 1);
    expect(platformGoogleMap.heatmapIdsToRemove.first, equals(p1.heatmapId));

    expect(platformGoogleMap.heatmapsToChange.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets("Updating a heatmap", (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    final Heatmap p2 = Heatmap(heatmapId: HeatmapId("heatmap_1"), opacity: 0.5);

    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.heatmapsToChange.length, 1);
    expect(platformGoogleMap.heatmapsToChange.first, equals(p2));

    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets("Updating a heatmap", (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    final Heatmap p2 =
        Heatmap(heatmapId: HeatmapId("heatmap_1"), visible: false);

    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p2)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.heatmapsToChange.length, 1);

    final Heatmap update = platformGoogleMap.heatmapsToChange.first;
    expect(update, equals(p2));
    expect(update.visible, false);
  });

  testWidgets("Mutate a heatmap", (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(
      heatmapId: HeatmapId("heatmap_1"),
      points: <WeightedLatLng>[
        WeightedLatLng(point: LatLng(0.0, 0.0), intensity: 1)
      ],
    );
    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));

    p1.points.add(WeightedLatLng(point: LatLng(1.0, 1.0), intensity: 1));
    await tester.pumpWidget(_mapWithHeatmaps(_toSet(p1: p1)));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.heatmapsToChange.length, 1);
    expect(platformGoogleMap.heatmapsToChange.first, equals(p1));

    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    Heatmap p2 = Heatmap(heatmapId: HeatmapId("heatmap_2"));
    final Set<Heatmap> prev = _toSet(p1: p1, p2: p2);
    p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"), visible: false);
    p2 = Heatmap(heatmapId: HeatmapId("heatmap_2"), opacity: 0.5);
    final Set<Heatmap> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.heatmapsToChange, cur);
    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    Heatmap p2 = Heatmap(heatmapId: HeatmapId("heatmap_2"));
    final Heatmap p3 = Heatmap(heatmapId: HeatmapId("heatmap_3"));
    final Set<Heatmap> prev = _toSet(p2: p2, p3: p3);

    // p1 is added, p2 is updated, p3 is removed.
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    p2 = Heatmap(heatmapId: HeatmapId("heatmap_2"), opacity: 0.5);
    final Set<Heatmap> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.heatmapsToChange.length, 1);
    expect(platformGoogleMap.heatmapsToAdd.length, 1);
    expect(platformGoogleMap.heatmapIdsToRemove.length, 1);

    expect(platformGoogleMap.heatmapsToChange.first, equals(p2));
    expect(platformGoogleMap.heatmapsToAdd.first, equals(p1));
    expect(platformGoogleMap.heatmapIdsToRemove.first, equals(p3.heatmapId));
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    final Heatmap p1 = Heatmap(heatmapId: HeatmapId("heatmap_1"));
    final Heatmap p2 = Heatmap(heatmapId: HeatmapId("heatmap_2"));
    Heatmap p3 = Heatmap(heatmapId: HeatmapId("heatmap_3"));
    final Set<Heatmap> prev = _toSet(p1: p1, p2: p2, p3: p3);
    p3 = Heatmap(heatmapId: HeatmapId("heatmap_3"), opacity: 0.5);
    final Set<Heatmap> cur = _toSet(p1: p1, p2: p2, p3: p3);

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.heatmapsToChange, _toSet(p3: p3));
    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });
}
