// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Connection Status Check Result
///
/// WiFi: Device connected via Wi-Fi
/// Mobile: Device connected to cellular network
/// None: Device not connected to any network
enum ConnectivityResult { wifi, mobile, none }
enum ConnectionSubtype {
  none,
  unknown,
  m1xRTT, // ~ 50-100 kbps
  cdma, // ~ 14-64 kbps
  edge, // ~ 50-100 kbps
  evdo_0, // ~ 400-1000 kbps
  evdo_a, // ~ 600-1400 kbps
  gprs, // ~ 100 kbps
  hsdpa, // ~ 2-14 Mbps
  hspa, // ~ 700-1700 kbps
  hsupa, // ~ 1-23 Mbps
  umts, // ~ 400-7000 kbps
  ehrpd, // ~ 1-2 Mbps
  evdo_b, // ~ 5 Mbps
  hspap, // ~ 10-20 Mbps
  iden, // ~25 kbps
  lte, // ~ 10+ Mbps
}

Map<String, ConnectionSubtype> connectionTypeMap = <String, ConnectionSubtype>{
  "1xRTT": ConnectionSubtype.m1xRTT, // ~ 50-100 kbps
  "cdma": ConnectionSubtype.cdma, // ~ 14-64 kbps
  "edge": ConnectionSubtype.edge, // ~ 50-100 kbps
  "evdo_0": ConnectionSubtype.evdo_0, // ~ 400-1000 kbps
  "evdo_a": ConnectionSubtype.evdo_a, // ~ 600-1400 kbps
  "gprs": ConnectionSubtype.gprs, // ~ 100 kbps
  "hsdpa": ConnectionSubtype.hsdpa, // ~ 2-14 Mbps
  "hspa": ConnectionSubtype.hspa, // ~ 700-1700 kbps
  "hsupa": ConnectionSubtype.hsupa, // ~ 1-23 Mbps
  "umts": ConnectionSubtype.umts, // ~ 400-7000 kbps
  "ehrpd": ConnectionSubtype.ehrpd, // ~ 1-2 Mbps
  "evdo_b": ConnectionSubtype.evdo_b, // ~ 5 Mbps
  "hspap": ConnectionSubtype.hspap, // ~ 10-20 Mbps
  "iden": ConnectionSubtype.iden, // ~25 kbps
  "lte": ConnectionSubtype.lte, // ~ 10+ Mbps
  "unknown":
      ConnectionSubtype.unknown, // is connected but cannot tell the speed
  "none": ConnectionSubtype.none
};

class ConnectivityDetailedResult {
  ConnectivityDetailedResult({
    this.result = ConnectivityResult.none,
    this.subtype = ConnectionSubtype.none,
  });

  final ConnectivityResult result;
  final ConnectionSubtype subtype;
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

  Stream<ConnectivityResult> _onConnectivityChanged;
  Stream<ConnectivityDetailedResult> _onConnectivityInfoChanged;

  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel(
    'plugins.flutter.io/connectivity',
  );

  @visibleForTesting
  static const EventChannel eventChannel = EventChannel(
    'plugins.flutter.io/connectivity_status',
  );

  /// Fires whenever the connectivity state changes. Returns stream of [ConnectivityResult]
  Stream<ConnectivityResult> get onConnectivityChanged {
    if (_onConnectivityChanged == null) {
      _onConnectivityChanged = eventChannel.receiveBroadcastStream().map(
          (dynamic event) => _parseConnectivityDetailedResult(event).result);
    }
    return _onConnectivityChanged;
  }

  /// Fires whenever the connectivity state changes. Return stream of [ConnectivityDetailedResult]
  Stream<ConnectivityDetailedResult> get onConnectivityInfoChanged {
    if (_onConnectivityInfoChanged == null) {
      _onConnectivityInfoChanged = eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseConnectivityDetailedResult(event));
    }
    return _onConnectivityInfoChanged;
  }

  /// Checks the connection status of the device.
  ///
  /// Do not use the result of this function to decide whether you can reliably
  /// make a network request. It only gives you the radio status.
  ///
  /// Instead listen for connectivity changes via [onConnectivityChanged] stream.
  ///
  /// You can also check the mobile broadband connectivity subtype via [getNetworkSubtype]
  Future<ConnectivityResult> checkConnectivity() async {
    final String result = await methodChannel.invokeMethod<String>('check');
    return _parseConnectivityDetailedResult(result).result;
  }

  /// Checks connectivity info, [ConnectivityDetailedResult]
  Future<ConnectivityDetailedResult> checkConnectivityInfo() async {
    final String result = await methodChannel.invokeMethod<String>('check');
    return _parseConnectivityDetailedResult(result);
  }

  /// Checks the network mobile connection subtype of the device.
  /// Returns the appropriate mobile connectivity subtype enum [ConnectionSubtype] such
  /// as gprs, edge, hsdpa etc.
  ///
  /// More information on mobile connectivity types can be found at
  /// https://en.wikipedia.org/wiki/Mobile_broadband#Generations
  ///
  /// Return [ConnectionSubtype.unknown] if it is connected but there is not connection subtype info. eg. Wifi
  /// Returns [ConnectionSubtype.none] if there is no connection
  Future<ConnectionSubtype> getNetworkSubtype() async {
    final String result = await methodChannel.invokeMethod<String>('subtype');
    return _parseConnectionSubtype(result);
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

  /// Request to authorize the location service (Only on iOS).
  ///
  /// This method will throw a [PlatformException] on Android.
  ///
  /// Returns a [LocationAuthorizationStatus] after user authorized or denied the location on this request.
  ///
  /// If the location information needs to be accessible all the time, set `requestAlwaysLocationUsage` to true. If user has
  /// already granted a [LocationAuthorizationStatus.authorizedWhenInUse] prior to requesting an "always" access, it will return [LocationAuthorizationStatus.denied].
  ///
  /// If the location service authorization is not determined prior to making this call, a platform standard UI of requesting a location service will pop up.
  /// This UI will only show once unless the user re-install the app to their phone which resets the location service authorization to not determined.
  ///
  /// This method is a helper to get the location authorization that is necessary for certain functionality of this plugin.
  /// It can be replaced with other permission handling code/plugin if preferred.
  /// To request location authorization, make sure to add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:
  /// * `NSLocationAlwaysAndWhenInUseUsageDescription` - describe why the app needs access to the user’s location information
  /// all the time (foreground and background). This is called _Privacy - Location Always and When In Use Usage Description_ in the visual editor.
  /// * `NSLocationWhenInUseUsageDescription` - describe why the app needs access to the user’s location information when the app is
  /// running in the foreground. This is called _Privacy - Location When In Use Usage Description_ in the visual editor.
  ///
  /// Starting from iOS 13, `getWifiBSSID` and `getWifiIP` will only work properly if:
  ///
  /// * The app uses Core Location, and has the user’s authorization to use location information.
  /// * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.
  /// * The app has active VPN configurations installed.
  ///
  /// If the app falls into the first category, call this method before calling `getWifiBSSID` or `getWifiIP`.
  /// For example,
  /// ```dart
  /// if (Platform.isIOS) {
  ///   LocationAuthorizationStatus status = await _connectivity.getLocationServiceAuthorization();
  ///   if (status == LocationAuthorizationStatus.notDetermined) {
  ///     status = await _connectivity.requestLocationServiceAuthorization();
  ///   }
  ///   if (status == LocationAuthorizationStatus.authorizedAlways || status == LocationAuthorizationStatus.authorizedWhenInUse) {
  ///     wifiBSSID = await _connectivity.getWifiName();
  ///   } else {
  ///     print('location service is not authorized, the data might not be correct');
  ///     wifiBSSID = await _connectivity.getWifiName();
  ///   }
  /// } else {
  ///   wifiBSSID = await _connectivity.getWifiName();
  /// }
  /// ```
  ///
  /// Ideally, a location service authorization should only be requested if the current authorization status is not determined.
  ///
  /// See also [getLocationServiceAuthorization] to obtain current location service status.
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) async {
    //Just `assert(Platform.isIOS)` will prevent us from doing dart side unit testing.
    assert(!Platform.isAndroid);
    final String result = await methodChannel.invokeMethod<String>(
        'requestLocationServiceAuthorization',
        <bool>[requestAlwaysLocationUsage]);
    return _convertLocationStatusString(result);
  }

  /// Get the current location service authorization (Only on iOS).
  ///
  /// This method will throw a [PlatformException] on Android.
  ///
  /// Returns a [LocationAuthorizationStatus].
  /// If the returned value is [LocationAuthorizationStatus.notDetermined], a subsequent [requestLocationServiceAuthorization] call
  /// can request the authorization.
  /// If the returned value is not [LocationAuthorizationStatus.notDetermined], a subsequent [requestLocationServiceAuthorization]
  /// will not initiate another request. It will instead return the "determined" status.
  ///
  /// This method is a helper to get the location authorization that is necessary for certain functionality of this plugin.
  /// It can be replaced with other permission handling code/plugin if preferred.
  ///
  /// Starting from iOS 13, `getWifiBSSID` and `getWifiIP` will only work properly if:
  ///
  /// * The app uses Core Location, and has the user’s authorization to use location information.
  /// * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.
  /// * The app has active VPN configurations installed.
  ///
  /// If the app falls into the first category, call this method before calling `getWifiBSSID` or `getWifiIP`.
  /// For example,
  /// ```dart
  /// if (Platform.isIOS) {
  ///   LocationAuthorizationStatus status = await _connectivity.getLocationServiceAuthorization();
  ///   if (status == LocationAuthorizationStatus.authorizedAlways || status == LocationAuthorizationStatus.authorizedWhenInUse) {
  ///     wifiBSSID = await _connectivity.getWifiName();
  ///   } else {
  ///     print('location service is not authorized, the data might not be correct');
  ///     wifiBSSID = await _connectivity.getWifiName();
  ///   }
  /// } else {
  ///   wifiBSSID = await _connectivity.getWifiName();
  /// }
  /// ```
  ///
  /// See also [requestLocationServiceAuthorization] for requesting a location service authorization.
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() async {
    //Just `assert(Platform.isIOS)` will prevent us from doing dart side unit testing.
    assert(!Platform.isAndroid);
    final String result = await methodChannel
        .invokeMethod<String>('getLocationServiceAuthorization');
    return _convertLocationStatusString(result);
  }

  LocationAuthorizationStatus _convertLocationStatusString(String result) {
    switch (result) {
      case 'notDetermined':
        return LocationAuthorizationStatus.notDetermined;
      case 'restricted':
        return LocationAuthorizationStatus.restricted;
      case 'denied':
        return LocationAuthorizationStatus.denied;
      case 'authorizedAlways':
        return LocationAuthorizationStatus.authorizedAlways;
      case 'authorizedWhenInUse':
        return LocationAuthorizationStatus.authorizedWhenInUse;
      default:
        return LocationAuthorizationStatus.unknown;
    }
  }
}

ConnectivityDetailedResult _parseConnectivityDetailedResult(String state) {
  final List<String> split = state.split(",");
  return ConnectivityDetailedResult(
    result: _parseConnectivityResult(split[0]),
    subtype: _parseConnectionSubtype(split[1]),
  );
}

ConnectionSubtype _parseConnectionSubtype(String state) {
  return connectionTypeMap[state] ?? ConnectionSubtype.unknown;
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

/// The status of the location service authorization.
enum LocationAuthorizationStatus {
  /// The authorization of the location service is not determined.
  notDetermined,

  /// This app is not authorized to use location.
  restricted,

  /// User explicitly denied the location service.
  denied,

  /// User authorized the app to access the location at any time.
  authorizedAlways,

  /// User authorized the app to access the location when the app is visible to them.
  authorizedWhenInUse,

  /// Status unknown.
  unknown
}
