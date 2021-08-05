// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toMap / fromMap', () {
    const cameraPosition = CameraPosition(
        target: LatLng(10.0, 15.0), bearing: 0.5, tilt: 30.0, zoom: 1.5);
    // Cast to <dynamic, dynamic> to ensure that recreating from JSON, where
    // type information will have likely been lost, still works.
    final json = (cameraPosition.toMap() as Map<String, dynamic>)
        .cast<dynamic, dynamic>();
    final cameraPositionFromJson = CameraPosition.fromMap(json);

    expect(cameraPosition, cameraPositionFromJson);
  });
}
