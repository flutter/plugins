// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$GoogleMapsPlacesPlatform', () {
    test('$GoogleMapsPlacesMethodChannel() is the default instance', () {
      expect(GoogleMapsPlacesPlatform.instance,
          isInstanceOf<GoogleMapsPlacesMethodChannel>());
    });

    test('Can be extended', () {
      GoogleMapsPlacesPlatform.instance = ExtendsGoogleMapsPlacesPlatform();
    });
  });

  group('#findAutocompletePredictions', () {
    test('Should throw unimplemented exception', () async {
      final GoogleMapsPlacesPlatform platform =
          ExtendsGoogleMapsPlacesPlatform();

      await expectLater(() async {
        return platform.findAutocompletePredictions(query: 'Query');
      }, throwsA(isA<UnimplementedError>()));
    });
  });
}

class ExtendsGoogleMapsPlacesPlatform extends GoogleMapsPlacesPlatform {}
