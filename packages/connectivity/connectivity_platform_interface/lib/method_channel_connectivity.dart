// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'connectivity_platform_interface.dart';

/// The method channel used to interact with the native platform.
@visibleForTesting
const MethodChannel method_channel =
    MethodChannel('plugins.flutter.io/connectivity');

/// An implementation of [ConnectivityPlatform] that uses method channels.
class MethodChannelConnectivity extends ConnectivityPlatform {
  @override
  Future<String> checkConnectivity() async {
    final String result = await method_channel.invokeMethod<String>('check');
    return result;
  }

  @override
  Future<String> getWifiName() async {
    return method_channel.invokeMethod<String>('wifiName');
  }

  @override
  Future<String> getWifiBSSID() async {
    return await method_channel.invokeMethod<String>('wifiBSSID');
  }

  @override
  Future<String> getWifiIP() async {
    return await method_channel.invokeMethod<String>('wifiIPAddress');
  }

  @override
  Future<String> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) async {
    final String result = await method_channel.invokeMethod<String>(
        'requestLocationServiceAuthorization',
        <bool>[requestAlwaysLocationUsage]);
    return result;
  }

  @override
  Future<String> getLocationServiceAuthorization() async {
    final String result = await method_channel
        .invokeMethod<String>('getLocationServiceAuthorization');
    return result;
  }
}
