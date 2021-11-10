// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanLng constructor', () {
    test('Maintains longitude precision if within acceptable range', () async {
      const lat = -34.509981;
      const lng = 150.792384;

      final latLng = LatLng(lat, lng);

      expect(latLng.latitude, equals(lat));
      expect(latLng.longitude, equals(lng));
    });

    test('Normalizes longitude that is below lower limit', () async {
      const lat = -34.509981;
      const lng = -270.0;

      final latLng = LatLng(lat, lng);

      expect(latLng.latitude, equals(lat));
      expect(latLng.longitude, equals(90.0));
    });

    test('Normalizes longitude that is above upper limit', () async {
      const lat = -34.509981;
      const lng = 270.0;

      final latLng = LatLng(lat, lng);

      expect(latLng.latitude, equals(lat));
      expect(latLng.longitude, equals(-90.0));
    });

    test('Includes longitude set to lower limit', () async {
      const lat = -34.509981;
      const lng = -180.0;

      final latLng = LatLng(lat, lng);

      expect(latLng.latitude, equals(lat));
      expect(latLng.longitude, equals(-180.0));
    });

    test('Normalizes longitude set to upper limit', () async {
      const lat = -34.509981;
      const lng = 180.0;

      final latLng = LatLng(lat, lng);

      expect(latLng.latitude, equals(lat));
      expect(latLng.longitude, equals(-180.0));
    });
  });
}
