// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('android')
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_maps_controllers.dart';

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

  testWidgets('Can update liteModeEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          liteModeEnabled: false,
        ),
      ),
    );

    final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformGoogleMap.liteModeEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          liteModeEnabled: true,
        ),
      ),
    );

    expect(platformGoogleMap.liteModeEnabled, true);
  });
}
