// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_places_ios/google_maps_places_ios.dart';
import 'package:google_maps_places_ios/src/messages.g.dart';
import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('converts', () {
    test('convertsLatLng', () async {
      final LatLngIOS? converted = convertLatLng(mockOrigin);
      expect(converted, isNotNull);
      expect(converted?.latitude, equals(mockOrigin.latitude));
      expect(converted?.longitude, equals(mockOrigin.longitude));

      expect(convertLatLng(null), isNull);
    });
    test('convertsLatLngBounds', () async {
      final LatLngBoundsIOS? converted = convertLatLngBounds(mockLocationBias);
      expect(converted, isNotNull);
      expect(converted?.northeast?.latitude,
          equals(mockLocationBias.northeast.latitude));
      expect(converted?.northeast?.longitude,
          equals(mockLocationBias.northeast.longitude));
      expect(converted?.southwest?.latitude,
          equals(mockLocationBias.southwest.latitude));
      expect(converted?.southwest?.longitude,
          equals(mockLocationBias.southwest.longitude));

      expect(convertLatLng(null), isNull);
    });
    test('convertsTypeFilter', () async {
      for (int i = 0; i < TypeFilter.values.length; i++) {
        final List<int>? converted =
            convertTypeFilter(<TypeFilter>[TypeFilter.values[i]]);
        expect(converted, isNotNull);
        expect(converted?.length, equals(1));
        expect(TypeFilterIOS.values[converted![0]].name,
            equals(TypeFilter.values[i].name));
      }
      expect(convertTypeFilter(null), isNull);
    });
    test('convertsPlaceTypes', () async {
      for (int i = 0; i < PlaceTypeIOS.values.length; i++) {
        final List<PlaceType> converted = convertPlaceTypes(<int?>[i]);
        expect(converted.length, equals(1));
        expect(converted[0].name, equals(PlaceTypeIOS.values[i].name));
      }
    });
    test('convertsPrediction', () async {
      final AutocompletePrediction converted =
          convertPrediction(mockPrediction);
      expect(converted.distanceMeters, mockPrediction.distanceMeters);
      expect(converted.fullText, mockPrediction.fullText);
      expect(converted.placeId, mockPrediction.placeId);
      expect(converted.placeTypes.length, mockPrediction.placeTypes.length);
      expect(converted.primaryText, mockPrediction.primaryText);
      expect(converted.secondaryText, mockPrediction.secondaryText);
    });
    test('convertsReponse', () async {
      final List<AutocompletePrediction> converted =
          convertReponse(<AutocompletePredictionIOS>[mockPrediction]);
      expect(converted.length, equals(1));
    });
  });
}
