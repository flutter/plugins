// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

/// Connection Status Check Result
///
/// Wifi: Device connected via Wi-Fi
/// Mobile: Device connected to cellular network
/// None: Device not connected to any network
enum ConnectivityResult { wifi, mobile, none }

const MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/connectivity');

/// Checks the connection status of the device.
Future<ConnectivityResult> checkConnectivity() async {
  final String result = await _channel.invokeMethod('check');
  switch (result) {
    case 'wifi':
      return ConnectivityResult.wifi;
    case 'mobile':
      return ConnectivityResult.mobile;
    case 'none':
    default:
      return ConnectivityResult.none;
  }
}
