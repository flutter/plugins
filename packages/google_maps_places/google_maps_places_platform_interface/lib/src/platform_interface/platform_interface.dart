// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../method_channel/method_channel_google_maps_places.dart';
import '../types/types.dart';

/// The interface that implementations of google_maps_platform must implement.
///
/// Platform implementations should extend this class rather than implement it as `google_maps_places`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [GoogleMapsPlacesPlatform] methods.
abstract class GoogleMapsPlacesPlatform extends PlatformInterface {
  /// Constructs a GoogleMapsPlacesPlatform.
  GoogleMapsPlacesPlatform() : super(token: _token);

  static final Object _token = Object();

  static GoogleMapsPlacesPlatform _instance = GoogleMapsPlacesMethodChannel();

  /// The instance of [GoogleMapsPlacesPlatform] to use.
  ///
  /// Defaults to a placeholder that does not override any methods, and thus
  /// throws `UnimplementedError` in most cases.
  static GoogleMapsPlacesPlatform get instance => _instance;

  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [GoogleMapsPlacesPlatform] when they
  /// register themselves.
  static set instance(GoogleMapsPlacesPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

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
  /// [typeFilter] List of [TypeFilter], which is used to restrict the results to
  /// the specified place type.
  ///
  /// [refreshToken] is null of false, previously saved sessiontoken is used. If
  /// true, new sessiontoken is created. If previously saved sessiontoken is not
  /// available, new one is created automatically and saved.
  ///
  /// The returned [Future] completes after predictions query is finished.
  /// Returns list of [AutocompletePrediction].
  ///
  /// ref: https://developers.google.com/maps/documentation/places/android-sdk/autocomplete
  Future<List<AutocompletePrediction>> findAutocompletePredictions({
    required String query,
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
    LatLng? origin,
    List<String>? countries,
    List<TypeFilter>? typeFilter,
    bool? refreshToken,
  }) async {
    throw UnimplementedError(
        'findAutocompletePredictions() has not been implemented.');
  }
}
