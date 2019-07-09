// Copyright 2019 The HKTaxiApp Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Uniquely identifies a [MarkerRoute] among [GoogleMap] routes.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class MarkerRouteId {
  MarkerRouteId(this.value) : assert(value != null);

  /// value of the [MarkerRouteId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final MarkerRouteId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'MarkerRouteId{value: $value}';
  }
}

/// List of marker icon is drawn oriented against the device's screen rather
/// than the map's surface; that is, it will not necessarily change orientation
/// due to map rotations, tilting, or zooming.
@immutable
class MarkerRoute {
  /// Creates a set of route configuration options.
  ///
  /// Default route options.
  const MarkerRoute({
    @required this.routeId,
    this.markers,
  });

  /// Uniquely identifies a [MarkerRoute].
  final MarkerRouteId routeId;

  /// A list of markers.
  final List<Marker> markers;

  /// Creates a new [MarkerRoute] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  MarkerRoute copyWith({
    List<Marker> markersParam,
  }) {
    return MarkerRoute(
      routeId: routeId,
      markers: markersParam ?? markers,
    );
  }

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('routeId', routeId.value);
    addIfPresent('markers', markers.map<Map<String, dynamic>>((Marker m) => m._toJson()).toList());
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final MarkerRoute typedOther = other;
    return routeId == typedOther.routeId;
  }

  @override
  int get hashCode => routeId.hashCode;

  @override
  String toString() {
    return 'MarkerRoute{routeId: $routeId, markers: $markers';
  }
}

Map<MarkerRouteId, MarkerRoute> _keyByMarkerRouteId(Iterable<MarkerRoute> routes) {
  if (routes == null) {
    return <MarkerRouteId, MarkerRoute>{};
  }
  return Map<MarkerRouteId, MarkerRoute>.fromEntries(routes.map(
      (MarkerRoute route) => MapEntry<MarkerRouteId, MarkerRoute>(route.routeId, route)));
}

List<Map<String, dynamic>> _serializeMarkerRouteSet(Set<MarkerRoute> routes) {
  if (routes == null) {
    return null;
  }
  return routes.map<Map<String, dynamic>>((MarkerRoute m) => m._toJson()).toList();
}
