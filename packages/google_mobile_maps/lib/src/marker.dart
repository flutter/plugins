// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

class Marker {
  Marker._(this.mapId, this.id, MarkerOptions options) : _options = options;

  final int mapId;
  final String id;
  MarkerOptions _options;

  Future<void> update(MarkerOptions options) async {
    assert(options != null);
    _options = options;
    await _channel.invokeMethod('marker#update', <String, dynamic>{
      'map': mapId,
      'marker': id,
      'markerOptions': options._toJson(),
    });
  }

  MarkerOptions get options => _options;

  Future<void> remove() async {
    await _channel.invokeMethod('marker#remove', <String, dynamic>{
      'map': mapId,
      'marker': id,
    });
  }

  Future<void> hideInfoWindow() async {
    await _channel.invokeMethod('marker#hideInfoWindow', <String, dynamic>{
      'map': mapId,
      'marker': id,
    });
  }

  Future<void> showInfoWindow() async {
    await _channel.invokeMethod('marker#showInfoWindow', <String, dynamic>{
      'map': mapId,
      'marker': id,
    });
  }
}

class MarkerOptions {
  static const String unspecified = 'Unspecified';
  final LatLng position;
  final double alpha;
  final Offset anchor;
  final bool draggable;
  final bool flat;
  final BitmapDescriptor icon;
  final Offset infoWindowAnchor;
  final double rotation;
  final String snippet;
  final String title;
  final bool visible;
  final double zIndex;

  const MarkerOptions({
    @required this.position,
    this.alpha = 1.0,
    this.anchor = const Offset(0.5, 1.0),
    this.draggable = false,
    this.flat = false,
    this.icon = BitmapDescriptor.defaultMarker,
    this.infoWindowAnchor = const Offset(0.5, 0.0),
    this.rotation = 0.0,
    this.snippet,
    this.title,
    this.visible = true,
    this.zIndex = 0.0,
  })  : assert(position != null),
        assert(alpha != null),
        assert(anchor != null),
        assert(draggable != null),
        assert(flat != null),
        assert(icon != null),
        assert(infoWindowAnchor != null),
        assert(rotation != null),
        assert(zIndex != null),
        assert(visible != null);

  MarkerOptions copyWith({
    LatLng position,
    double alpha,
    Offset anchor,
    bool draggable,
    bool flat,
    BitmapDescriptor icon,
    Offset infoWindowAnchor,
    double rotation,
    String snippet = unspecified,
    String title = unspecified,
    double zIndex,
    bool visible,
  }) =>
      new MarkerOptions(
        position: position ?? this.position,
        alpha: alpha ?? this.alpha,
        anchor: anchor ?? this.anchor,
        draggable: draggable ?? this.draggable,
        flat: flat ?? this.flat,
        icon: icon ?? this.icon,
        infoWindowAnchor: infoWindowAnchor ?? this.infoWindowAnchor,
        rotation: rotation ?? this.rotation,
        snippet: identical(snippet, unspecified) ? this.snippet : snippet,
        title: identical(title, unspecified) ? this.title : title,
        zIndex: zIndex ?? this.zIndex,
        visible: visible ?? this.visible,
      );

  dynamic _toJson() => <String, dynamic>{
        'position': position._toJson(),
        'alpha': alpha,
        'anchor': <double>[anchor.dx, anchor.dy],
        'draggable': draggable,
        'flat': flat,
        'icon': icon._toJson(),
        'infoWindowAnchor': <double>[infoWindowAnchor.dx, infoWindowAnchor.dy],
        'rotation': rotation,
        'snippet': snippet,
        'title': title,
        'visible': visible,
        'zIndex': zIndex,
      };
}
