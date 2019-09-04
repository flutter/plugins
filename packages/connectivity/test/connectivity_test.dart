// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Connectivity', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      Connectivity.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'check':
            return 'wifi,unknown';
          case 'subtype':
            return 'evdo_b';
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
      log.clear();
      MethodChannel(Connectivity.eventChannel.name)
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listen':
            // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
            // https://github.com/flutter/flutter/issues/33446
            // ignore: deprecated_member_use
            await BinaryMessages.handlePlatformMessage(
              Connectivity.eventChannel.name,
              Connectivity.eventChannel.codec
                  .encodeSuccessEnvelope('mobile,hsdpa'),
              (_) {},
            );
            break;
          case 'cancel':
          default:
            return null;
        }
      });
    });

    test('onConnectivityChanged', () async {
      final ConnectivityResult result =
          await Connectivity().onConnectivityChanged.first;
      expect(result, ConnectivityResult.mobile);
    });

    test('onConnectivityInfoChanged', () async {
      final ConnectivityDetailedResult info =
          await Connectivity().onConnectivityInfoChanged.first;
      expect(info.result, ConnectivityResult.mobile);
      expect(info.subtype, ConnectionSubtype.hsdpa);
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

    test('checkConnectivityInfo', () async {
      final ConnectivityDetailedResult info =
          await Connectivity().checkConnectivityInfo();
      expect(info.result, ConnectivityResult.wifi);
      expect(info.subtype, ConnectionSubtype.unknown);
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

    test('subtype', () async {
      final ConnectionSubtype result = await Connectivity().getNetworkSubtype();
      expect(result, ConnectionSubtype.evdo_b);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'subtype',
            arguments: null,
          ),
        ],
      );
    });
  });
}
