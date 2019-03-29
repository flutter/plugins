// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'google_map_inspector.dart';
import 'test_widgets.dart';

const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: LatLng(0, 0));

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);

  tearDownAll(() => allTestsCompleter.complete(null));

  test('testCompassToggle', () async {
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool compassEnabled = await inspector.isCompassEnabled();
    expect(compassEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    compassEnabled = await inspector.isCompassEnabled();
    expect(compassEnabled, true);
  });
}
