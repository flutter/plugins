// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_places_android/google_maps_places_android.dart';
import 'package:google_maps_places_android/src/messages.g.dart';
import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_maps_places_android_test.mocks.dart';

import 'messages_test.g.dart';
import 'mocks.dart';

@GenerateMocks(<Type>[TestGoogleMapsPlacesApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsPlacesAndroid plugin = GoogleMapsPlacesAndroid();
  late MockTestGoogleMapsPlacesApi mockApi;

  setUp(() {
    mockApi = MockTestGoogleMapsPlacesApi();
    TestGoogleMapsPlacesApi.setup(mockApi);
  });

  test('registers instance', () async {
    GoogleMapsPlacesAndroid.registerWith();
    expect(GoogleMapsPlacesPlatform.instance, isA<GoogleMapsPlacesAndroid>());
  });

  group('findAutocompletePredictionsAndroid', () {
    setUp(() {
      when(mockApi.findAutocompletePredictionsAndroid(
              any, any, any, any, any, any, any))
          .thenAnswer((Invocation _) async =>
              Future<List<AutocompletePredictionAndroid?>>.value(
                  <AutocompletePredictionAndroid>[mockPrediction]));
    });

    test('passes the required values', () async {
      await plugin.findAutocompletePredictions(query: mockQuery);
      final VerificationResult result = verify(
          mockApi.findAutocompletePredictionsAndroid(captureAny, captureAny,
              captureAny, captureAny, captureAny, captureAny, captureAny));
      expect(result.captured[0], mockQuery);
      expect(result.captured[1], isNull);
      expect(result.captured[2], isNull);
      expect(result.captured[3], isNull);
      expect(result.captured[4], isNull);
      expect(result.captured[5], isNull);
      expect(result.captured[6], isNull);
    });

    test('passes the optional parameters with location bias', () async {
      await plugin.findAutocompletePredictions(
          query: mockQuery,
          locationBias: mockLocationBias,
          origin: mockOrigin,
          countries: mockCountries,
          typeFilter: mockTypeFilters);
      final VerificationResult result = verify(
          mockApi.findAutocompletePredictionsAndroid(captureAny, captureAny,
              captureAny, captureAny, captureAny, captureAny, captureAny));
      expect(result.captured[0], mockQuery);
      final LatLngBoundsAndroid locationBias =
          result.captured[1] as LatLngBoundsAndroid;
      expect(locationBias, isNotNull);
      expect(locationBias.northeast, isNotNull);
      expect(locationBias.southwest, isNotNull);
      expect(locationBias.northeast!.latitude,
          mockLocationBias.northeast.latitude);
      expect(locationBias.northeast!.longitude,
          mockLocationBias.northeast.longitude);
      expect(locationBias.southwest!.latitude,
          mockLocationBias.southwest.latitude);
      expect(locationBias.southwest!.longitude,
          mockLocationBias.southwest.longitude);
      expect(result.captured[2], isNull);
      final LatLngAndroid origin = result.captured[3] as LatLngAndroid;
      expect(origin, isNotNull);
      expect(origin.latitude, mockOrigin.latitude);
      expect(origin.longitude, mockOrigin.longitude);
      final List<String?> countries = result.captured[4] as List<String?>;
      expect(result.captured[4], isNotNull);
      expect(countries.length, mockCountries.length);
      expect(countries.first, mockCountries.first);
      final List<int?> typeFilters = result.captured[5] as List<int?>;
      expect(typeFilters, isNotNull);
      expect(typeFilters.length, mockTypeFilters.length);
      expect(
          typeFilters.first,
          TypeFilterAndroid.values
              .firstWhere((TypeFilterAndroid element) =>
                  element.name == mockTypeFilters.first.name)
              .index);
      expect(result.captured[6], isNull);
    });

    test('passes the optional parameters with location restriction', () async {
      await plugin.findAutocompletePredictions(
          query: mockQuery,
          locationRestriction: mockLocationRestriction,
          origin: mockOrigin,
          countries: mockCountries,
          typeFilter: mockTypeFilters,
          refreshToken: true);
      final VerificationResult result = verify(
          mockApi.findAutocompletePredictionsAndroid(captureAny, captureAny,
              captureAny, captureAny, captureAny, captureAny, captureAny));
      expect(result.captured[0], mockQuery);
      expect(result.captured[1], isNull);
      final LatLngBoundsAndroid locationRestriction =
          result.captured[2] as LatLngBoundsAndroid;
      expect(locationRestriction, isNotNull);
      expect(locationRestriction.northeast, isNotNull);
      expect(locationRestriction.southwest, isNotNull);
      expect(locationRestriction.northeast!.latitude,
          mockLocationRestriction.northeast.latitude);
      expect(locationRestriction.northeast!.longitude,
          mockLocationRestriction.northeast.longitude);
      expect(locationRestriction.southwest!.latitude,
          mockLocationRestriction.southwest.latitude);
      expect(locationRestriction.southwest!.longitude,
          mockLocationRestriction.southwest.longitude);
      final LatLngAndroid origin = result.captured[3] as LatLngAndroid;
      expect(origin, isNotNull);
      expect(origin.latitude, mockOrigin.latitude);
      expect(origin.longitude, mockOrigin.longitude);
      final List<String?> countries = result.captured[4] as List<String?>;
      expect(result.captured[4], isNotNull);
      expect(countries.length, mockCountries.length);
      expect(countries.first, mockCountries.first);
      final List<int?> typeFilters = result.captured[5] as List<int?>;
      expect(typeFilters, isNotNull);
      expect(typeFilters.length, mockTypeFilters.length);
      expect(
          typeFilters.first,
          TypeFilterAndroid.values
              .firstWhere((TypeFilterAndroid element) =>
                  element.name == mockTypeFilters.first.name)
              .index);
      expect(result.captured[6], true);
    });

    test('throws for location bias and restriction', () async {
      await expectLater(
          plugin.findAutocompletePredictions(
              query: mockQuery,
              locationBias: mockLocationBias,
              locationRestriction: mockLocationRestriction),
          throwsAssertionError);
    });

    test('throws for multiple typefilters', () async {
      await expectLater(
          plugin.findAutocompletePredictions(
              query: mockQuery,
              typeFilter: <TypeFilter>[TypeFilter.address, TypeFilter.cities]),
          throwsAssertionError);
    });
  });
}
