// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_maps_controllers.dart';

Widget _mapWithGroundOverlays(Set<GroundOverlay> groundOverlays) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      groundOverlays: groundOverlays,
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

  testWidgets('Initializing a ground overlay', (WidgetTester tester) async {
    final GroundOverlay g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59.935460, 30.325177),
      width: 200,
    );
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.groundOverlaysToAdd.length, 1);

    final GroundOverlay initializedGroundOverlay =
        platformGoogleMap.groundOverlaysToAdd.first;
    expect(initializedGroundOverlay, equals(g1));
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToChange.isEmpty, true);
  });

  testWidgets("Adding a ground overlay", (WidgetTester tester) async {
    final GroundOverlay g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59, 30),
      width: 200,
    );
    final GroundOverlay g2 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_2"),
      image: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      position: LatLng(60, 31),
      width: 400,
    );

    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1, g2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.groundOverlaysToAdd.length, 1);

    final GroundOverlay addedGroundOverlay =
        platformGoogleMap.groundOverlaysToAdd.first;
    expect(addedGroundOverlay, equals(g2));
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.groundOverlaysToChange.isEmpty, true);
  });

  testWidgets("Removing a ground overlay", (WidgetTester tester) async {
    final GroundOverlay g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59, 30),
      width: 200,
    );
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.groundOverlayIdsToRemove.length, 1);
    expect(platformGoogleMap.groundOverlayIdsToRemove.first,
        equals(g1.groundOverlayId));

    expect(platformGoogleMap.groundOverlaysToChange.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets("Updating a ground overlay", (WidgetTester tester) async {
    final GroundOverlay g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59, 30),
      width: 200,
    );
    final GroundOverlay g2 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59, 30),
      width: 200,
      bearing: 100,
    );

    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToChange.length, 1);
    expect(platformGoogleMap.groundOverlaysToChange.first, equals(g2));

    final GroundOverlay update = platformGoogleMap.groundOverlaysToChange.first;
    expect(update, equals(g2));
    expect(update.bearing, 100);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    GroundOverlay g2 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_2"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(60, 30),
      width: 200,
    );
    final GroundOverlay g3 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_3"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(65, 30),
      width: 200,
    );
    final Set<GroundOverlay> prev = <GroundOverlay>{g2, g3};

    // g1 is added, g2 is updated, g3 is removed.
    final GroundOverlay g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59, 30),
      width: 200,
    );
    g2 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_2"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59, 30),
      width: 200,
      bearing: 100,
      zIndex: 100,
    );
    final Set<GroundOverlay> cur = <GroundOverlay>{g1, g2};

    await tester.pumpWidget(_mapWithGroundOverlays(prev));
    await tester.pumpWidget(_mapWithGroundOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.groundOverlaysToChange.length, 1);
    expect(platformGoogleMap.groundOverlaysToAdd.length, 1);
    expect(platformGoogleMap.groundOverlayIdsToRemove.length, 1);

    expect(platformGoogleMap.groundOverlaysToChange.first, equals(g2));
    expect(platformGoogleMap.groundOverlaysToAdd.first, equals(g1));
    expect(platformGoogleMap.groundOverlayIdsToRemove.first,
        equals(g3.groundOverlayId));

    final GroundOverlay update = platformGoogleMap.groundOverlaysToChange.first;
    expect(update.zIndex, 100);
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    final GroundOverlay g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_1"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(60, 30),
      width: 200,
    );
    final GroundOverlay g2 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_2"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(65, 30),
      width: 200,
    );
    GroundOverlay g3 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_3"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(62, 30),
      width: 200,
    );
    final Set<GroundOverlay> prev = <GroundOverlay>{g1, g2, g3};
    g3 = GroundOverlay(
      groundOverlayId: GroundOverlayId("ground_overlay_3"),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(60, 30),
      width: 200,
      zIndex: 50,
    );
    final Set<GroundOverlay> cur = <GroundOverlay>{g1, g2, g3};

    await tester.pumpWidget(_mapWithGroundOverlays(prev));
    await tester.pumpWidget(_mapWithGroundOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.groundOverlaysToChange, <GroundOverlay>{g3});
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
  });
}
