import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Connectivity', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      Connectivity.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'check':
            return 'wifi/metered';
          case 'wifiName':
            return '1337wifi';
          case 'wifiBSSID':
            return 'c0:ff:33:c0:d3:55';
          case 'wifiIPAddress':
            return '127.0.0.1';
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
              Connectivity.eventChannel.codec.encodeSuccessEnvelope('wifi/metered'),
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
      final NetworkInfo result =
      await Connectivity().onConnectivityChanged.first;
      expect(result.connectivityResult, ConnectivityResult.wifi);
      expect(result.dataSaving, DataSaving.metered);
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

    test('checkConnectivity', () async {
      final NetworkInfo result =
      await Connectivity().checkConnectivity();
      expect(result.connectivityResult, ConnectivityResult.wifi);
      expect(result.dataSaving, DataSaving.metered);
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
