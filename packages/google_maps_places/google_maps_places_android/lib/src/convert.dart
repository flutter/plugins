// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_places_android;

/// Converts [LatLng] to [LatLngAndroid].
///
/// Returns [null] if [latLng] is [null].
LatLngAndroid? convertLatLng(LatLng? latLng) {
  if (latLng == null) {
    return null;
  }
  return LatLngAndroid(latitude: latLng.latitude, longitude: latLng.longitude);
}

/// Converts [LatLngBounds] to [LatLngBoundsAndroid].
///
/// Returns [null] if [bounds] is [null].
LatLngBoundsAndroid? convertLatLngBounds(LatLngBounds? bounds) {
  if (bounds == null) {
    return null;
  }
  return LatLngBoundsAndroid(
      northeast: convertLatLng(bounds.northeast),
      southwest: convertLatLng(bounds.southwest));
}

/// Converts list of [TypeFilter] to list of [int].
///
/// Returns [null] if [filters] is [null].
List<int>? convertTypeFilter(List<TypeFilter>? filters) => filters
    ?.map<int>((TypeFilter filter) => TypeFilterAndroid.values
        .firstWhere((TypeFilterAndroid element) => element.name == filter.name)
        .index)
    .toList();

/// Converts list of [int] to list of [PlaceType].
List<PlaceType> convertPlaceTypes(List<int?> placeTypes) => placeTypes
    .map<PlaceType>((int? placeType) => PlaceType.values.firstWhere(
        (PlaceType element) =>
            element.name == PlaceTypeAndroid.values[placeType!].name))
    .toList();

/// Converts [AutocompletePredictionAndroid] to [AutocompletePrediction].
AutocompletePrediction convertPrediction(
    AutocompletePredictionAndroid prediction) {
  return AutocompletePrediction(
      distanceMeters: prediction.distanceMeters,
      fullText: prediction.fullText,
      placeId: prediction.placeId,
      placeTypes: convertPlaceTypes(prediction.placeTypes),
      primaryText: prediction.primaryText,
      secondaryText: prediction.secondaryText);
}

/// Converts list of [AutocompletePredictionAndroid] to list of [AutocompletePrediction].
List<AutocompletePrediction> convertReponse(
    List<AutocompletePredictionAndroid?> results) {
  return results
      .map((AutocompletePredictionAndroid? e) => convertPrediction(e!))
      .toList();
}
