// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// An icon placed at a particular point on the map's surface. A marker icon is
/// drawn oriented against the device's screen rather than the map's surface;
/// that is, it will not necessarily change orientation due to map rotations,
/// tilting, or zooming.
///
/// Markers are owned by a single [GoogleMapController] which fires change
/// events when markers are added, updated, or removed.
class Marker {
  Marker._(this._mapController, this.id, this._options);

  final GoogleMapController _mapController;
  final String id;
  MarkerOptions _options;

  Future<void> remove() {
    return _mapController._removeMarker(this);
  }

  Future<void> update(MarkerOptions changes) {
    return _mapController._updateMarker(this, changes);
  }

  /// The configuration options most recently applied programmatically.
  ///
  /// The returned value does not reflect any changes made to the marker through
  /// touch events. Add listeners to track those.
  MarkerOptions get options => _options;
}

dynamic _offsetToJson(Offset offset) =>
    offset == null ? null : <dynamic>[offset.dx, offset.dy];

/// Text labels for a [Marker] info window.
class InfoWindowText {
  const InfoWindowText(this.title, this.snippet);

  static const InfoWindowText noText = const InfoWindowText(null, null);

  final String title;
  final String snippet;

  dynamic _toJson() => <dynamic>[title, snippet];
}

/// Configuration options for [Marker] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration item". When used to represent current
/// configuration, all values will be non-null.
class MarkerOptions {
  final double alpha;
  final Offset anchor;
  final bool consumesTapEvents;
  final bool draggable;
  final bool flat;
  final BitmapDescriptor icon;
  final Offset infoWindowAnchor;
  final bool infoWindowShown;
  final InfoWindowText infoWindowText;
  final LatLng position;
  final double rotation;
  final bool visible;
  final double zIndex;

  const MarkerOptions({
    this.alpha,
    this.anchor,
    this.consumesTapEvents,
    this.draggable,
    this.flat,
    this.icon,
    this.infoWindowAnchor,
    this.infoWindowShown,
    this.infoWindowText,
    this.position,
    this.rotation,
    this.visible,
    this.zIndex,
  });

  static const MarkerOptions defaultOptions = const MarkerOptions(
    alpha: 1.0,
    anchor: const Offset(0.5, 1.0),
    consumesTapEvents: false,
    draggable: false,
    flat: false,
    icon: BitmapDescriptor.defaultMarker,
    infoWindowAnchor: const Offset(0.5, 0.0),
    infoWindowShown: false,
    infoWindowText: InfoWindowText.noText,
    rotation: 0.0,
    visible: true,
    zIndex: 0.0,
  );

  MarkerOptions _updateWith(MarkerOptions changes) {
    return new MarkerOptions(
      alpha: changes.alpha ?? alpha,
      anchor: changes.anchor ?? anchor,
      consumesTapEvents: changes.consumesTapEvents ?? consumesTapEvents,
      draggable: changes.draggable ?? draggable,
      flat: changes.flat ?? flat,
      icon: changes.icon ?? icon,
      infoWindowAnchor: changes.infoWindowAnchor ?? infoWindowAnchor,
      infoWindowShown: changes.infoWindowShown ?? infoWindowShown,
      infoWindowText: changes.infoWindowText ?? infoWindowText,
      position: changes.position ?? position,
      rotation: changes.rotation ?? rotation,
      visible: changes.visible ?? visible,
      zIndex: changes.zIndex ?? zIndex,
    );
  }

  dynamic _toJson() {
    return <String, dynamic>{
      'alpha': alpha,
      'anchor': _offsetToJson(anchor),
      'consumesTapEvents': consumesTapEvents,
      'draggable': draggable,
      'flat': flat,
      'icon': icon?._toJson(),
      'infoWindowAnchor': _offsetToJson(infoWindowAnchor),
      'infoWindowShown': infoWindowShown,
      'infoWindowText': infoWindowText?._toJson(),
      'position': position?._toJson(),
      'rotation': rotation,
      'visible': visible,
      'zIndex': zIndex,
    };
  }
}
