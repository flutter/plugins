// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'connectivity_platform_interface.dart';

const MethodChannel _method_channel = MethodChannel('plugins.flutter.io/connectivity');

/// An implementation of [ConnectivityPlatform] that uses method channels.
class MethodChannelConnectivity extends ConnectivityPlatform {
  @override
  Future<String> checkConnectivity() async {
    final String result = await _method_channel.invokeMethod<String>('check');
    return result;
  }

  @override
  Future<String> getWifiName() async {
    String wifiName = await _method_channel.invokeMethod<String>('wifiName');
    // as Android might return <unknown ssid>, uniforming result
    // our iOS implementation will return null
    if (wifiName == '<unknown ssid>') wifiName = null;
    return wifiName;
  }

  @override
  Future<String> getWifiBSSID() async {
    return await _method_channel.invokeMethod<String>('wifiBSSID');
  }

  @override
  /// Obtains the IP address of the connected wifi network
  Future<String> getWifiIP() async {
    return await _method_channel.invokeMethod<String>('wifiIPAddress');
  }

  @override
  Future<String> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) async {
    final String result = await _method_channel.invokeMethod<String>(
        'requestLocationServiceAuthorization',
        <bool>[requestAlwaysLocationUsage]);
    return result;
  }

  @override
  Future<String> getLocationServiceAuthorization() async {
    final String result = await _method_channel
        .invokeMethod<String>('getLocationServiceAuthorization');
    return result;
  }
}
