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
            return 'wifi';
          case 'wifiName':
            return '1337wifi';
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
            await BinaryMessages.handlePlatformMessage(
              Connectivity.eventChannel.name,
              Connectivity.eventChannel.codec.encodeSuccessEnvelope('wifi'),
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
