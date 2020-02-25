import 'dart:async';

import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';

import 'src/generated/network_information_types.dart' as dom;
import 'src/utils/connectivity_result.dart';

/// The web implementation of the ConnectivityPlatform of the Connectivity plugin.
class ConnectivityPlugin extends ConnectivityPlatform {
  /// Factory method that initializes the connectivity plugin platform with an instance
  /// of the plugin for the web.
  static void registerWith(Registrar registrar) {
    ConnectivityPlatform.instance = ConnectivityPlugin();
  }

  final dom.NetworkInformation _networkInformation;
  final bool _networkInformationApiSupported;

  /// The constructor of the plugin.
  ConnectivityPlugin() : this.withConnection(dom.navigator?.connection);

  /// Creates the plugin, with an override of the NetworkInformation object.
  @visibleForTesting
  ConnectivityPlugin.withConnection(dom.NetworkInformation connection)
      : _networkInformationApiSupported = connection != null,
        _networkInformation = connection;

  /// Checks the connection status of the device.
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    if (!_networkInformationApiSupported) {
      return ConnectivityResult.none;
    }
    return networkInformationToConnectivityResult(_networkInformation);
  }

  Stream<ConnectivityResult> get _noopStream async* {
    yield ConnectivityResult.none;
  }

  StreamController<ConnectivityResult> _connectivityResult;

  /// Returns a Stream of ConnectivityResults changes.
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    if (!_networkInformationApiSupported) {
      return _noopStream;
    }
    if (_connectivityResult == null) {
      _connectivityResult = StreamController<ConnectivityResult>();
      _networkInformation.onchange = allowInterop((_) {
        _connectivityResult
            .add(networkInformationToConnectivityResult(_networkInformation));
      });
    }
    return _connectivityResult.stream;
  }

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
