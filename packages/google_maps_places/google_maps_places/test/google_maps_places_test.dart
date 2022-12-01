// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeGoogleMapsPlaces fakePlatformImplementation;

  setUp(() {
    fakePlatformImplementation = FakeGoogleMapsPlaces();
    GoogleMapsPlacesPlatform.instance = fakePlatformImplementation;
  });

  group('findAutocompletePredictions', () {
    const List<AutocompletePrediction> expectedResults =
        <AutocompletePrediction>[mockPrediction];

    test('works with required values', () async {
      fakePlatformImplementation
        ..setExpectations(query: mockQuery)
        ..setAutocompleteResponse(expectedResults);

      final List<AutocompletePrediction> results =
          await fakePlatformImplementation.findAutocompletePredictions(
        query: mockQuery,
      );

      expect(results, expectedResults);
    });

    test('works with optional values including location bias', () async {
      fakePlatformImplementation
        ..setExpectations(
            query: mockQuery,
            locationBias: mockLocationBias,
            origin: mockOrigin,
            countries: mockCountries,
            typeFilter: mockTypeFilters)
        ..setAutocompleteResponse(expectedResults);

      final List<AutocompletePrediction> results =
          await fakePlatformImplementation.findAutocompletePredictions(
              query: mockQuery,
              locationBias: mockLocationBias,
              origin: mockOrigin,
              countries: mockCountries,
              typeFilter: mockTypeFilters);

      expect(results, expectedResults);
    });
    test('works with optional values including location restriction', () async {
      fakePlatformImplementation
        ..setExpectations(
            query: mockQuery,
            locationRestriction: mockLocationRestriction,
            origin: mockOrigin,
            countries: mockCountries,
            typeFilter: mockTypeFilters,
            refreshToken: true)
        ..setAutocompleteResponse(expectedResults);

      final List<AutocompletePrediction> results =
          await fakePlatformImplementation.findAutocompletePredictions(
              query: mockQuery,
              locationRestriction: mockLocationRestriction,
              origin: mockOrigin,
              countries: mockCountries,
              typeFilter: mockTypeFilters,
              refreshToken: true);

      expect(results, expectedResults);
    });
  });
}

class FakeGoogleMapsPlaces extends Fake
    with MockPlatformInterfaceMixin
    implements GoogleMapsPlacesPlatform {
  // Expectations.
  String query = '';
  LatLngBounds? locationBias;
  LatLngBounds? locationRestriction;
  LatLng? origin;
  List<String>? countries;
  List<TypeFilter>? typeFilter;
  bool? refreshToken;
  // Return values.
  List<AutocompletePrediction> results = <AutocompletePrediction>[];

  void setExpectations({
    String query = '',
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
    LatLng? origin,
    List<String>? countries,
    List<TypeFilter>? typeFilter,
    bool? refreshToken,
  }) {
    this.query = query;
    this.locationBias = locationBias;
    this.locationRestriction = locationRestriction;
    this.origin = origin;
    this.countries = countries;
    this.typeFilter = typeFilter;
    this.refreshToken = refreshToken;
  }

  // ignore: use_setters_to_change_properties
  void setAutocompleteResponse(List<AutocompletePrediction> results) {
    this.results = results;
  }

  @override
  Future<List<AutocompletePrediction>> findAutocompletePredictions(
      {String? query,
      LatLngBounds? locationBias,
      LatLngBounds? locationRestriction,
      LatLng? origin,
      List<String>? countries,
      List<TypeFilter>? typeFilter,
      bool? refreshToken}) async {
    expect(query, this.query);
    expect(locationBias, this.locationBias);
    expect(locationRestriction, locationRestriction);
    expect(origin, origin);
    expect(countries, countries);
    expect(typeFilter, typeFilter);
    expect(refreshToken, refreshToken);
    return results;
  }
}
