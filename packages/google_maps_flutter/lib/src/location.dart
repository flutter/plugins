// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude)
      : assert(latitude != null),
        assert(longitude != null);

  dynamic _toJson() {
    return <double>[latitude, longitude];
  }

  static LatLng _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return new LatLng(json[0], json[1]);
  }

  @override
  String toString() {
    return '$runtimeType[$latitude, $longitude]';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}

/// A latitude/longitude aligned rectangle.
class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;

  const LatLngBounds({@required this.southwest, @required this.northeast})
      : assert(southwest != null),
        assert(northeast != null);

  dynamic _toJson() {
    return <dynamic>[southwest._toJson(), northeast._toJson()];
  }

  static LatLngBounds _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return new LatLngBounds(
      southwest: LatLng._fromJson(json[0]),
      northeast: LatLng._fromJson(json[1]),
    );
  }

  @override
  String toString() {
    return '$runtimeType[$southwest, $northeast]';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLngBounds &&
        o.southwest == southwest &&
        o.northeast == northeast;
  }

  @override
  int get hashCode => hashValues(southwest, northeast);
}
