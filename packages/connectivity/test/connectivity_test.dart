// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Connectivity', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      _setMockMethodChannel(log);
      _setMockEventChannel();
    });

    test('onConnectivityChanged', () async {
      final ConnectivityResult result =
          await Connectivity().onConnectivityChanged.first;
      expect(result, ConnectivityResult.wifi);
    });

    test('getWifiName', () async {
      final String result = await Connectivity().getWifiName();
      expect(result, '1337wifi');
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'wifiName',
            arguments: null,
          ),
        ],
      );
    });

    test('getWifiBSSID', () async {
      final String result = await Connectivity().getWifiBSSID();
      expect(result, 'c0:ff:33:c0:d3:55');
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'wifiBSSID',
            arguments: null,
          ),
        ],
      );
    });

    test('getWifiIP', () async {
      final String result = await Connectivity().getWifiIP();
      expect(result, '127.0.0.1');
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'wifiIPAddress',
            arguments: null,
          ),
        ],
      );
    });

    test('requestLocationServiceAuthorization', () async {
      final LocationAuthorizationStatus result =
          await Connectivity().requestLocationServiceAuthorization();
      expect(result, LocationAuthorizationStatus.authorizedAlways);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'requestLocationServiceAuthorization',
            arguments: <bool>[false],
          ),
        ],
      );
    });

    test('getLocationServiceAuthorization', () async {
      final LocationAuthorizationStatus result =
          await Connectivity().getLocationServiceAuthorization();
      expect(result, LocationAuthorizationStatus.authorizedAlways);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'getLocationServiceAuthorization',
            arguments: null,
          ),
        ],
      );
    });

    test('checkConnectivity', () async {
      final ConnectivityResult result =
          await Connectivity().checkConnectivity();
      expect(result, ConnectivityResult.wifi);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'check',
            arguments: null,
          ),
        ],
      );
    });
  });
}

/// Intercept [Connectivity] calls to the [MethodChannel].
void _setMockMethodChannel(List<MethodCall> log) {
  Connectivity.methodChannel
      .setMockMethodCallHandler((MethodCall methodCall) async {
    log
      ..clear()
      ..add(methodCall);

    switch (methodCall.method) {
      case 'check':
        return 'wifi';
      case 'wifiName':
        return '1337wifi';
      case 'wifiBSSID':
        return 'c0:ff:33:c0:d3:55';
      case 'wifiIPAddress':
        return '127.0.0.1';
      case 'requestLocationServiceAuthorization':
        return 'authorizedAlways';
      case 'getLocationServiceAuthorization':
        return 'authorizedAlways';
      default:
        return null;
    }
  });
}

/// Intercept [Connectivity] calls to the [EventChannel].
void _setMockEventChannel() {
  final ConnectivityNetworkOption _wifi =
      ConnectivityNetworkOption.ofType(ConnectivityNetworkType.wifi);

  MethodChannel(Connectivity.eventChannel.name)
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'listen':
        await _setNetworkType(_wifi);
        break;
      case 'cancel':
      default:
        return null;
    }
  });
}

/// Update the [Connectivity.onConnectivityChanged] stream value.
Future<void> _setNetworkType(
  ConnectivityNetworkOption connectivityNetworkOption,
) async {
  await defaultBinaryMessenger.handlePlatformMessage(
    Connectivity.eventChannel.name,
    Connectivity.eventChannel.codec.encodeSuccessEnvelope(
      connectivityNetworkOption.getType,
    ),
    (_) {},
  );
}

/// An object representing the possible network types available for [Connectivity]
///
/// Create a [ConnectivityNetworkOption] by using the named constructor [ConnectivityNetworkOption.ofType]
/// to get network options for:
///
/// {@tool sample}
///
/// wifi:
///
/// ```dart
/// ConnectivityNetworkOption.ofType(ConnectivityNetworkType.wifi);
/// ```
/// {@end-tool}
///
/// {@tool sample}
/// mobile:
///
/// ```dart
/// ConnectivityNetworkOption.ofType(ConnectivityNetworkType.mobile);
/// ```
/// {@end-tool}
///
/// {@tool sample}
/// none, disconnected, airplane mode:
///
/// ```dart
/// ConnectivityNetworkOption.ofType(ConnectivityNetworkType.none);
/// ```
/// {@end-tool}
class ConnectivityNetworkOption {
  /// Create an instance of [ConnectivityNetworkOption] using the
  /// [ConnectivityNetworkType] provided.
  ConnectivityNetworkOption.ofType(
    ConnectivityNetworkType networkType,
  ) : _networkType = _networkTypes[networkType];

  static Map<ConnectivityNetworkType, String> _networkTypes =
      <ConnectivityNetworkType, String>{
    ConnectivityNetworkType.wifi: 'wifi',
    ConnectivityNetworkType.mobile: 'mobile',
    ConnectivityNetworkType.none: 'none',
  };

  final String _networkType;

  /// Get a [String] representing the network type correlating with
  /// [Connectivity]'s available network options.
  String get getType => _networkType;
}

/// Network types available for [Connectivity]
enum ConnectivityNetworkType { wifi, mobile, none }
