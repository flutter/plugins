// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// An icon placed at a particular geographical location on the map's surface.
/// A marker icon is drawn oriented against the device's screen rather than the
/// map's surface; that is, it will not necessarily change orientation due to
/// map rotations, tilting, or zooming.
///
/// Markers are owned by a single [GoogleMapController] which fires events
/// as markers are added, updated, tapped, and removed.
class Marker {
  @visibleForTesting
  Marker(this._id, this._options);

  final String _id;
  MarkerOptions _options;

  /// The marker configuration options most recently applied programmatically
  /// via the map controller.
  ///
  /// The returned value does not reflect any changes made to the marker through
  /// touch events. Add listeners to the owning map controller to track those.
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

  /// Text labels specifying that no text is to be displayed.
  static const InfoWindowText noText = InfoWindowText(null, null);

  /// Text displayed in an info window when the user taps the marker.
  ///
  /// A null value means no title.
  final String title;

  /// Additional text displayed below the [title].
  ///
  /// A null value means no additional text.
  final String snippet;

  dynamic _toJson() => <dynamic>[title, snippet];
}

/// Configuration options for [Marker] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class MarkerOptions {
  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// True if the marker icon consumes tap events. If not, the map will perform
  /// default tap handling by centering the map on the marker and displaying its
  /// info window.
  final bool consumeTapEvents;

  /// True if the marker is draggable by user touch events.
  final bool draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool flat;

  /// A description of the bitmap used to draw the marker icon.
  final BitmapDescriptor icon;

  /// The icon image point that will be the anchor of the info window when
  /// displayed.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset infoWindowAnchor;

  /// Text content for the info window.
  final InfoWindowText infoWindowText;

  /// Geographical location of the marker.
  final LatLng position;

  /// Rotation of the marker image in degrees clockwise from the [anchor] point.
  final double rotation;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Creates a set of marker configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// marker defaults or current configuration.
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
  }) : assert(alpha == null || (0.0 <= alpha && alpha <= 1.0));

  /// Default marker options.
  ///
  /// Specifies a marker that
  /// * is fully opaque; [alpha] is 1.0
  /// * uses icon bottom center to indicate map position; [anchor] is (0.5, 1.0)
  /// * has default tap handling; [consumeTapEvents] is false
  /// * is stationary; [draggable] is false
  /// * is drawn against the screen, not the map; [flat] is false
  /// * has a default icon; [icon] is `BitmapDescriptor.defaultMarker`
  /// * anchors the info window at top center; [infoWindowAnchor] is (0.5, 0.0)
  /// * has no info window text; [infoWindowText] is `InfoWindowText.noText`
  /// * is positioned at 0, 0; [position] is `LatLng(0.0, 0.0)`
  /// * has an axis-aligned icon; [rotation] is 0.0
  /// * is visible; [visible] is true
  /// * is placed at the base of the drawing order; [zIndex] is 0.0
  static const MarkerOptions defaultOptions = MarkerOptions(
    alpha: 1.0,
    anchor: Offset(0.5, 1.0),
    consumeTapEvents: false,
    draggable: false,
    flat: false,
    icon: BitmapDescriptor.defaultMarker,
    infoWindowAnchor: Offset(0.5, 0.0),
    infoWindowText: InfoWindowText.noText,
    position: LatLng(0.0, 0.0),
    rotation: 0.0,
    visible: true,
    zIndex: 0.0,
  );

  /// Creates a new options object whose values are the same as this instance,
  /// unless overwritten by the specified [changes].
  ///
  /// Returns this instance, if [changes] is null.
  MarkerOptions copyWith(MarkerOptions changes) {
    if (changes == null) {
      return this;
    }
    return MarkerOptions(
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
