// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Connection Status Check Result
///
/// WiFi: Device connected via Wi-Fi
/// Mobile: Device connected to cellular network
/// None: Device not connected to any network
enum ConnectivityResult { wifi, mobile, none }

/// Metered: Device connected via metered Wi-Fi (Android only)
/// BlockedBackgroundData: DataSaver is active and the app can't use background data (Android only)
/// WhitelistedBackgroundData: DataSaver is active but the app is whitelisted can use background data (Android only)
/// None: No DataSaver is active, default value on iOS
enum DataSaving {
  metered,
  blockedBackgroundData,
  whitelistedBackgroundData,
  none
}

class NetworkInfo {
  NetworkInfo(this.connectivityResult, this.dataSaving);

  final ConnectivityResult connectivityResult;
  final DataSaving dataSaving;
}

class Connectivity {
  /// Constructs a singleton instance of [Connectivity].
  ///
  /// [Connectivity] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // EventChannel because it is overridden. Forcing the class to be a singleton class can prevent
  // misusage of creating a second instance from a programmer.
  factory Connectivity() {
    if (_singleton == null) {
      _singleton = Connectivity._();
    }
    return _singleton;
  }

  Connectivity._();

  static Connectivity _singleton;

  Stream<NetworkInfo> _onConnectivityChanged;

  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel(
    'plugins.flutter.io/connectivity',
  );

  @visibleForTesting
  static const EventChannel eventChannel = EventChannel(
    'plugins.flutter.io/connectivity_status',
  );

  /// Fires whenever the connectivity state changes.
  Stream<NetworkInfo> get onConnectivityChanged {
    if (_onConnectivityChanged == null) {
      _onConnectivityChanged = eventChannel
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
  Future<NetworkInfo> checkConnectivity() async {
    final String result = await methodChannel.invokeMethod<String>('check');
    return _parseConnectivityResult(result);
  }

  /// Obtains the wifi name (SSID) of the connected network
  ///
  /// Please note that it DOESN'T WORK on emulators (returns null).
  ///
  /// From android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the SSID.
  Future<String> getWifiName() async {
    String wifiName = await methodChannel.invokeMethod<String>('wifiName');
    // as Android might return <unknown ssid>, uniforming result
    // our iOS implementation will return null
    if (wifiName == '<unknown ssid>') wifiName = null;
    return wifiName;
  }

  /// Obtains the wifi BSSID of the connected network.
  ///
  /// Please note that it DOESN'T WORK on emulators (returns null).
  ///
  /// From Android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the BSSID.
  Future<String> getWifiBSSID() async {
    return await methodChannel.invokeMethod<String>('wifiBSSID');
  }

  /// Obtains the IP address of the connected wifi network
  Future<String> getWifiIP() async {
    return await methodChannel.invokeMethod<String>('wifiIPAddress');
  }
}

NetworkInfo _parseConnectivityResult(String state) {
  final List<String> statuses = state.split("/");
  ConnectivityResult connectivity;
  DataSaving dataSaving = DataSaving.none;
  // first the general casese
  switch (statuses[0]) {
    // general cases
    case 'wifi':
      connectivity = ConnectivityResult.wifi;
      break;
    case 'mobile':
      connectivity = ConnectivityResult.mobile;
      break;
    case 'none':
    default:
      connectivity = ConnectivityResult.none;
      break;
  }
  if (statuses.length > 1) {
    // Android cases
    switch (statuses[1]) {
      case 'metered':
        dataSaving = DataSaving.metered;
        break;
      case 'blockedBackgroundData':
        dataSaving = DataSaving.blockedBackgroundData;
        break;
      case 'whitelistedBackgroundData':
        dataSaving = DataSaving.whitelistedBackgroundData;
        break;
    }
  }

  return NetworkInfo(connectivity, dataSaving);
}
