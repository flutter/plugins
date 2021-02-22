import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:connectivity_for_web/src/network_information_api_connectivity_plugin.dart';

import 'package:mockito/mockito.dart';

import 'src/connectivity_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('checkConnectivity', () {
    void testCheckConnectivity({
      String type,
      String effectiveType,
      num downlink = 10,
      num rtt = 50,
      ConnectivityResult expected,
    }) {
      final connection = MockNetworkInformation();
      when(connection.type).thenReturn(type);
      when(connection.effectiveType).thenReturn(effectiveType);
      when(connection.downlink).thenReturn(downlink);
      when(connection.rtt).thenReturn(downlink);

      NetworkInformationApiConnectivityPlugin plugin =
          NetworkInformationApiConnectivityPlugin.withConnection(connection);
      expect(plugin.checkConnectivity(), completion(equals(expected)));
    }

    test('0 downlink and rtt -> none', () {
      testCheckConnectivity(
          effectiveType: '4g',
          downlink: 0,
          rtt: 0,
          expected: ConnectivityResult.none);
    });
    test('slow-2g -> mobile', () {
      testCheckConnectivity(
          effectiveType: 'slow-2g', expected: ConnectivityResult.mobile);
    });
    test('2g -> mobile', () {
      testCheckConnectivity(
          effectiveType: '2g', expected: ConnectivityResult.mobile);
    });
    test('3g -> mobile', () {
      testCheckConnectivity(
          effectiveType: '3g', expected: ConnectivityResult.mobile);
    });
    test('4g -> wifi', () {
      testCheckConnectivity(
          effectiveType: '4g', expected: ConnectivityResult.wifi);
    });
  });

  group('get onConnectivityChanged', () {
    test('puts change events in a Stream', () async {
      final connection = MockNetworkInformation();
      NetworkInformationApiConnectivityPlugin plugin =
          NetworkInformationApiConnectivityPlugin.withConnection(connection);

      Stream<ConnectivityResult> results = plugin.onConnectivityChanged;

      // Fake a disconnect-reconnect
      await connection.mockChangeValue(downlink: 0, rtt: 0);
      await connection.mockChangeValue(
          downlink: 10, rtt: 50, effectiveType: '4g');

      // The stream of results is infinite, so we need to .take(2) for this test to complete.
      expect(
          results.take(2).toList(),
          completion(
              equals([ConnectivityResult.none, ConnectivityResult.wifi])));
    });
  });
}
