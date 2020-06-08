import 'dart:async';

import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/network_information_api_connectivity_plugin.dart';
import 'src/dart_html_connectivity_plugin.dart';

/// The web implementation of the ConnectivityPlatform of the Connectivity plugin.
class ConnectivityPlugin extends ConnectivityPlatform {
  /// Factory method that initializes the connectivity plugin platform with an instance
  /// of the plugin for the web.
  static void registerWith(Registrar registrar) {
    if (NetworkInformationApiConnectivityPlugin.isSupported()) {
      ConnectivityPlatform.instance = NetworkInformationApiConnectivityPlugin();
    } else {
      ConnectivityPlatform.instance = DartHtmlConnectivityPlugin();
    }
  }

  // The following are completely unsupported methods on the web platform.

  /// Obtains the wifi name (SSID) of the connected network
  @override
  Future<String> getWifiName() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: 'getWifiName() is not supported on the web platform.',
    );
  }

  /// Obtains the wifi BSSID of the connected network.
  @override
  Future<String> getWifiBSSID() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: 'getWifiBSSID() is not supported on the web platform.',
    );
  }

  /// Obtains the IP address of the connected wifi network
  @override
  Future<String> getWifiIP() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: 'getWifiIP() is not supported on the web platform.',
    );
  }

  /// Request to authorize the location service (Only on iOS).
  @override
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message:
          'requestLocationServiceAuthorization() is not supported on the web platform.',
    );
  }

  /// Get the current location service authorization (Only on iOS).
  @override
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message:
          'getLocationServiceAuthorization() is not supported on the web platform.',
    );
  }
}
