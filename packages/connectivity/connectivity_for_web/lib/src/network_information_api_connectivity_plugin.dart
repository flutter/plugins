import 'dart:async';

import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:connectivity_for_web/connectivity_for_web.dart';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

import 'generated/network_information_types.dart' as dom;
import 'utils/connectivity_result.dart';

/// The web implementation of the ConnectivityPlatform of the Connectivity plugin.
class NetworkInformationApiConnectivityPlugin extends ConnectivityPlugin {
  final dom.NetworkInformation _networkInformation;

  /// A check to determine if this version of the plugin can be used.
  static bool isSupported() => dom.navigator?.connection != null;

  /// The constructor of the plugin.
  NetworkInformationApiConnectivityPlugin()
      : this.withConnection(dom.navigator?.connection);

  /// Creates the plugin, with an override of the NetworkInformation object.
  @visibleForTesting
  NetworkInformationApiConnectivityPlugin.withConnection(
      dom.NetworkInformation connection)
      : _networkInformation = connection;

  /// Checks the connection status of the device.
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return networkInformationToConnectivityResult(_networkInformation);
  }

  StreamController<ConnectivityResult> _connectivityResult;

  /// Returns a Stream of ConnectivityResults changes.
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    if (_connectivityResult == null) {
      _connectivityResult = StreamController<ConnectivityResult>();
      _networkInformation.onchange = allowInterop((_) {
        _connectivityResult
            .add(networkInformationToConnectivityResult(_networkInformation));
      });
    }
    return _connectivityResult.stream;
  }
}
