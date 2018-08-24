// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'package:geofencing/src/callback_dispatcher.dart';
import 'package:geofencing/src/location.dart';
import 'package:geofencing/src/platform_settings.dart';

const int _kEnterEvent = 1;
const int _kExitEvent = 2;
const int _kDwellEvent = 4;

/// Valid geofencing events.
///
/// Note: `GeofenceEvent.dwell` is not supported on iOS.
enum GeofenceEvent { enter, exit, dwell }

// Internal.
int geofenceEventToInt(GeofenceEvent e) {
  switch (e) {
    case GeofenceEvent.enter:
      return _kEnterEvent;
    case GeofenceEvent.exit:
      return _kExitEvent;
    case GeofenceEvent.dwell:
      return _kDwellEvent;
    default:
      throw UnimplementedError();
  }
}

// TODO(bkonyi): handle event masks
// Internal.
GeofenceEvent intToGeofenceEvent(int e) {
  switch (e) {
    case _kEnterEvent:
      return GeofenceEvent.enter;
    case _kExitEvent:
      return GeofenceEvent.exit;
    case _kDwellEvent:
      return GeofenceEvent.dwell;
    default:
      throw UnimplementedError();
  }
}

/// A circular region which represents a geofence.
class GeofenceRegion {
  /// The ID associated with the geofence.
  ///
  /// This ID is used to identify the geofence and is required to delete a
  /// specific geofence.
  final String id;

  /// The location of the geofence.
  final Location location;

  /// The radius around `location` that will be considered part of the geofence.
  final double radius;

  /// The types of geofence events to listen for.
  ///
  /// Note: `GeofenceEvent.dwell` is not supported on iOS.
  final List<GeofenceEvent> triggers;

  /// Android specific settings for a geofence.
  final AndroidGeofencingSettings androidSettings;

  GeofenceRegion(
      this.id, double latitude, double longitude, this.radius, this.triggers,
      {AndroidGeofencingSettings androidSettings})
      : location = Location(latitude, longitude),
        androidSettings = (androidSettings ?? AndroidGeofencingSettings());

  List<dynamic> _toArgs() {
    final int triggerMask = triggers.fold(
        0, (int trigger, GeofenceEvent e) => (geofenceEventToInt(e) | trigger));
    final List<dynamic> args = <dynamic>[
      id,
      location.latitude,
      location.longitude,
      radius,
      triggerMask
    ];
    if (Platform.isAndroid) {
      args.addAll(platformSettingsToArgs(androidSettings));
    }
    return args;
  }
}

class GeofencingManager {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/geofencing_plugin');

  /// Initialize the plugin and request relevant permissions from the user.
  static Future<void> initialize() async {
    final CallbackHandle callback =
        PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel.invokeMethod('GeofencingPlugin.initializeService',
        <dynamic>[callback.toRawHandle()]);
  }

  /// Register for geofence events for a [GeofenceRegion].
  ///
  /// `region` is the geofence region to register with the system.
  /// `callback` is the method to be called when a geofence event associated
  /// with `region` occurs.
  ///
  /// Note: `GeofenceEvent.dwell` is not supported on iOS. If the
  /// `GeofenceRegion` provided only requests notifications for a
  /// `GeofenceEvent.dwell` trigger on iOS, `UnsupportedError` is thrown.
  static Future<void> registerGeofence(
      GeofenceRegion region,
      void Function(List<String> id, Location location, GeofenceEvent event)
          callback) async {
    if (Platform.isIOS &&
        region.triggers.contains(GeofenceEvent.dwell) &&
        (region.triggers.length == 1)) {
      throw UnsupportedError("iOS does not support 'GeofenceEvent.dwell'");
    }
    final List<dynamic> args = <dynamic>[
      PluginUtilities.getCallbackHandle(callback).toRawHandle()
    ];
    args.addAll(region._toArgs());
    await _channel.invokeMethod('GeofencingPlugin.registerGeofence', args);
  }

  /// Stop receiving geofence events for a given [GeofenceRegion].
  static Future<bool> removeGeofence(GeofenceRegion region) async =>
      (region == null) ? false : await removeGeofenceById(region.id);

  /// Stop receiving geofence events for an identifier associated with a
  /// geofence region.
  static Future<bool> removeGeofenceById(String id) async => await _channel
      .invokeMethod('GeofencingPlugin.removeGeofence', <dynamic>[id]);
}
