// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';

class MockGoogleMapsFlutterPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = MockGoogleMapsFlutterPlatform();

  setUp(() {
    // Use a mock platform so we never need to hit the MethodChannel code.
    GoogleMapsFlutterPlatform.instance = platform;
    when(platform.buildView(any, any, any)).thenReturn(Container());
  });

  testWidgets('_webOnlyMapCreationId increments with each GoogleMap widget', (
    WidgetTester tester,
  ) async {
    // Inject two map widgets...
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: const [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(43.362, -5.849),
              ),
            ),
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(47.649, -122.350),
              ),
            ),
          ],
        ),
      ),
    );

    // Verify that each one was created with a different _webOnlyMapCreationId.
    verifyInOrder([
      platform.buildView(
        argThat(containsPair('_webOnlyMapCreationId', 0)),
        any,
        any,
      ),
      platform.buildView(
        argThat(containsPair('_webOnlyMapCreationId', 1)),
        any,
        any,
      ),
    ]);
  });
}
