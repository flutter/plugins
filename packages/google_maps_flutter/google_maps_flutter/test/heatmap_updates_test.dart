// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

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
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.heatmapsToAdd.length, 1);

    final Heatmap initializedHeatmap = platformGoogleMap.heatmapsToAdd.first;
    expect(initializedHeatmap, equals(c1));
    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToChange.isEmpty, true);
  });

  testWidgets('Adding a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_2'));

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1, c2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.heatmapsToAdd.length, 1);

    final Heatmap addedHeatmap = platformGoogleMap.heatmapsToAdd.first;
    expect(addedHeatmap, equals(c2));

    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.heatmapsToChange.isEmpty, true);
  });

  testWidgets('Removing a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.heatmapIdsToRemove.length, 1);
    expect(platformGoogleMap.heatmapIdsToRemove.first, equals(c1.heatmapId));

    expect(platformGoogleMap.heatmapsToChange.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Updating a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_1'), radius: 10);

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.heatmapsToChange.length, 1);
    expect(platformGoogleMap.heatmapsToChange.first, equals(c2));

    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Updating a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_1'), radius: 10);

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.heatmapsToChange.length, 1);

    final Heatmap update = platformGoogleMap.heatmapsToChange.first;
    expect(update, equals(c2));
    expect(update.radius, 10);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Heatmap c1 = const Heatmap(heatmapId: HeatmapId('heatmap_1'));
    Heatmap c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'));
    final Set<Heatmap> prev = <Heatmap>{c1, c2};
    c1 = const Heatmap(heatmapId: HeatmapId('heatmap_1'), dissipating: false);
    c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'), radius: 10);
    final Set<Heatmap> cur = <Heatmap>{c1, c2};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.heatmapsToChange, cur);
    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Heatmap c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'));
    const Heatmap c3 = Heatmap(heatmapId: HeatmapId('heatmap_3'));
    final Set<Heatmap> prev = <Heatmap>{c2, c3};

    // c1 is added, c2 is updated, c3 is removed.
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'), radius: 10);
    final Set<Heatmap> cur = <Heatmap>{c1, c2};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.heatmapsToChange.length, 1);
    expect(platformGoogleMap.heatmapsToAdd.length, 1);
    expect(platformGoogleMap.heatmapIdsToRemove.length, 1);

    expect(platformGoogleMap.heatmapsToChange.first, equals(c2));
    expect(platformGoogleMap.heatmapsToAdd.first, equals(c1));
    expect(platformGoogleMap.heatmapIdsToRemove.first, equals(c3.heatmapId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_2'));
    Heatmap c3 = const Heatmap(heatmapId: HeatmapId('heatmap_3'));
    final Set<Heatmap> prev = <Heatmap>{c1, c2, c3};
    c3 = const Heatmap(heatmapId: HeatmapId('heatmap_3'), radius: 10);
    final Set<Heatmap> cur = <Heatmap>{c1, c2, c3};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.heatmapsToChange, <Heatmap>{c3});
    expect(platformGoogleMap.heatmapIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.heatmapsToAdd.isEmpty, true);
  });
}
