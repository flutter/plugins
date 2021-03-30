// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../wifi_info_flutter_platform_interface.dart';

/// An implementation of [WifiInfoFlutterPlatform] that uses method channels.
class MethodChannelWifiInfoFlutter extends WifiInfoFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
      MethodChannel('plugins.flutter.io/wifi_info_flutter');

  @override
  Future<String?> getWifiName() async {
    return methodChannel.invokeMethod<String>('wifiName');
  }

  @override
  Future<String?> getWifiBSSID() {
    return methodChannel.invokeMethod<String>('wifiBSSID');
  }

  @override
  Future<String?> getWifiIP() {
    return methodChannel.invokeMethod<String>('wifiIPAddress');
  }

  @override
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization({
    bool requestAlwaysLocationUsage = false,
  }) {
    return methodChannel.invokeMethod<String>(
        'requestLocationServiceAuthorization', <bool>[
      requestAlwaysLocationUsage
    ]).then(_parseLocationAuthorizationStatus);
  }

  @override
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() {
    return methodChannel
        .invokeMethod<String>('getLocationServiceAuthorization')
        .then(_parseLocationAuthorizationStatus);
  }
}

/// Convert a String to a LocationAuthorizationStatus value.
LocationAuthorizationStatus _parseLocationAuthorizationStatus(String? result) {
  return LocationAuthorizationStatus.values.firstWhere(
    (LocationAuthorizationStatus status) => result == describeEnum(status),
    orElse: () => LocationAuthorizationStatus.unknown,
  );
}
