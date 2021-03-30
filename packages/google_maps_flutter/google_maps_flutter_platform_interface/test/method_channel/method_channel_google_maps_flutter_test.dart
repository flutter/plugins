// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/src/method_channel/method_channel_google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelGoogleMapsFlutter', () {
    late List<String> log;

    setUp(() async {
      log = <String>[];
    });

    /// Initializes a map with the given ID and canned responses, logging all
    /// calls to [log].
    void configureMockMap(
      MethodChannelGoogleMapsFlutter maps, {
      required int mapId,
      required Future<dynamic>? Function(MethodCall call) handler,
    }) {
      maps
          .ensureChannelInitialized(mapId)
          .setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall.method);
        return handler(methodCall);
      });
    }

    // Calls each method that uses invokeMethod with a return type other than
    // void to ensure that the casting/nullability handling succeeds.
    //
    // TODO(stuartmorgan): Remove this once there is real test coverage of
    // each method, since that would cover this issue.
    test('non-void invokeMethods handle types correctly', () async {
      const int mapId = 0;
      final MethodChannelGoogleMapsFlutter maps =
          MethodChannelGoogleMapsFlutter();
      configureMockMap(maps, mapId: mapId,
          handler: (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'map#getLatLng':
            return <dynamic>[1.0, 2.0];
          case 'markers#isInfoWindowShown':
            return true;
          case 'map#getZoomLevel':
            return 2.5;
          case 'map#takeSnapshot':
            return null;
        }
      });

      await maps.getLatLng(ScreenCoordinate(x: 0, y: 0), mapId: mapId);
      await maps.isMarkerInfoWindowShown(MarkerId(''), mapId: mapId);
      await maps.getZoomLevel(mapId: mapId);
      await maps.takeSnapshot(mapId: mapId);
      // Check that all the invokeMethod calls happened.
      expect(log, <String>[
        'map#getLatLng',
        'markers#isInfoWindowShown',
        'map#getZoomLevel',
        'map#takeSnapshot',
      ]);
    });
  });
}
