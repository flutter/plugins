// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Widget _mapWithTileOverlays(Set<TileOverlay> tileOverlays) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      tileOverlays: tileOverlays,
    ),
  );
}

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform_views,
          fakePlatformViewsController.fakePlatformViewsMethodHandler,
        );
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  testWidgets('Initializing a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.tileOverlaysToAdd.length, 1);

    final TileOverlay initializedTileOverlay =
        platformGoogleMap.tileOverlaysToAdd.first;
    expect(initializedTileOverlay, equals(t1));
    expect(platformGoogleMap.tileOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.tileOverlaysToChange.isEmpty, true);
  });

  testWidgets('Adding a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    const TileOverlay t2 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_2'));

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1, t2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.tileOverlaysToAdd.length, 1);

    final TileOverlay addedTileOverlay =
        platformGoogleMap.tileOverlaysToAdd.first;
    expect(addedTileOverlay, equals(t2));
    expect(platformGoogleMap.tileOverlayIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.tileOverlaysToChange.isEmpty, true);
  });

  testWidgets('Removing a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.tileOverlayIdsToRemove.length, 1);
    expect(platformGoogleMap.tileOverlayIdsToRemove.first,
        equals(t1.tileOverlayId));

    expect(platformGoogleMap.tileOverlaysToChange.isEmpty, true);
    expect(platformGoogleMap.tileOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Updating a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    const TileOverlay t2 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'), zIndex: 10);

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.tileOverlaysToChange.length, 1);
    expect(platformGoogleMap.tileOverlaysToChange.first, equals(t2));

    expect(platformGoogleMap.tileOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.tileOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Updating a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    const TileOverlay t2 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'), zIndex: 10);

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t2}));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.tileOverlaysToChange.length, 1);

    final TileOverlay update = platformGoogleMap.tileOverlaysToChange.first;
    expect(update, equals(t2));
    expect(update.zIndex, 10);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    TileOverlay t1 =
        const TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    TileOverlay t2 =
        const TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_2'));
    final Set<TileOverlay> prev = <TileOverlay>{t1, t2};
    t1 = const TileOverlay(
        tileOverlayId: TileOverlayId('tile_overlay_1'), visible: false);
    t2 = const TileOverlay(
        tileOverlayId: TileOverlayId('tile_overlay_2'), zIndex: 10);
    final Set<TileOverlay> cur = <TileOverlay>{t1, t2};

    await tester.pumpWidget(_mapWithTileOverlays(prev));
    await tester.pumpWidget(_mapWithTileOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.tileOverlaysToChange, cur);
    expect(platformGoogleMap.tileOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.tileOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    TileOverlay t2 =
        const TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_2'));
    const TileOverlay t3 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_3'));
    final Set<TileOverlay> prev = <TileOverlay>{t2, t3};

    // t1 is added, t2 is updated, t3 is removed.
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    t2 = const TileOverlay(
        tileOverlayId: TileOverlayId('tile_overlay_2'), zIndex: 10);
    final Set<TileOverlay> cur = <TileOverlay>{t1, t2};

    await tester.pumpWidget(_mapWithTileOverlays(prev));
    await tester.pumpWidget(_mapWithTileOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.tileOverlaysToChange.length, 1);
    expect(platformGoogleMap.tileOverlaysToAdd.length, 1);
    expect(platformGoogleMap.tileOverlayIdsToRemove.length, 1);

    expect(platformGoogleMap.tileOverlaysToChange.first, equals(t2));
    expect(platformGoogleMap.tileOverlaysToAdd.first, equals(t1));
    expect(platformGoogleMap.tileOverlayIdsToRemove.first,
        equals(t3.tileOverlayId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    const TileOverlay t2 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_2'));
    TileOverlay t3 =
        const TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_3'));
    final Set<TileOverlay> prev = <TileOverlay>{t1, t2, t3};
    t3 = const TileOverlay(
        tileOverlayId: TileOverlayId('tile_overlay_3'), zIndex: 10);
    final Set<TileOverlay> cur = <TileOverlay>{t1, t2, t3};

    await tester.pumpWidget(_mapWithTileOverlays(prev));
    await tester.pumpWidget(_mapWithTileOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.tileOverlaysToChange, <TileOverlay>{t3});
    expect(platformGoogleMap.tileOverlayIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.tileOverlaysToAdd.isEmpty, true);
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
