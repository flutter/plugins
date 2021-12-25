// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `MarkerController` class wraps a [gmaps.Marker], how it handles events, and its associated (optional) [gmaps.InfoWindow] widget.
class MarkerController {
  gmaps.Marker? _marker;

  final bool _consumeTapEvents;

  final gmaps.InfoWindow? _infoWindow;

  bool _infoWindowShown = false;

  /// Creates a `MarkerController`, which wraps a [gmaps.Marker] object, its `onTap`/`onDrag` behavior, and its associated [gmaps.InfoWindow].
  MarkerController({
    required gmaps.Marker marker,
    gmaps.InfoWindow? infoWindow,
    bool consumeTapEvents = false,
    LatLngCallback? onDragStart,
    LatLngCallback? onDrag,
    LatLngCallback? onDragEnd,
    ui.VoidCallback? onTap,
  })  : _marker = marker,
        _infoWindow = infoWindow,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      marker.onClick.listen((event) {
        onTap.call();
      });
    }
    if (onDragStart != null) {
      marker.onDragstart.listen((event) {
        if (marker != null) {
          marker.position = event.latLng;
        }
        onDragStart.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
    if (onDrag != null) {
      marker.onDrag.listen((event) {
        if (marker != null) {
          marker.position = event.latLng;
        }
        onDrag.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
    if (onDragEnd != null) {
      marker.onDragend.listen((event) {
        if (marker != null) {
          marker.position = event.latLng;
        }
        onDragEnd.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
  }

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Returns `true` if the [gmaps.InfoWindow] associated to this marker is being shown.
  bool get infoWindowShown => _infoWindowShown;

  /// Returns the [gmaps.Marker] associated to this controller.
  gmaps.Marker? get marker => _marker;

  /// Returns the [gmaps.InfoWindow] associated to the marker.
  @visibleForTesting
  gmaps.InfoWindow? get infoWindow => _infoWindow;

  /// Updates the options of the wrapped [gmaps.Marker] object.
  ///
  /// This cannot be called after [remove].
  void update(
    gmaps.MarkerOptions options, {
    HtmlElement? newInfoWindowContent,
  }) {
    assert(_marker != null, 'Cannot `update` Marker after calling `remove`.');
    _marker!.options = options;
    if (_infoWindow != null && newInfoWindowContent != null) {
      _infoWindow!.content = newInfoWindowContent;
    }
  }

  /// Disposes of the currently wrapped [gmaps.Marker].
  void remove() {
    if (_marker != null) {
      _infoWindowShown = false;
      _marker!.visible = false;
      _marker!.map = null;
      _marker = null;
    }
  }

  /// Hide the associated [gmaps.InfoWindow].
  ///
  /// This cannot be called after [remove].
  void hideInfoWindow() {
    assert(_marker != null, 'Cannot `hideInfoWindow` on a `remove`d Marker.');
    if (_infoWindow != null) {
      _infoWindow!.close();
      _infoWindowShown = false;
    }
  }

  /// Show the associated [gmaps.InfoWindow].
  ///
  /// This cannot be called after [remove].
  void showInfoWindow() {
    assert(_marker != null, 'Cannot `showInfoWindow` on a `remove`d Marker.');
    if (_infoWindow != null) {
      _infoWindow!.open(_marker!.map, _marker);
      _infoWindowShown = true;
    }
  }
}
