// Copyright 2020 The Chromium Authors. All rights reserved.
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

    final MethodChannelConnectivity connectivity = MethodChannelConnectivity();

    tearDown(() {
      log.clear();
    });

    test('checkConnectivity', () async {
      await connectivity.checkConnectivity();
      expect(
        log,
        <Matcher>[isMethodCall('check', arguments: null)],
      );
    });

    test('getWifiName', () async {
      await connectivity.getWifiName();
      expect(
        log,
        <Matcher>[isMethodCall('wifiName', arguments: null)],
      );
    });

    test('getWifiBSSID', () async {
      await connectivity.getWifiBSSID();
      expect(
        log,
        <Matcher>[isMethodCall('wifiBSSID', arguments: null)],
      );
    });

    test('getWifiIP', () async {
      await connectivity.getWifiIP();
      expect(
        log,
        <Matcher>[isMethodCall('wifiIPAddress', arguments: null)],
      );
    });

    test(
        'requestLocationServiceAuthorization requestLocationServiceAuthorization set to false (default)',
        () async {
      await connectivity.requestLocationServiceAuthorization();
      expect(
        log,
        <Matcher>[
          isMethodCall('requestLocationServiceAuthorization',
              arguments: <bool>[false])
        ],
      );
    });

    test(
        'requestLocationServiceAuthorization requestLocationServiceAuthorization set to true',
        () async {
      await connectivity.requestLocationServiceAuthorization(
          requestAlwaysLocationUsage: true);
      expect(
        log,
        <Matcher>[
          isMethodCall('requestLocationServiceAuthorization',
              arguments: <bool>[true])
        ],
      );
    });

    test('getLocationServiceAuthorization', () async {
      await connectivity.getLocationServiceAuthorization();
      expect(
        log,
        <Matcher>[
          isMethodCall('getLocationServiceAuthorization', arguments: null)
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
