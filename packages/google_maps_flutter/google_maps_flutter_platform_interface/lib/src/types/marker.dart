// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart'
    show immutable, ValueChanged, VoidCallback;

import 'types.dart';

Object _offsetToJson(Offset offset) {
  return <Object>[offset.dx, offset.dy];
}

/// Text labels for a [Marker] info window.
@immutable
class InfoWindow {
  /// Creates an immutable representation of a label on for [Marker].
  const InfoWindow({
    this.title,
    this.snippet,
    this.anchor = const Offset(0.5, 0.0),
    this.onTap,
  });

  /// Text labels specifying that no text is to be displayed.
  static const InfoWindow noText = InfoWindow();

  /// Text displayed in an info window when the user taps the marker.
  ///
  /// A null value means no title.
  final String? title;

  /// Additional text displayed below the [title].
  ///
  /// A null value means no additional text.
  final String? snippet;

  /// The icon image point that will be the anchor of the info window when
  /// displayed.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// onTap callback for this [InfoWindow].
  final VoidCallback? onTap;

  /// Creates a new [InfoWindow] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  InfoWindow copyWith({
    String? titleParam,
    String? snippetParam,
    Offset? anchorParam,
    VoidCallback? onTapParam,
  }) {
    return InfoWindow(
      title: titleParam ?? title,
      snippet: snippetParam ?? snippet,
      anchor: anchorParam ?? anchor,
      onTap: onTapParam ?? onTap,
    );
  }

  Object _toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('title', title);
    addIfPresent('snippet', snippet);
    addIfPresent('anchor', _offsetToJson(anchor));

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is InfoWindow &&
        title == other.title &&
        snippet == other.snippet &&
        anchor == other.anchor;
  }

  @override
  int get hashCode => Object.hash(title.hashCode, snippet, anchor);

  @override
  String toString() {
    return 'InfoWindow{title: $title, snippet: $snippet, anchor: $anchor}';
  }
}

/// Uniquely identifies a [Marker] among [GoogleMap] markers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class MarkerId extends MapsObjectId<Marker> {
  /// Creates an immutable identifier for a [Marker].
  const MarkerId(String value) : super(value);
}

/// Marks a geographical location on the map.
///
/// A marker icon is drawn oriented against the device's screen rather than
/// the map's surface; that is, it will not necessarily change orientation
/// due to map rotations, tilting, or zooming.
@immutable
class Marker implements MapsObject<Marker> {
  /// Creates a set of marker configuration options.
  ///
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
  /// * reports [onTap] events
  /// * reports [onDragEnd] events
  const Marker({
    required this.markerId,
    this.alpha = _defaultAlphaValue,
    this.anchor = _defaultAnchorValue,
    this.consumeTapEvents = _defaultConsumeTapEventsValue,
    this.draggable = _defaultDraggableValue,
    this.flat = _defaultFlatValue,
    this.icon = _defaultIconValue,
    this.infoWindow = _defaultInfoWindowValue,
    this.position = _defaultPositionValue,
    this.rotation = _defaultRotationValue,
    this.visible = _defaultVisibleValue,
    this.zIndex = _defaultZIndexValue,
    this.clusterManagerId = _defaultClusterManagerId,
    this.onTap = _defaultOnTap,
    this.onDrag = _defaultOnDrag,
    this.onDragStart = _defaultOnDragStart,
    this.onDragEnd = _defaultOnDragEnd,
  }) : assert(alpha == null || (0.0 <= alpha && alpha <= 1.0));

  // Defaults used by constructor and copyWithDefaults method.
  static const double _defaultAlphaValue = 1.0;
  static const Offset _defaultAnchorValue = Offset(0.5, 1.0);
  static const bool _defaultConsumeTapEventsValue = false;
  static const bool _defaultDraggableValue = false;
  static const bool _defaultFlatValue = false;
  static const BitmapDescriptor _defaultIconValue =
      BitmapDescriptor.defaultMarker;
  static const InfoWindow _defaultInfoWindowValue = InfoWindow.noText;
  static const LatLng _defaultPositionValue = LatLng(0.0, 0.0);
  static const double _defaultRotationValue = 0.0;
  static const bool _defaultVisibleValue = true;
  static const double _defaultZIndexValue = 0.0;
  static const VoidCallback? _defaultOnTap = null;
  static const ValueChanged<LatLng>? _defaultOnDrag = null;
  static const ValueChanged<LatLng>? _defaultOnDragStart = null;
  static const ValueChanged<LatLng>? _defaultOnDragEnd = null;
  static const ClusterManagerId? _defaultClusterManagerId = null;

  /// Uniquely identifies a [Marker].
  final MarkerId markerId;

  @override
  MarkerId get mapsId => markerId;

  /// Marker clustering is managed by [ClusterManager] with [clusterManagerId].
  final ClusterManagerId? clusterManagerId;

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

  /// A Google Maps InfoWindow.
  ///
  /// The window is displayed when the marker is tapped.
  final InfoWindow infoWindow;

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

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Signature reporting the new [LatLng] at the start of a drag event.
  final ValueChanged<LatLng>? onDragStart;

  /// Signature reporting the new [LatLng] at the end of a drag event.
  final ValueChanged<LatLng>? onDragEnd;

  /// Signature reporting the new [LatLng] during the drag event.
  final ValueChanged<LatLng>? onDrag;

  /// Creates a new [Marker] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Marker copyWith({
    double? alphaParam,
    Offset? anchorParam,
    bool? consumeTapEventsParam,
    bool? draggableParam,
    bool? flatParam,
    BitmapDescriptor? iconParam,
    InfoWindow? infoWindowParam,
    LatLng? positionParam,
    double? rotationParam,
    bool? visibleParam,
    double? zIndexParam,
    VoidCallback? onTapParam,
    ValueChanged<LatLng>? onDragStartParam,
    ValueChanged<LatLng>? onDragParam,
    ValueChanged<LatLng>? onDragEndParam,
    ClusterManagerId? clusterManagerIdParam,
  }) {
    return Marker(
      markerId: markerId,
      alpha: alphaParam ?? alpha,
      anchor: anchorParam ?? anchor,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      draggable: draggableParam ?? draggable,
      flat: flatParam ?? flat,
      icon: iconParam ?? icon,
      infoWindow: infoWindowParam ?? infoWindow,
      position: positionParam ?? position,
      rotation: rotationParam ?? rotation,
      visible: visibleParam ?? visible,
      zIndex: zIndexParam ?? zIndex,
      onTap: onTapParam ?? onTap,
      onDragStart: onDragStartParam ?? onDragStart,
      onDrag: onDragParam ?? onDrag,
      onDragEnd: onDragEndParam ?? onDragEnd,
      clusterManagerId: clusterManagerIdParam ?? clusterManagerId,
    );
  }

  /// Creates a new [Marker] object whose values are the same as this instance,
  /// unless overwritten by the default values for specified parameters.
  Marker copyWithDefaults({
    bool? defaultAlpha,
    bool? defaultAnchor,
    bool? defaultConsumeTapEvents,
    bool? defaultDraggable,
    bool? defaultFlat,
    bool? defaultIcon,
    bool? defaultInfoWindow,
    bool? defaultPosition,
    bool? defaultRotation,
    bool? defaultVisible,
    bool? defaultZIndex,
    bool? defaultOnTap,
    bool? defaultOnDragStart,
    bool? defaultOnDrag,
    bool? defaultOnDragEnd,
    bool? defaultClusterManagerId,
  }) {
    return Marker(
      markerId: markerId,
      alpha: (defaultAlpha ?? false) ? _defaultAlphaValue : alpha,
      anchor: (defaultAnchor ?? false) ? _defaultAnchorValue : anchor,
      consumeTapEvents: (defaultConsumeTapEvents ?? false)
          ? _defaultConsumeTapEventsValue
          : consumeTapEvents,
      draggable:
          (defaultDraggable ?? false) ? _defaultDraggableValue : draggable,
      flat: (defaultFlat ?? false) ? _defaultFlatValue : flat,
      icon: (defaultIcon ?? false) ? _defaultIconValue : icon,
      infoWindow:
          (defaultInfoWindow ?? false) ? _defaultInfoWindowValue : infoWindow,
      position: (defaultPosition ?? false) ? _defaultPositionValue : position,
      rotation: (defaultRotation ?? false) ? _defaultRotationValue : rotation,
      visible: (defaultVisible ?? false) ? _defaultVisibleValue : visible,
      zIndex: (defaultZIndex ?? false) ? _defaultZIndexValue : zIndex,
      onTap: (defaultOnTap ?? false) ? _defaultOnTap : onTap,
      onDragStart:
          (defaultOnDragStart ?? false) ? _defaultOnDragStart : onDragStart,
      onDrag: (defaultOnDrag ?? false) ? _defaultOnDrag : onDrag,
      onDragEnd: (defaultOnDragEnd ?? false) ? _defaultOnDragEnd : onDragEnd,
      clusterManagerId: (defaultClusterManagerId ?? false)
          ? _defaultClusterManagerId
          : clusterManagerId,
    );
  }

  /// Creates a new [Marker] object whose values are the same as this instance.
  @override
  Marker clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('markerId', markerId.value);
    addIfPresent('alpha', alpha);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('draggable', draggable);
    addIfPresent('flat', flat);
    addIfPresent('icon', icon.toJson());
    addIfPresent('infoWindow', infoWindow._toJson());
    addIfPresent('position', position.toJson());
    addIfPresent('rotation', rotation);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    addIfPresent('clusterManagerId', clusterManagerId?.value);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Marker &&
        markerId == other.markerId &&
        alpha == other.alpha &&
        anchor == other.anchor &&
        consumeTapEvents == other.consumeTapEvents &&
        draggable == other.draggable &&
        flat == other.flat &&
        icon == other.icon &&
        infoWindow == other.infoWindow &&
        position == other.position &&
        rotation == other.rotation &&
        visible == other.visible &&
        zIndex == other.zIndex &&
        clusterManagerId == other.clusterManagerId;
  }

  @override
  int get hashCode => markerId.hashCode;

  @override
  String toString() {
    return 'Marker{markerId: $markerId, alpha: $alpha, anchor: $anchor, '
        'consumeTapEvents: $consumeTapEvents, draggable: $draggable, flat: $flat, '
        'icon: $icon, infoWindow: $infoWindow, position: $position, rotation: $rotation, '
        'visible: $visible, zIndex: $zIndex, onTap: $onTap, onDragStart: $onDragStart, '
        'onDrag: $onDrag, onDragEnd: $onDragEnd, clusterManagerId: $clusterManagerId}';
  }
}
