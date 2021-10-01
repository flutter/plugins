// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Inspect Google Maps state using the platform SDK.
///
/// This class is primarily used for testing. The methods on this
/// class should call "getters" on the GoogleMap object or equivalent
/// on the platform side.
class GoogleMapInspector {
  GoogleMapInspector(this._channel);

  final MethodChannel _channel;

  Future<bool?> isCompassEnabled() async {
    return await _channel.invokeMethod<bool>('map#isCompassEnabled');
  }

  Future<bool?> isMapToolbarEnabled() async {
    return await _channel.invokeMethod<bool>('map#isMapToolbarEnabled');
  }

  Future<MinMaxZoomPreference> getMinMaxZoomLevels() async {
    final List<double> zoomLevels =
        (await _channel.invokeMethod<List<dynamic>>('map#getMinMaxZoomLevels'))!
            .cast<double>();
    return MinMaxZoomPreference(zoomLevels[0], zoomLevels[1]);
  }

  Future<double?> getZoomLevel() async {
    final double? zoomLevel =
        await _channel.invokeMethod<double>('map#getZoomLevel');
    return zoomLevel;
  }

  Future<bool?> isZoomGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isZoomGesturesEnabled');
  }

  Future<bool?> isZoomControlsEnabled() async {
    return await _channel.invokeMethod<bool>('map#isZoomControlsEnabled');
  }

  Future<bool?> isLiteModeEnabled() async {
    return await _channel.invokeMethod<bool>('map#isLiteModeEnabled');
  }

  Future<bool?> isRotateGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isRotateGesturesEnabled');
  }

  Future<bool?> isTiltGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isTiltGesturesEnabled');
  }

  Future<bool?> isScrollGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isScrollGesturesEnabled');
  }

  Future<bool?> isMyLocationButtonEnabled() async {
    return await _channel.invokeMethod<bool>('map#isMyLocationButtonEnabled');
  }

  Future<bool?> isTrafficEnabled() async {
    return await _channel.invokeMethod<bool>('map#isTrafficEnabled');
  }

  Future<bool?> isBuildingsEnabled() async {
    return await _channel.invokeMethod<bool>('map#isBuildingsEnabled');
  }

  Future<Uint8List?> takeSnapshot() async {
    return await _channel.invokeMethod<Uint8List>('map#takeSnapshot');
  }

  Future<Map<String, dynamic>?> getTileOverlayInfo(String id) async {
    return (await _channel.invokeMapMethod<String, dynamic>(
        'map#getTileOverlayInfo', <String, String>{
      'tileOverlayId': id,
    }));
  }

  Future<Map<String, dynamic>?> getGroundOverlayInfo(String id) async {
    return (await _channel.invokeMapMethod<String, dynamic>(
        'map#getGroundOverlayInfo', <String, String>{
      'groundOverlayId': id,
    }));
  }
}
