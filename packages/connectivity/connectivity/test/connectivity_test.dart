// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:connectivity/connectivity.dart';
import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';

const ConnectivityResult kCheckConnectivityResult = ConnectivityResult.wifi;
const String kWifiNameResult = '1337wifi';
const String kWifiBSSIDResult = 'c0:ff:33:c0:d3:55';
const String kWifiIpAddressResult = '127.0.0.1';
const String kProxyHostResult = '10.0.2.2';
const int kProxyPortResult = 8888;
const List kProxyExclusionListResult = ['localhost'];
const LocationAuthorizationStatus kRequestLocationResult =
    LocationAuthorizationStatus.authorizedAlways;
const LocationAuthorizationStatus kGetLocationResult =
    LocationAuthorizationStatus.authorizedAlways;

void main() {
  group('Connectivity', () {
    Connectivity connectivity;
    MockConnectivityPlatform fakePlatform;
    setUp(() async {
      fakePlatform = MockConnectivityPlatform();
      ConnectivityPlatform.instance = fakePlatform;
      connectivity = Connectivity();
    });

    test('checkConnectivity', () async {
      ConnectivityResult result = await connectivity.checkConnectivity();
      expect(result, kCheckConnectivityResult);
    });

    test('getWifiName', () async {
      String result = await connectivity.getWifiName();
      expect(result, kWifiNameResult);
    });

    test('getWifiBSSID', () async {
      String result = await connectivity.getWifiBSSID();
      expect(result, kWifiBSSIDResult);
    });

    test('getWifiIP', () async {
      String result = await connectivity.getWifiIP();
      expect(result, kWifiIpAddressResult);
    });

    test('getProxyHost', () async {
      String result = await connectivity.getProxyHost();
      expect(result, kProxyHostResult);
    });

    test('getProxyPort', () async {
      int result = await connectivity.getProxyPort();
      expect(result, kProxyPortResult);
    });

    test('getProxyExclusionList', () async {
      List result = await connectivity.getProxyExclusionList();
      expect(result, kProxyExclusionListResult);
    });

    test('requestLocationServiceAuthorization', () async {
      LocationAuthorizationStatus result =
          await connectivity.requestLocationServiceAuthorization();
      expect(result, kRequestLocationResult);
    });

    test('getLocationServiceAuthorization', () async {
      LocationAuthorizationStatus result =
          await connectivity.getLocationServiceAuthorization();
      expect(result, kRequestLocationResult);
    });
  });
}

class MockConnectivityPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {
  Future<ConnectivityResult> checkConnectivity() async {
    return kCheckConnectivityResult;
  }

  Future<String> getWifiName() async {
    return kWifiNameResult;
  }

  Future<String> getWifiBSSID() async {
    return kWifiBSSIDResult;
  }

  Future<String> getWifiIP() async {
    return kWifiIpAddressResult;
  }

  Future<String> getProxyHost() async {
    return kProxyHostResult;
  }

  Future<int> getProxyPort() async {
    return kProxyPortResult;
  }

  Future<List> getProxyExclusionList() async {
    return kProxyExclusionListResult;
  }

  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization({
    bool requestAlwaysLocationUsage = false,
  }) async {
    return kRequestLocationResult;
  }

  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() async {
    return kGetLocationResult;
  }
}
