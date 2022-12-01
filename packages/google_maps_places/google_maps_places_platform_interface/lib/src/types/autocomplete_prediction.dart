// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart'
    show immutable, visibleForTesting, objectRuntimeType;

import 'place_type.dart';

/// Represents an autocomplete suggestion of a place, based on a particular text query.
///
/// ref: https://developers.google.com/maps/documentation/places/android-sdk/reference/com/google/android/libraries/places/api/model/AutocompletePrediction
@immutable
class AutocompletePrediction {
  /// Creates new represation of [AutocompletePrediction].
  const AutocompletePrediction({
    this.distanceMeters,
    required this.fullText,
    required this.placeId,
    required this.placeTypes,
    required this.primaryText,
    required this.secondaryText,
  });

  /// The straight line distance in meters between the origin and this prediction
  /// if a valid origin is in the request.
  final int? distanceMeters;

  /// The full description of the prediction as string.
  final String fullText;

  /// A property representing the place ID of the prediction, suitable for use
  /// in a place details request.
  final String placeId;

  /// The list of place types associated with this place.
  final List<PlaceType> placeTypes;

  /// The main text of a prediction as a String, usually the name of the place.
  final String primaryText;

  /// The secondary text of a prediction as a String, usually the location of the place.
  final String secondaryText;

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<Object?, Object?> map = <Object?, Object?>{};
    map['distanceMeters'] = distanceMeters;
    map['fullText'] = fullText;
    map['placeId'] = placeId;
    map['placeTypes'] = placeTypes;
    map['primaryText'] = primaryText;
    map['secondaryText'] = secondaryText;
    return map;
  }

  /// Converts a data to [AutocompletePrediction].
  static AutocompletePrediction fromJson(Object json) {
    final Map<Object?, Object?> map = json as Map<Object?, Object?>;
    return AutocompletePrediction(
      distanceMeters: map['distanceMeters'] as int?,
      fullText: map['fullText']! as String,
      placeId: map['placeId']! as String,
      placeTypes: convertPlaceTypes(
          (map['placeTypes'] as List<Object?>?)!.cast<int?>()),
      primaryText: map['primaryText']! as String,
      secondaryText: map['secondaryText']! as String,
    );
  }

  /// Converts list [int] to list of [PlaceType].
  @visibleForTesting
  static List<PlaceType> convertPlaceTypes(List<int?> placeTypes) => placeTypes
      .map<PlaceType>((int? placeType) => PlaceType.values.firstWhere(
          (PlaceType element) =>
              element.name == PlaceType.values[placeType!].name))
      .toList();

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AutocompletePrediction')}(distanceMeters:  '
      ' $distanceMeters, fullText: $fullText, placeId $placeId, placeTypes  '
      '$placeTypes, primaryText: $primaryText, secondaryText: $secondaryText)';

  @override
  bool operator ==(Object other) =>
      other is AutocompletePrediction &&
      distanceMeters == other.distanceMeters &&
      fullText == other.fullText &&
      placeId == other.placeId &&
      placeTypes == other.placeTypes &&
      primaryText == other.primaryText &&
      secondaryText == other.secondaryText;

  @override
  int get hashCode => Object.hash(distanceMeters, fullText, placeId, placeTypes,
      primaryText, secondaryText);
}
