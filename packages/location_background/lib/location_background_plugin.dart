// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Required for PluginUtilities.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Types of location activities for iOS.
///
/// See https://developer.apple.com/documentation/corelocation/clactivitytype
enum LocationActivityType {
  other,
  automotiveNavigation,
  fitness,
  otherNavigation,
}

/// A representation of a location update.
class Location {
  Location(
      this._time, this.latitude, this.longitude, this.altitude, this.speed);

  factory Location.fromJson(String jsonLocation) {
    final Map<String, dynamic> location = json.decode(jsonLocation);
    return Location(location['time'], location['latitude'],
        location['longitude'], location['altitude'], location['speed']);
  }

  final double _time;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;

  DateTime get time =>
      DateTime.fromMillisecondsSinceEpoch((_time * 1000).round(), isUtc: true);

  @override
  String toString() =>
      '[$time] ($latitude, $longitude) altitude: $altitude m/s: $speed';

  String toJson() {
    final Map<String, double> location = <String, double>{
      'time': _time,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
    };
    return json.encode(location);
  }
}

// When we start the background service isolate, we only ever enter it once.
// To communicate between the native plugin and this entrypoint, we'll use
// MethodChannels to open a persistent communication channel to trigger
// callbacks.
void _backgroundCallbackDispatcher() {
  const String kOnLocationEvent = 'onLocationEvent';
  const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/ios_background_location_callback');

  // Setup Flutter state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // Reference to the onLocationEvent callback.
  Function onLocationEvent;

  // This is where the magic happens and we handle background events from the
  // native portion of the plugin. Here we massage the location data into a
  // `Location` object which we then pass to the provided callback.
  _channel.setMethodCallHandler((MethodCall call) async {
    final dynamic args = call.arguments;

    Function _performCallbackLookup() {
      final CallbackHandle handle =
          CallbackHandle.fromRawHandle(call.arguments[0]);

      // PluginUtilities.getCallbackFromHandle performs a lookup based on the
      // handle we retrieved earlier.
      final Function closure = PluginUtilities.getCallbackFromHandle(handle);

      if (closure == null) {
        print('Fatal Error: Callback lookup failed!');
        exit(-1);
      }
      return closure;
    }

    if (call.method == kOnLocationEvent) {
      onLocationEvent ??= _performCallbackLookup();
      final Location location =
          Location(args[1], args[2], args[3], args[4], args[5]);
      onLocationEvent(location);
    } else {
      assert(false, "No handler defined for method type: '${call.method}'");
    }
  });
}

class LocationBackgroundPlugin {
  LocationBackgroundPlugin(
      {this.pauseLocationUpdatesAutomatically = false,
      this.showsBackgroundLocationIndicator = true,
      this.activityType = LocationActivityType.other}) {
    // Start the headless location service. The parameter here is a handle to
    // a callback managed by the Flutter engine, which allows for us to pass
    // references to our callbacks between isolates.
    print("Starting LocationBackgroundPlugin service");
    final CallbackHandle handle =
        PluginUtilities.getCallbackHandle(_backgroundCallbackDispatcher);
    assert(handle != null, 'Unable to lookup callback.');
    _channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod(_kStartHeadlessService, <dynamic>[handle.toRawHandle()]);
  }

  // The method channel we'll use to communicate with the native portion of our
  // plugin.
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/ios_background_location');

  static const String _kCancelLocationUpdates = 'cancelLocationUpdates';
  static const String _kMonitorLocationChanges = 'monitorLocationChanges';
  static const String _kStartHeadlessService = 'startHeadlessService';

  bool pauseLocationUpdatesAutomatically;
  bool showsBackgroundLocationIndicator;
  LocationActivityType activityType;

  /// Start getting significant location updates through `callback`.
  ///
  /// `callback` is invoked on a background isolate and will not have direct
  /// access to the state held by the main isolate (or any other isolate).
  Future<bool> monitorSignificantLocationChanges(
      void Function(Location location) callback) {
    if (callback == null) {
      throw ArgumentError.notNull('callback');
    }
    final CallbackHandle handle = PluginUtilities.getCallbackHandle(callback);
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod(_kMonitorLocationChanges, <dynamic>[
      handle.toRawHandle(),
      pauseLocationUpdatesAutomatically,
      showsBackgroundLocationIndicator,
      activityType.index
    ]).then<bool>((dynamic result) => result);
  }

  /// Stop all location updates.
  Future<void> cancelLocationUpdates() =>
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      _channel.invokeMethod(_kCancelLocationUpdates);
}
