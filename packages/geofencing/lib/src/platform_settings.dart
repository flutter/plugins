// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:geofencing/src/geofencing.dart';

// Internal.
List<dynamic> platformSettingsToArgs(AndroidGeofencingSettings s) =>
    s._toArgs();

class AndroidGeofencingSettings {
  List<GeofenceEvent> initialTrigger;
  int expirationDuration;
  int loiteringDelay;
  int notificationResponsiveness;

  AndroidGeofencingSettings(
      {this.initialTrigger = const <GeofenceEvent>[GeofenceEvent.enter],
      this.loiteringDelay = 0,
      this.expirationDuration = -1,
      this.notificationResponsiveness = 0});

  List<dynamic> _toArgs() {
    final int initTriggerMask = initialTrigger.fold(
        0, (int trigger, GeofenceEvent e) => (geofenceEventToInt(e) | trigger));
    return <dynamic>[
      initTriggerMask,
      expirationDuration,
      loiteringDelay,
      notificationResponsiveness
    ];
  }
}
