// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_places_ios;

/// An implementation of [GoogleMapsPlacesPlatform] for IOS.
class GoogleMapsPlacesIOS extends GoogleMapsPlacesPlatform {
  final GoogleMapsPlacesApiIOS _api = GoogleMapsPlacesApiIOS();

  /// Registers this class as the default platform implementation.
  static void registerWith() {
    GoogleMapsPlacesPlatform.instance = GoogleMapsPlacesIOS();
  }

  @override
  Future<List<AutocompletePrediction>> findAutocompletePredictions({
    required String query,
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
    LatLng? origin,
    List<String>? countries,
    List<TypeFilter>? typeFilter,
    bool? refreshToken,
  }) async {
    // Only one type filter is accepted at the moment.
    assert(typeFilter == null || typeFilter.length <= 1);
    // Only either locationBias or locationRestriction is allowed.
    assert(locationBias == null || locationRestriction == null);
    final List<AutocompletePredictionIOS?>? response =
        await _api.findAutocompletePredictionsIOS(
            query,
            convertLatLngBounds(locationBias),
            convertLatLngBounds(locationRestriction),
            convertLatLng(origin),
            countries,
            convertTypeFilter(typeFilter),
            refreshToken);
    if (response == null) {
      throw ArgumentError(
          'API returned empty response. Check log for details.');
    }
    return convertReponse(response);
  }
}
