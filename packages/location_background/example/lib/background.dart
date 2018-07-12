// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file

import 'package:location_background_plugin/location_background_plugin.dart';

import 'dart:isolate';
import 'dart:ui';

const String kLocationPluginPortName = 'location_plugin_port';
SendPort uiSendPort;

/// This is an example of a callback for LocationBackgroundPlugin's
/// `startMonitoringLocation`. A callback can be defined anywhere in an
/// application's code, but cannot be from another program.
class Foo {
  static void locationCallback(Location location) {
    if (uiSendPort == null) {
      // We use isolate ports to communicate between the main isolate and spawned
      // isolates since they do not share memory.
      uiSendPort = IsolateNameServer.lookupPortByName(kLocationPluginPortName);
    }
    uiSendPort?.send(location.toJson());
  }
}
