import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  testWidgets('Initializing a ground overlay', (WidgetTester tester) async {
    final GroundOverlay g1 =
        GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.groundOverlaysToAdd.length, 1);

    final GroundOverlay initializedMarker =
        platformGoogleMap.groundOverlaysToAdd.first;
    expect(initializedMarker, equals(g1));
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToChange.isEmpty, true);
  });

  testWidgets("Adding a ground overlay", (WidgetTester tester) async {
    final GroundOverlay g1 =
    GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    final GroundOverlay g2 =
    GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_2"));

    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1, g2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.groundOverlaysToAdd.length, 1);

    final GroundOverlay addedGroundOverlay =
        platformGoogleMap.groundOverlaysToAdd.first;
    print(addedGroundOverlay.toJson());
    print(g2.toJson());
    expect(addedGroundOverlay, equals(g2));

    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.groundOverlaysToChange.isEmpty, true);
  });

  testWidgets("Removing a ground overlay", (WidgetTester tester) async {
    final GroundOverlay g1 =
    GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));

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
    final GroundOverlay g1 =
    GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    final GroundOverlay g2 = GroundOverlay(
        groundOverlayId: GroundOverlayId("g_overlay_1"), opacity: 0.5);

    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g1}));
    await tester.pumpWidget(_mapWithGroundOverlays(<GroundOverlay>{g2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.groundOverlaysToChange.length, 1);
    expect(platformGoogleMap.groundOverlaysToChange.first, equals(g2));

    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    GroundOverlay g1 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    GroundOverlay g2 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_2"));
    final Set<GroundOverlay> prev = <GroundOverlay>{g1, g2};
    g1 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"), visible: false);
    g2 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_2"), opacity: 0.5);
    final Set<GroundOverlay> cur = <GroundOverlay>{g1, g2};

    await tester.pumpWidget(_mapWithGroundOverlays(prev));
    await tester.pumpWidget(_mapWithGroundOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.groundOverlaysToChange, cur);
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    GroundOverlay g2 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_2"));
    final GroundOverlay g3 = GroundOverlay(groundOverlayId: GroundOverlayId("marker_3"));
    final Set<GroundOverlay> prev = <GroundOverlay>{g2, g3};

    // m1 is added, m2 is updated, m3 is removed.
    final GroundOverlay g1 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    g2 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_2"), visible: false);
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
    expect(platformGoogleMap.groundOverlayIdsToRemove.first, equals(g3.groundOverlayId));
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    final GroundOverlay g1 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    final GroundOverlay g2 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_2"));
    GroundOverlay g3 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_3"));
    final Set<GroundOverlay> prev = <GroundOverlay>{g1, g2, g3};
    g3 = GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_3"), visible: false);
    final Set<GroundOverlay> cur = <GroundOverlay>{g1, g2, g3};

    await tester.pumpWidget(_mapWithGroundOverlays(prev));
    await tester.pumpWidget(_mapWithGroundOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.groundOverlaysToChange, <GroundOverlay>{g3});
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets("Update non platform related attr", (WidgetTester tester) async {
    GroundOverlay g1 =
    GroundOverlay(groundOverlayId: GroundOverlayId("g_overlay_1"));
    final Set<GroundOverlay> prev = <GroundOverlay>{g1};
    g1 = GroundOverlay(
      groundOverlayId: GroundOverlayId("g_overlay_1"),
      onTap: () => print("hello"),
    );
    final Set<GroundOverlay> cur = <GroundOverlay>{g1};

    await tester.pumpWidget(_mapWithGroundOverlays(prev));
    await tester.pumpWidget(_mapWithGroundOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.groundOverlaysToChange.isEmpty, true);
    expect(platformGoogleMap.groundOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.groundOverlaysToAdd.isEmpty, true);
  });
}