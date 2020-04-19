// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

Widget _mapWithTileOverlays(List<TileOverlay> tileOverlays) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      tileOverlays: tileOverlays,
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

  testWidgets('Initializing a tile overlay', (WidgetTester tester) async {
    final TileOverlay t1 = TileOverlay(256, 256, 'abc.def');
    await tester.pumpWidget(_mapWithTileOverlays([t1]));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.tilesToAdd.length, 1);

    final TileOverlay tileOverlay = platformGoogleMap.tilesToAdd.first;
    expect(tileOverlay, equals(tileOverlay));
    expect(platformGoogleMap.tilesToRemove.isEmpty, true);
    expect(platformGoogleMap.tilesToChange.isEmpty, true);
  });

  testWidgets("Adding a tile overlay", (WidgetTester tester) async {
    final TileOverlay t1 = TileOverlay(256, 256, 'abc.def');
    final TileOverlay t2 = TileOverlay(512, 512, 'def.abc');

    await tester.pumpWidget(_mapWithTileOverlays([t1]));
    await tester.pumpWidget(_mapWithTileOverlays([t1, t2]));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.tilesToAdd.length, 1);

    final TileOverlay addedTileOverlay = platformGoogleMap.tilesToAdd.first;
    expect(addedTileOverlay, equals(t2));

    expect(platformGoogleMap.tilesToRemove.isEmpty, true);
    expect(platformGoogleMap.tilesToChange.isEmpty, true);
  });

  testWidgets("Removing a tile overlay", (WidgetTester tester) async {
    final TileOverlay t1 = TileOverlay(256, 256, 'abc.def');

    await tester.pumpWidget(_mapWithTileOverlays([t1]));
    await tester.pumpWidget(_mapWithTileOverlays([]));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.tilesToRemove.length, 1);
    expect(platformGoogleMap.tilesToRemove.first, equals(t1));

    expect(platformGoogleMap.tilesToChange.isEmpty, true);
    expect(platformGoogleMap.tilesToAdd.isEmpty, true);
  });

  testWidgets("Updating a tile overlay", (WidgetTester tester) async {
    final TileOverlay t1 = TileOverlay(256, 256, 'abc.def');
    final TileOverlay t2 = TileOverlay(256, 256, 'abc.def', isVisible: false);

    await tester.pumpWidget(_mapWithTileOverlays([t1]));
    await tester.pumpWidget(_mapWithTileOverlays([t2]));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
    expect(platformGoogleMap.tilesToChange.length, 1);
    expect(platformGoogleMap.tilesToChange.first, equals(t2));

    expect(platformGoogleMap.tilesToRemove.isEmpty, true);
    expect(platformGoogleMap.tilesToAdd.isEmpty, true);
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    TileOverlay t1 = TileOverlay(256, 256, 'abc.def');
    TileOverlay t2 = TileOverlay(256, 256, 'def.abc');

    final List<TileOverlay> prev = [t1, t2];
    t1 = TileOverlay(256, 256, 'abc.def', isVisible: false);
    t2 = TileOverlay(256, 256, 'def.abc', isVisible: false);
    final List<TileOverlay> cur = [t1, t2];

    await tester.pumpWidget(_mapWithTileOverlays(prev));
    await tester.pumpWidget(_mapWithTileOverlays(cur));

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.tilesToChange, cur);
    expect(platformGoogleMap.tilesToRemove.isEmpty, true);
    expect(platformGoogleMap.tilesToAdd.isEmpty, true);
  });
}