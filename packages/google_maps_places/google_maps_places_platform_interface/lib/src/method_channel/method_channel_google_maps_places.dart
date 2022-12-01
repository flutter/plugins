// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import '../../google_maps_places_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/google_maps_places');

/// The default interface implementation acting as a placeholder for
/// the native implementation to be set.
///
/// This implementation is not used by any of the implementations in this
/// repository, and exists only for backward compatibility with any
/// clients that were relying on internal details of the method channel
/// in the pre-federated plugin.
class GoogleMapsPlacesMethodChannel extends GoogleMapsPlacesPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<List<AutocompletePrediction>> findAutocompletePredictions({
    required String query,
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
    LatLng? origin,
    List<String?>? countries,
    List<TypeFilter>? typeFilter,
    bool? refreshToken,
  }) async {
    // This assert can be removed when multiple typefilters are working properly.
    assert(typeFilter == null || typeFilter.length <= 1);
    // Only either locationBias or locationRestriction is allowed.
    assert(locationBias == null || locationRestriction == null);
    final List<Map<Object?, Object?>>? result =
        await _channel.invokeListMethod<Map<Object?, Object?>>(
      'findAutocompletePredictions',
      <String, Object?>{
        'query': query,
        'countries': countries,
        'typeFilter': typeFilterToJson(typeFilter),
        'origin': origin?.toJson(),
        'locationBias': locationBias?.toJson(),
        'locationRestriction': locationRestriction?.toJson(),
        'refreshToken': refreshToken
      },
    );
    final List<AutocompletePrediction> items = result
            ?.map((Map<Object?, Object?> item) => item.cast<String, dynamic>())
            .map((Map<String, dynamic> map) =>
                AutocompletePrediction.fromJson(map))
            .toList(growable: false) ??
        <AutocompletePrediction>[];
    return items;
  }
}
