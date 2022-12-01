// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';

const String mockQuery = 'Koulu';

const LatLng mockOrigin = LatLng(65.0121, 25.4651);

final LatLngBounds mockLocationBias = LatLngBounds(
  southwest: const LatLng(60.4518, 22.2666),
  northeast: const LatLng(70.0821, 27.8718),
);

final LatLngBounds mockLocationRestriction = LatLngBounds(
  southwest: const LatLng(63.4518, 23.2666),
  northeast: const LatLng(67.0821, 26.8718),
);

const List<String> mockCountries = <String>['fi'];

const List<TypeFilter> mockTypeFilters = <TypeFilter>[TypeFilter.address];

const AutocompletePrediction mockPrediction = AutocompletePrediction(
    distanceMeters: 200,
    fullText: 'Koulukatu, Tampere, Finland, placeId',
    placeId:
        'EhtLb3VsdWthdHUsIFRhbXBlcmUsIEZpbmxhbmQiLiosChQKEgmNKrw3sNiORhGUm8jmSvlI4RIUChIJVVwAnVEkj0YRhhoEA3s-vUQ',
    placeTypes: <PlaceType>[PlaceType.route, PlaceType.geocode],
    primaryText: 'Koulukatu',
    secondaryText: 'Tampere, Finland');
