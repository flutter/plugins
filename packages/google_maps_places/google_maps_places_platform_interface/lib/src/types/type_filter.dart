// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents an which you can use to restrict the [AutoCompleteResult] results
/// to the specified place type.
///
/// ref:https://developers.google.com/maps/documentation/places/android-sdk/reference/com/google/android/libraries/places/api/model/TypeFilter
enum TypeFilter {
  /// Only return geocoding results with a precise address.
  address,

  /// Return any result matching the following place types:
  ///
  /// LOCALITY
  /// ADMINISTRATIVE_AREA_LEVEL_3
  cities,

  /// Only return results that are classified as businesses.
  establishment,

  /// Only return geocoding results, rather than business results. For example,
  /// parks, cities and street addresses.
  geocode,

  /// Return any result matching the following place types:
  ///
  /// LOCALITY
  /// SUBLOCALITY
  /// POSTAL_CODE
  /// COUNTRY
  /// ADMINISTRATIVE_AREA_LEVEL_1
  /// ADMINISTRATIVE_AREA_LEVEL_2
  regions,
}

/// Covnverts list of type filter values to something serializable in JSON
List<int>? typeFilterToJson(List<TypeFilter>? filters) => filters
    ?.map<int>((TypeFilter filter) => TypeFilter.values
        .firstWhere((TypeFilter element) => element.name == filter.name)
        .index)
    .toList();
