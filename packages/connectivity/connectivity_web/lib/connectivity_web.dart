import 'dart:async';
import 'dart:js';

import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/generated/network_information_types.dart' as dom;
import 'src/utils/connectivity_result.dart';

/// The web implementation of the ConnectivityPlatform of the Connectivity plugin.
class ConnectivityPlugin extends ConnectivityPlatform {
  /// Factory method that initializes the connectivity plugin platform with an instance
  /// of the plugin for the web.
  static void registerWith(Registrar registrar) {
    ConnectivityPlatform.instance = ConnectivityPlugin();
  }

  bool _networkInformationApiSupported = false;

  /// The constructor of the plugin.
  ConnectivityPlugin() {
    // Check and cache if the browser supports the API.
    _networkInformationApiSupported = dom.navigator?.connection != null;
  }

  @override

  /// Checks the connection status of the device.
  Future<ConnectivityResult> checkConnectivity() async {
    if (!_networkInformationApiSupported) {
      return ConnectivityResult.none;
    }
    return networkInformationToConnectivityResult(dom.navigator.connection);
  }

  Stream<ConnectivityResult> get _noopStream async* {
    yield ConnectivityResult.none;
  }

  StreamController<ConnectivityResult> _connectivityResult;

  @override

  /// Returns a Stream of ConnectivityResults changes.
  Stream<ConnectivityResult> get onConnectivityChanged {
    if (!_networkInformationApiSupported) {
      return _noopStream;
    }
    if (_connectivityResult == null) {
      _connectivityResult = StreamController<ConnectivityResult>();
      dom.navigator.connection.onchange = allowInterop((dynamic e) {
        _connectivityResult
            .add(networkInformationToConnectivityResult(e.target));
      });
    }
    return _connectivityResult.stream;
  }

  @override

  /// Obtains the wifi name (SSID) of the connected network
  Future<String> getWifiName() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: 'getWifiName() is not supported on the web platform.',
    );
  }

  @override

  /// Obtains the wifi BSSID of the connected network.
  Future<String> getWifiBSSID() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: 'getWifiBSSID() is not supported on the web platform.',
    );
  }

  @override

  /// Obtains the IP address of the connected wifi network
  Future<String> getWifiIP() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: 'getWifiIP() is not supported on the web platform.',
    );
  }

  @override

  /// Request to authorize the location service (Only on iOS).
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message:
          'requestLocationServiceAuthorization() is not supported on the web platform.',
    );
  }

  @override

  /// Get the current location service authorization (Only on iOS).
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() {
    throw PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message:
          'getLocationServiceAuthorization() is not supported on the web platform.',
    );
  }
}
