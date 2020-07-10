import 'dart:async';
import 'dart:html' as html show window, NetworkInformation;

import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:connectivity_for_web/connectivity_for_web.dart';
import 'package:flutter/foundation.dart';

import 'utils/connectivity_result.dart';

/// The web implementation of the ConnectivityPlatform of the Connectivity plugin.
class NetworkInformationApiConnectivityPlugin extends ConnectivityPlugin {
  final html.NetworkInformation _networkInformation;

  /// A check to determine if this version of the plugin can be used.
  static bool isSupported() => html.window.navigator.connection != null;

  /// The constructor of the plugin.
  NetworkInformationApiConnectivityPlugin()
      : this.withConnection(html.window.navigator.connection);

  /// Creates the plugin, with an override of the NetworkInformation object.
  @visibleForTesting
  NetworkInformationApiConnectivityPlugin.withConnection(
      html.NetworkInformation connection)
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
      _networkInformation.onChange.listen((_) {
        _connectivityResult
            .add(networkInformationToConnectivityResult(_networkInformation));
      });
    }
    return _connectivityResult.stream;
  }
}
