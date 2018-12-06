// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// returns val for low ≤ val ≤ high, low for val < low and high for val > high.
T clip<T extends num>(T val, T low, T high) {
  assert(low <= high);
  assert(val != null);
  val = null != low ? val = max(val, low) : val;
  return null != high ? val = min(val, high) : val;
}

/// returns val wrapped (folded) into the interval low ... high
T wrap<T extends num>(T val, T low, T high) {
  assert(low <= high);
  assert(val != null && low != null && high != null);
  final T range = high - low;
  return ((val - low) % range + range) % range + low;
}

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const LatLng(double latitude, double longitude)
      : assert(latitude != null),
        assert(longitude != null),
        latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  dynamic _toJson() {
    return <double>[latitude, longitude];
  }

  static LatLng _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  @override
  String toString() {
    return '$runtimeType[$latitude, $longitude]';
  }

  //Todo: Decide whether it is preferable to accept approximate equality.
  //Todo: find out what tolerances can be accepted.
  /// Comparison function. Two LatLngs pointing to the exact same
  /// coordinates are considered equal.
  @override
  bool operator ==(Object o) {
    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}

class _LatRange {
  _LatRange(this.south, this.north);

  double north;
  double south;

  double get center => (north + south) / 2;

  bool isEmpty() {
    return south > north;
  }

  bool intersects(_LatRange other) {
    return south <= other.south
        ? other.south <= north && other.south <= other.north
        : south <= other.north && south <= north;
  }

  bool contains(double lat) {
    return lat >= south && lat <= north;
  }

  _LatRange extend(double lat) {
    if (isEmpty())
      north = south = lat;
    else {
      if (lat < south)
        south = lat;
      else if (lat > north) north = lat;
    }
    return this;
  }
}

class _LngRange {
  _LngRange(double west, double east)
      : west = -180.0 == west && 180.0 != east ? 180.0 : west,
        east = -180.0 == east && 180.0 != west ? 180.0 : east;

  double west;
  double east;

  bool isEmpty() {
    return 360.0 == west - east;
  }

  bool intersects(_LngRange other) {
    return isEmpty() || other.isEmpty()
        ? false
        : spans180deg(this)
            ? spans180deg(other) || other.west <= east || other.east >= west
            : spans180deg(other)
                ? other.west <= east || other.east >= west
                : other.west <= east && other.east >= west;
  }

  _LngRange extend(double lng) {
    if (contains(lng)) return this;
    if (isEmpty())
      west = east = lng;
    else {
      if (distance(lng, west) < distance(east, lng))
        west = lng;
      else
        east = lng;
    }
    return this;
  }

  bool contains(double lng) {
    lng = -180.0 == lng ? 180.0 : lng;
    return spans180deg(this)
        ? (lng >= west || lng <= east) && !isEmpty()
        : lng >= west && lng <= east;
  }

  double get center {
    // _.n.W
    double center = (west + east) / 2;
    if (spans180deg(this)) center = wrap(center + 180.0, -180.0, 180.0);
    return center;
  }

  static double distance(double east, double west) {
    // _.Cc
    final double dist = west - east;
    return 0.0 <= dist ? dist : west + 180.0 - (east - 180.0);
  }

  static bool spans180deg(_LngRange a) {
    // _.Bc
    return a.west > a.east;
  }
}

/// A latitude/longitude aligned rectangle.
///
/// The rectangle conceptually includes all points (lat, lng) where
/// * lat ∈ [`southwest.latitude`, `northeast.latitude`]
/// * lng ∈ [`southwest.longitude`, `northeast.longitude`],
///   if `southwest.longitude` ≤ `northeast.longitude`,
/// * lng ∈ [-180, `northeast.longitude`] ∪ [`southwest.longitude`, 180[,
///   if `northeast.longitude` < `southwest.longitude`
class LatLngBounds {
  /// Constructs a rectangle from the points at its
  /// south-west and north-east corners.
  LatLngBounds({LatLng southwest, LatLng northeast}) {
    if (southwest != null || northeast != null) {
      if (southwest != null) northeast = northeast ??= southwest;
      if (southwest != null) southwest = southwest ??= northeast;

      final double south = clip(southwest.latitude, -90.0, 90.0);
      final double north = clip(northeast.latitude, -90.0, 90.0);
      assert(south <= north);
      _latRange = _LatRange(south, north);
      double west = southwest.longitude;
      double east = northeast.longitude;
      if (360.0 <= east - west) {
        _lngRange = _LngRange(-180.0, 180.0);
      } else {
        west = wrap(west, -180.0, 180.0);
        east = wrap(east, -180.0, 180.0);
        _lngRange = _LngRange(west, east);
      }
    } else {
      _latRange = _LatRange(1.0, -1.0);
      _lngRange = _LngRange(180.0, -180.0);
    }
  }

  /// the center of this LatLngBounds
  LatLng get center => LatLng(_latRange.center, _lngRange.center);

  /// Returns true if the given lat/lng is within this bounds.
  bool contains(LatLng point) {
    return _latRange.contains(point.latitude) &&
        _lngRange.contains(point.longitude);
  }

  /// Extends this bounds to contain the given point.
  LatLngBounds extend(LatLng a) {
    _latRange.extend(a.latitude);
    _lngRange.extend(a.longitude);
    return this;
  }

  /// Returns true if this bounds shares any points with the other bounds.
  bool intersects(LatLngBounds a) {
    return _latRange.intersects(a._latRange) &&
        _lngRange.intersects(a._lngRange);
  }

  /// Returns true if the bounds are empty.
  bool isEmpty() {
    return _latRange.isEmpty() || _lngRange.isEmpty();
  }

  /// Extends this bounds to contain the union of this and the given bounds.
  LatLngBounds union(LatLngBounds a) {
    if (a == null || a.isEmpty()) return this;
    extend(a.southWest);
    extend(a.northEast);
    return this;
  }

  /// The the north-east corner of this bounds.
  LatLng get northEast => LatLng(_latRange.north, _lngRange.east);

  /// The the north-west corner of this bounds.
  LatLng get northWest => LatLng(_latRange.north, _lngRange.west);

  /// The south-east corner of this bounds.
  LatLng get southEast => LatLng(_latRange.south, _lngRange.east);

  /// The south-west corner of this bounds.
  LatLng get southWest => LatLng(_latRange.south, _lngRange.west);

  /// The north latitude of this bounds.
  double get north => _latRange.north;

  /// The south latitude of this bounds.
  double get south => _latRange.south;

  /// the west longitude of this bounds.
  double get west => _lngRange.west;

  /// the east longitude of this bounds.
  double get east => _lngRange.east;

  _LatRange _latRange;
  _LngRange _lngRange;

  dynamic _toJson() {
    return <dynamic>[southWest._toJson(), northEast._toJson()];
  }

  static LatLngBounds _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: LatLng._fromJson(json[0]),
      northeast: LatLng._fromJson(json[1]),
    );
  }

  @override
  String toString() {
    return '$runtimeType[$southWest, $northEast]';
  }

  //Todo: implement js api behavior to accept approximate equality.
  //Todo: find out what tolerances are accepted.
  /// Returns true if this bounds exactly equals the given bounds.
  @override
  bool operator ==(Object o) {
    return o is LatLngBounds &&
        o.southWest == southWest &&
        o.northEast == northEast;
  }

  @override
  int get hashCode => hashValues(southWest, northEast);
}
