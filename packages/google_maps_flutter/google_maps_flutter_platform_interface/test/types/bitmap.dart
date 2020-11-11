// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$BitmapDescriptor', () {
    test('toJson / fromJson', () {
      final descriptor =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      final json = descriptor.toJson();

      // Rehydrate a new bitmap descriptor...
      final descriptorFromJson = BitmapDescriptor.fromJson(json);

      expect(descriptorFromJson, isNot(descriptor)); // New instance
      expect(identical(descriptorFromJson.toJson(), json), isTrue); // Same JSON
    });
  });
}
