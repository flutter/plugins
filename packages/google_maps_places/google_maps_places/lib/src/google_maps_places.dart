// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_classes_with_only_static_members

part of google_maps_places;

/// App-facing presentation of [GoogleMapsPlacesPlatform]
class GoogleMapsPlaces {
  static final GoogleMapsPlacesPlatform _instance =
      GoogleMapsPlacesPlatform.instance;

  /// Fetches autocomplete predictions based on a query.
  ///
  /// [query] A query string containing the text typed by the user.
  ///
  /// [locationBias] Specifies [LatLngBounds] to constrain results to the
  /// specified region. Do not use with [locationRestriction].
  ///
  /// [locationRestriction] Specifies [LatLngBounds]  to avoid results from the
  /// specified region. Do not use with [locationBias].
  ///
  /// [origin] A [LatLng] specifying the location of origin for the request.
  ///
  /// [countries] One or more two-letter country codes (ISO 3166-1 Alpha-2),
  /// indicating the country or countries to which results should be restricted.
  ///
  /// [typeFilter] A [TypeFilter], which you can use to restrict the results to
  /// the specified place type.
  ///
  /// [refreshToken] is null of false, previously saved sessiontoken is used. If
  /// true, new sessiontoken is created. If previously saved sessiontoken is not
  /// available, new one is created automatically and saved.
  ///
  /// The returned [Future] completes after predictions query is finished.
  /// Returns list of [AutocompletePrediction].
  static Future<List<AutocompletePrediction>> findAutocompletePredictions({
    required String query,
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
    LatLng? origin,
    List<String>? countries,
    List<TypeFilter>? typeFilter,
    bool? refreshToken,
  }) async {
    return _instance.findAutocompletePredictions(
        query: query,
        countries: countries,
        origin: origin,
        locationBias: locationBias,
        locationRestriction: locationRestriction,
        typeFilter: typeFilter,
        refreshToken: refreshToken);
  }
}
