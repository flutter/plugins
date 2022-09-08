// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// An Android of implementation of [GoogleMapsInspectorPlatform].
@visibleForTesting
class GoogleMapsInspectorIOS extends GoogleMapsInspectorPlatform {
  /// Creates a method-channel-based inspector instance that gets the channel
  /// for a given map ID from [channelProvider].
  GoogleMapsInspectorIOS(MethodChannel? Function(int mapId) channelProvider)
      : _channelProvider = channelProvider;

  final MethodChannel? Function(int mapId) _channelProvider;

  @override
  Future<bool> areBuildingsEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isBuildingsEnabled'))!;
  }

  @override
  Future<bool> areRotateGesturesEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isRotateGesturesEnabled'))!;
  }

  @override
  Future<bool> areScrollGesturesEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isScrollGesturesEnabled'))!;
  }

  @override
  Future<bool> areTiltGesturesEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isTiltGesturesEnabled'))!;
  }

  @override
  Future<bool> areZoomControlsEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isZoomControlsEnabled'))!;
  }

  @override
  Future<bool> areZoomGesturesEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isZoomGesturesEnabled'))!;
  }

  @override
  Future<MinMaxZoomPreference> getMinMaxZoomLevels({required int mapId}) async {
    final List<double> zoomLevels = (await _channelProvider(mapId)!
            .invokeMethod<List<dynamic>>('map#getMinMaxZoomLevels'))!
        .cast<double>();
    return MinMaxZoomPreference(zoomLevels[0], zoomLevels[1]);
  }

  @override
  Future<TileOverlay?> getTileOverlayInfo(TileOverlayId tileOverlayId,
      {required int mapId}) async {
    final Map<String, Object?>? tileInfo = await _channelProvider(mapId)!
        .invokeMapMethod<String, dynamic>(
            'map#getTileOverlayInfo', <String, String>{
      'tileOverlayId': tileOverlayId.value,
    });
    if (tileInfo == null) {
      return null;
    }
    return TileOverlay(
      tileOverlayId: tileOverlayId,
      fadeIn: tileInfo['fadeIn']! as bool,
      transparency: tileInfo['transparency']! as double,
      visible: tileInfo['visible']! as bool,
      // Android and iOS return different types.
      zIndex: (tileInfo['zIndex']! as num).toInt(),
    );
  }

  @override
  Future<bool> isCompassEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isCompassEnabled'))!;
  }

  @override
  Future<bool> isLiteModeEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isLiteModeEnabled'))!;
  }

  @override
  Future<bool> isMapToolbarEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isMapToolbarEnabled'))!;
  }

  @override
  Future<bool> isMyLocationButtonEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isMyLocationButtonEnabled'))!;
  }

  @override
  Future<bool> isTrafficEnabled({required int mapId}) async {
    return (await _channelProvider(mapId)!
        .invokeMethod<bool>('map#isTrafficEnabled'))!;
  }
}
