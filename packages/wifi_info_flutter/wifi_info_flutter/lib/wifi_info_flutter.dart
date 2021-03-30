// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wifi_info_flutter_platform_interface/wifi_info_flutter_platform_interface.dart';

// Export enums from the platform_interface so plugin users can use them directly.
export 'package:wifi_info_flutter_platform_interface/wifi_info_flutter_platform_interface.dart'
    show LocationAuthorizationStatus;

/// Checks WI-FI status and more.
class WifiInfo {
  WifiInfo._();

  /// Constructs a singleton instance of [WifiInfo].
  ///
  /// [WifiInfo] is designed to work as a singleton.
  factory WifiInfo() => _singleton;

  static final WifiInfo _singleton = WifiInfo._();

  static WifiInfoFlutterPlatform get _platform =>
      WifiInfoFlutterPlatform.instance;

  /// Obtains the wifi name (SSID) of the connected network
  ///
  /// Please note that it DOESN'T WORK on emulators (returns null).
  ///
  /// From android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the SSID.
  Future<String?> getWifiName() {
    return _platform.getWifiName();
  }

  /// Obtains the wifi BSSID of the connected network.
  ///
  /// Please note that it DOESN'T WORK on emulators (returns null).
  ///
  /// From Android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the BSSID.
  Future<String?> getWifiBSSID() {
    return _platform.getWifiBSSID();
  }

  /// Obtains the IP address of the connected wifi network
  Future<String?> getWifiIP() {
    return _platform.getWifiIP();
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
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization({
    bool requestAlwaysLocationUsage = false,
  }) {
    return _platform.requestLocationServiceAuthorization(
      requestAlwaysLocationUsage: requestAlwaysLocationUsage,
    );
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
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() {
    return _platform.getLocationServiceAuthorization();
  }
}
