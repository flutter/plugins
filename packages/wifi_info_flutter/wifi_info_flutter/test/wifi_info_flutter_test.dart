// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_info_flutter_platform_interface/wifi_info_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const String kWifiNameResult = '1337wifi';
const String kWifiBSSIDResult = 'c0:ff:33:c0:d3:55';
const String kWifiIpAddressResult = '127.0.0.1';
const LocationAuthorizationStatus kRequestLocationResult =
    LocationAuthorizationStatus.authorizedAlways;
const LocationAuthorizationStatus kGetLocationResult =
    LocationAuthorizationStatus.authorizedAlways;

void main() {
  group('$WifiInfo', () {
    late WifiInfo wifiInfo;
    MockWifiInfoFlutterPlatform fakePlatform;

    setUp(() async {
      fakePlatform = MockWifiInfoFlutterPlatform();
      WifiInfoFlutterPlatform.instance = fakePlatform;
      wifiInfo = WifiInfo();
    });

    test('getWifiName', () async {
      String? result = await wifiInfo.getWifiName();
      expect(result, kWifiNameResult);
    });

    test('getWifiBSSID', () async {
      String? result = await wifiInfo.getWifiBSSID();
      expect(result, kWifiBSSIDResult);
    });

    test('getWifiIP', () async {
      String? result = await wifiInfo.getWifiIP();
      expect(result, kWifiIpAddressResult);
    });

    test('requestLocationServiceAuthorization', () async {
      LocationAuthorizationStatus result =
          await wifiInfo.requestLocationServiceAuthorization();
      expect(result, kRequestLocationResult);
    });

    test('getLocationServiceAuthorization', () async {
      LocationAuthorizationStatus result =
          await wifiInfo.getLocationServiceAuthorization();
      expect(result, kRequestLocationResult);
    });
  });
}

class MockWifiInfoFlutterPlatform extends WifiInfoFlutterPlatform {
  @override
  Future<String?> getWifiName() async {
    return kWifiNameResult;
  }

  @override
  Future<String?> getWifiBSSID() async {
    return kWifiBSSIDResult;
  }

  @override
  Future<String?> getWifiIP() async {
    return kWifiIpAddressResult;
  }

  @override
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization({
    bool requestAlwaysLocationUsage = false,
  }) async {
    return kRequestLocationResult;
  }

  @override
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() async {
    return kGetLocationResult;
  }
}
