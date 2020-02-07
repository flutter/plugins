// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required;

import 'connectivity_platform_interface.dart';

const MethodChannel _method_channel = MethodChannel('plugins.flutter.io/connectivity');
const EventChannel _eventChannel = EventChannel('plugins.flutter.io/connectivity_status');

/// An implementation of [ConnectivityPlatform] that uses method channels.
class MethodChannelConnectivity extends ConnectivityPlatform {
  Stream<ConnectivityResult> _onConnectivityChanged;

   /// Fires whenever the connectivity state changes.
  Stream<ConnectivityResult> get onConnectivityChanged {
    if (_onConnectivityChanged == null) {
      _onConnectivityChanged = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => parseConnectivityResult(event));
    }
    return _onConnectivityChanged;
  }

  Future<ConnectivityResult> checkConnectivity() async {
    final String result = await _method_channel.invokeMethod<String>('check');
    return parseConnectivityResult(result);
  }

  Future<String> getWifiName() async {
    String wifiName = await _method_channel.invokeMethod<String>('wifiName');
    // as Android might return <unknown ssid>, uniforming result
    // our iOS implementation will return null
    if (wifiName == '<unknown ssid>') wifiName = null;
    return wifiName;
  }

  Future<String> getWifiBSSID() async {
    return await _method_channel.invokeMethod<String>('wifiBSSID');
  }

  /// Obtains the IP address of the connected wifi network
  Future<String> getWifiIP() async {
    return await _method_channel.invokeMethod<String>('wifiIPAddress');
  }

  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) async {
    //Just `assert(Platform.isIOS)` will prevent us from doing dart side unit testing.
    assert(!Platform.isAndroid);
    final String result = await _method_channel.invokeMethod<String>(
        'requestLocationServiceAuthorization',
        <bool>[requestAlwaysLocationUsage]);
    return convertLocationStatusString(result);
  }

  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() async {
    //Just `assert(Platform.isIOS)` will prevent us from doing dart side unit testing.
    assert(!Platform.isAndroid);
    final String result = await _method_channel
        .invokeMethod<String>('getLocationServiceAuthorization');
    return convertLocationStatusString(result);
  }
}
