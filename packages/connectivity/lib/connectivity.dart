// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

/// Connection Status Check Result
///
/// WiFi: Device connected via Wi-Fi
/// Mobile: Device connected to cellular network
/// None: Device not connected to any network
enum ConnectivityResult { wifi, mobile, none }

const MethodChannel _methodChannel =
    MethodChannel('plugins.flutter.io/connectivity');

const EventChannel _eventChannel =
    EventChannel('plugins.flutter.io/connectivity_status');

class Connectivity {
  Stream<ConnectivityResult> _onConnectivityChanged;

  /// Fires whenever the connectivity state changes.
  Stream<ConnectivityResult> get onConnectivityChanged {
    if (_onConnectivityChanged == null) {
      _onConnectivityChanged = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseConnectivityResult(event));
    }
    return _onConnectivityChanged;
  }

  /// Checks the connection status of the device.
  ///
  /// Do not use the result of this function to decide whether you can reliably
  /// make a network request. It only gives you the radio status.
  ///
  /// Instead listen for connectivity changes via [onConnectivityChanged] stream.
  Future<ConnectivityResult> checkConnectivity() async {
    final String result = await _methodChannel.invokeMethod('check');
    return _parseConnectivityResult(result);
  }
}

ConnectivityResult _parseConnectivityResult(String state) {
  switch (state) {
    case 'wifi':
      return ConnectivityResult.wifi;
    case 'mobile':
      return ConnectivityResult.mobile;
    case 'none':
    default:
      return ConnectivityResult.none;
  }
}
