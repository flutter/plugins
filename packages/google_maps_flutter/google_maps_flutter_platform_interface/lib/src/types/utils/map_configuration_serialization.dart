// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../map_configuration.dart';

/// Returns a JSON representation of [config].
///
/// This is intended for two purposes:
/// - Conversion of [MapConfiguration] to the map options dictionary used by
///   legacy platform interface methods.
/// - Conversion of [MapConfiguration] to the default method channel
///   implementation's representation.
///
/// Both of these are parts of the public interface, so any change to the
/// representation other than adding a new field requires a breaking change to
/// the package.
Map<String, Object> jsonForMapConfiguration(MapConfiguration config) {
  final EdgeInsets? padding = config.padding;
  return <String, Object>{
    if (config.compassEnabled != null) 'compassEnabled': config.compassEnabled!,
    if (config.mapToolbarEnabled != null)
      'mapToolbarEnabled': config.mapToolbarEnabled!,
    if (config.cameraTargetBounds != null)
      'cameraTargetBounds': config.cameraTargetBounds!.toJson(),
    if (config.mapType != null) 'mapType': config.mapType!.index,
    if (config.minMaxZoomPreference != null)
      'minMaxZoomPreference': config.minMaxZoomPreference!.toJson(),
    if (config.rotateGesturesEnabled != null)
      'rotateGesturesEnabled': config.rotateGesturesEnabled!,
    if (config.scrollGesturesEnabled != null)
      'scrollGesturesEnabled': config.scrollGesturesEnabled!,
    if (config.tiltGesturesEnabled != null)
      'tiltGesturesEnabled': config.tiltGesturesEnabled!,
    if (config.zoomControlsEnabled != null)
      'zoomControlsEnabled': config.zoomControlsEnabled!,
    if (config.zoomGesturesEnabled != null)
      'zoomGesturesEnabled': config.zoomGesturesEnabled!,
    if (config.liteModeEnabled != null)
      'liteModeEnabled': config.liteModeEnabled!,
    if (config.trackCameraPosition != null)
      'trackCameraPosition': config.trackCameraPosition!,
    if (config.myLocationEnabled != null)
      'myLocationEnabled': config.myLocationEnabled!,
    if (config.myLocationButtonEnabled != null)
      'myLocationButtonEnabled': config.myLocationButtonEnabled!,
    if (padding != null)
      'padding': <double>[
        padding.top,
        padding.left,
        padding.bottom,
        padding.right,
      ],
    if (config.indoorViewEnabled != null)
      'indoorEnabled': config.indoorViewEnabled!,
    if (config.trafficEnabled != null) 'trafficEnabled': config.trafficEnabled!,
    if (config.buildingsEnabled != null)
      'buildingsEnabled': config.buildingsEnabled!,
  };
}
