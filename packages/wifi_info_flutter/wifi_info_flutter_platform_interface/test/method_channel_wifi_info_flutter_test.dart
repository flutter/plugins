// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_info_flutter_platform_interface/src/enums.dart';
import 'package:wifi_info_flutter_platform_interface/src/method_channel_wifi_info_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelWifiInfoFlutter', () {
    final List<MethodCall> log = <MethodCall>[];
    late MethodChannelWifiInfoFlutter methodChannelWifiInfoFlutter;

    setUp(() async {
      methodChannelWifiInfoFlutter = MethodChannelWifiInfoFlutter();

      methodChannelWifiInfoFlutter.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
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
    });

    test('getWifiName', () async {
      final String? result = await methodChannelWifiInfoFlutter.getWifiName();
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
      final String? result = await methodChannelWifiInfoFlutter.getWifiBSSID();
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
      final String? result = await methodChannelWifiInfoFlutter.getWifiIP();
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
          await methodChannelWifiInfoFlutter
              .requestLocationServiceAuthorization();
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
          await methodChannelWifiInfoFlutter.getLocationServiceAuthorization();
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
  });
}
