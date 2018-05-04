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

dynamic _offsetToJson(Offset offset) {
  if (offset == null) {
    return null;
  }
  return <dynamic>[offset.dx, offset.dy];
}

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
/// "do not change this configuration item".
class MarkerOptions {
  final double alpha;
  final Offset anchor;
  final bool consumeTapEvents;
  final bool draggable;
  final bool flat;
  final BitmapDescriptor icon;
  final Offset infoWindowAnchor;
  final InfoWindowText infoWindowText;
  final LatLng position;
  final double rotation;
  final bool visible;
  final double zIndex;

  const MarkerOptions({
    this.alpha,
    this.anchor,
    this.consumeTapEvents,
    this.draggable,
    this.flat,
    this.icon,
    this.infoWindowAnchor,
    this.infoWindowText,
    this.position,
    this.rotation,
    this.visible,
    this.zIndex,
  });

  static const MarkerOptions defaultOptions = const MarkerOptions(
    alpha: 1.0,
    anchor: const Offset(0.5, 1.0),
    consumeTapEvents: false,
    draggable: false,
    flat: false,
    icon: BitmapDescriptor.defaultMarker,
    infoWindowAnchor: const Offset(0.5, 0.0),
    infoWindowText: InfoWindowText.noText,
    rotation: 0.0,
    visible: true,
    zIndex: 0.0,
  );

  MarkerOptions _updateWith(MarkerOptions changes) {
    return new MarkerOptions(
      alpha: changes.alpha ?? alpha,
      anchor: changes.anchor ?? anchor,
      consumeTapEvents: changes.consumeTapEvents ?? consumeTapEvents,
      draggable: changes.draggable ?? draggable,
      flat: changes.flat ?? flat,
      icon: changes.icon ?? icon,
      infoWindowAnchor: changes.infoWindowAnchor ?? infoWindowAnchor,
      infoWindowText: changes.infoWindowText ?? infoWindowText,
      position: changes.position ?? position,
      rotation: changes.rotation ?? rotation,
      visible: changes.visible ?? visible,
      zIndex: changes.zIndex ?? zIndex,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('alpha', alpha);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('draggable', draggable);
    addIfPresent('flat', flat);
    addIfPresent('icon', icon?._toJson());
    addIfPresent('infoWindowAnchor', _offsetToJson(infoWindowAnchor));
    addIfPresent('infoWindowText', infoWindowText?._toJson());
    addIfPresent('position', position?._toJson());
    addIfPresent('rotation', rotation);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    return json;
  }
}
