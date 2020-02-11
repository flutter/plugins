// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:connectivity_platform_interface/method_channel_connectivity.dart';
import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$ConnectivityPlatform', () {
    test('$MethodChannelConnectivity() is the default instance', () {
      expect(ConnectivityPlatform.instance,
          isInstanceOf<MethodChannelConnectivity>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        ConnectivityPlatform.instance = ImplementsConnectivityPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final ConnectivityPlatformMock mock = ConnectivityPlatformMock();
      ConnectivityPlatform.instance = mock;
    });

    test('Can be extended', () {
      ConnectivityPlatform.instance = ExtendsConnectivityPlatform();
    });
  });

  group('$MethodChannelConnectivity', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/connectivity');
    final List<MethodCall> log = <MethodCall>[];
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    final MethodChannelConnectivity launcher = MethodChannelConnectivity();

    tearDown(() {
      log.clear();
    });

    test('checkConnectivity', () async {
      await launcher.checkConnectivity();
      expect(
        log,
        <Matcher>[
          isMethodCall('check')
        ],
      );
    });

    test('getWifiName', () async {
      await launcher.getWifiName();
      expect(
        log,
        <Matcher>[
          isMethodCall('wifiName')
        ],
      );
    });

    test('getWifiBSSID', () async {
      await launcher.getWifiBSSID();
      expect(
        log,
        <Matcher>[
          isMethodCall('wifiBSSID')
        ],
      );
    });

    test('getWifiIP', () async {
      await launcher.getWifiIP();
      expect(
        log,
        <Matcher>[
          isMethodCall('wifiIPAddress')
        ],
      );
    });

    test('requestLocationServiceAuthorization requestLocationServiceAuthorization set to false (default)', () async {
      await launcher.requestLocationServiceAuthorization();
      expect(
        log,
        <Matcher>[
          isMethodCall('requestLocationServiceAuthorization', arguments: <bool>[false])
        ],
      );
    });

    test('requestLocationServiceAuthorization requestLocationServiceAuthorization set to true', () async {
      await launcher.requestLocationServiceAuthorization(requestAlwaysLocationUsage: true);
      expect(
        log,
        <Matcher>[
          isMethodCall('requestLocationServiceAuthorization', arguments: <bool>[true])
        ],
      );
    });

    test('getLocationServiceAuthorization', () async {
      await launcher.getLocationServiceAuthorization();
      expect(
        log,
        <Matcher>[
          isMethodCall('getLocationServiceAuthorization')
        ],
      );
    });
  });
}

class ConnectivityPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {}

class ImplementsConnectivityPlatform extends Mock
    implements ConnectivityPlatform {}

class ExtendsConnectivityPlatform extends ConnectivityPlatform {}
